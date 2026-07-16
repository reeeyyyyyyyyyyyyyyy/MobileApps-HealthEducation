<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use OpenAI;

class UploadController extends Controller
{
    public function storeQuestions(Request $request)
    {
        $questions = $request->input('questions', []);
        if (!empty($questions)) {
            session()->flash('upload_questions', $questions);
        }
        return response()->json(['success' => true]);
    }

    public function parse(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:md,txt,pdf,docx|max:5120',
        ]);

        $file = $request->file('file');
        $ext = strtolower($file->getClientOriginalExtension());

        $text = match ($ext) {
            'md', 'txt' => file_get_contents($file->getRealPath()),
            'pdf' => $this->parsePdf($file->getRealPath()),
            'docx' => $this->parseDocx($file->getRealPath()),
            default => throw new \Exception('Format tidak didukung'),
        };

        if (empty(trim($text))) {
            return redirect()->route('admin.modules.create')->with('error', 'Gagal membaca konten dari file.');
        }

        $result = $this->parseWithAI($text);

        session()->flash('upload_result', $result);

        return response()->json(['success' => true]);
    }

    private function parsePdf($path): string
    {
        $parser = new \Smalot\PdfParser\Parser();
        $pdf = $parser->parseFile($path);
        return $pdf->getText();
    }

    private function parseDocx($path): string
    {
        $phpWord = \PhpOffice\PhpWord\IOFactory::load($path);
        $text = '';
        foreach ($phpWord->getSections() as $section) {
            foreach ($section->getElements() as $element) {
                if (method_exists($element, 'getText')) {
                    $text .= $element->getText() . "\n";
                }
                if (method_exists($element, 'getElements')) {
                    foreach ($element->getElements() as $child) {
                        if (method_exists($child, 'getText')) {
                            $text .= $child->getText() . "\n";
                        }
                    }
                }
            }
        }
        return $text;
    }

    private function parseWithAI(string $text): array
    {
        $apiKey = env('OPENAI_API_KEY');

        if (empty($apiKey)) {
            return $this->parseManual($text);
        }

        try {
            $client = OpenAI::client($apiKey);

            $response = $client->chat()->create([
                'model' => 'gpt-4o-mini',
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten yang mengubah konten edukasi kesehatan reproduksi remaja menjadi format JSON terstruktur. Kembalikan JSON valid (tanpa markdown, tanpa ```json). Gunakan Bahasa Indonesia.
                        
                        Format:
                        {
                          "title": "judul modul",
                          "category": "Pengetahuan atau Sikap Positif atau Perilaku Sehat",
                          "duration": "X menit",
                          "content": "konten HTML lengkap dengan tag <h1>, <h2>, <p>, <ul>, <li>, <strong>, <em>, <blockquote>",
                          "questions": [
                            {
                              "question_text": "teks pertanyaan",
                              "options": ["Opsi A", "Opsi B", "Opsi C", "Opsi D"],
                              "correct_index": 0,
                              "explanation": "penjelasan jawaban"
                            }
                          ]
                        }

                        Jika tidak ada soal, questions boleh array kosong []. 
                        Gunakan heading <h2> untuk sub-topik. Konten harus informatif dan sesuai untuk remaja putri usia 12-18 tahun.'
                    ],
                    [
                        'role' => 'user',
                        'content' => "Ubah teks berikut menjadi modul edukasi kesehatan reproduksi:\n\n" . substr($text, 0, 15000),
                    ],
                ],
                'temperature' => 0.3,
                'max_tokens' => 4000,
            ]);

            $jsonText = $response->choices[0]->message->content;
            $jsonText = preg_replace('/^```(?:json)?\s*|\s*```$/i', '', trim($jsonText));

            $data = json_decode($jsonText, true, 512, JSON_THROW_ON_ERROR);

            return [
                'title' => $data['title'] ?? 'Hasil Upload',
                'category' => in_array($data['category'] ?? '', ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat']) ? $data['category'] : 'Pengetahuan',
                'duration' => $data['duration'] ?? '5 menit',
                'content' => $data['content'] ?? (new \ParsedownExtra())->text($text),
                'questions' => $data['questions'] ?? [],
            ];
        } catch (\Exception $e) {
            \Log::error('AI Parse failed: ' . $e->getMessage());
            return $this->parseManual($text);
        }
    }

    private function parseManual(string $text): array
    {
        $lines = explode("\n", $text);
        $title = '';
        $content = '';
        $questions = [];
        $currentSection = 'content';
        $currentQuestion = null;

        foreach ($lines as $line) {
            $trimmed = trim($line);

            if (str_starts_with($trimmed, '# ') && empty($title)) {
                $title = substr($trimmed, 2);
                continue;
            }

            if (preg_match('/^##?\s*(soal|quiz|pertanyaan|kuis)/i', $trimmed)) {
                $currentSection = 'quiz';
                continue;
            }

            if ($currentSection === 'quiz') {
                if (preg_match('/^(?:\d+[.\)]|[-*])\s*(.+)/', $trimmed, $m)) {
                    if ($currentQuestion) $questions[] = $currentQuestion;
                    $currentQuestion = ['question_text' => $m[1], 'options' => [], 'correct_index' => 0, 'explanation' => ''];
                    continue;
                }

                if ($currentQuestion && preg_match('/^([A-Da-d])[.)]\s*(.+?)(?:\s*[✓x])?/i', $trimmed, $m)) {
                    $currentQuestion['options'][] = $m[2];
                    if (!empty($m[3])) $currentQuestion['correct_index'] = count($currentQuestion['options']) - 1;
                    continue;
                }

                if ($currentQuestion && preg_match('/^(?:penjelasan|alasan|>:)\s*(.+)/i', $trimmed, $m)) {
                    $currentQuestion['explanation'] = $m[1];
                    continue;
                }

                if (empty($trimmed) && $currentQuestion) {
                    $questions[] = $currentQuestion;
                    $currentQuestion = null;
                }
            } else {
                $content .= $line . "\n";
            }
        }

        if ($currentQuestion) $questions[] = $currentQuestion;

        return [
            'title' => $title ?: 'Hasil Upload',
            'category' => preg_match('/sikap|positif/i', $text) ? 'Sikap Positif' : (preg_match('/perilaku|sehat|olahraga|makan/i', $text) ? 'Perilaku Sehat' : 'Pengetahuan'),
            'duration' => max(1, ceil(str_word_count($text) / 200)) . ' menit',
            'content' => (new \ParsedownExtra())->text($content),
            'questions' => $questions,
        ];
    }
}
