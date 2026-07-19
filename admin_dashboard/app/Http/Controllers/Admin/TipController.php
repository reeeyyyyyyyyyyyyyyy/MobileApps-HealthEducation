<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Tip;
use Illuminate\Http\Request;
use Inertia\Inertia;
use OpenAI;

class TipController extends Controller
{
    public function index()
    {
        $tips = Tip::orderBy('created_at', 'desc')->paginate(10);
        return Inertia::render('Admin/Tips/Index', ['tips' => $tips]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string|max:50',
        ]);
        Tip::create($validated);
        return redirect()->route('admin.tips.index')->with('success', 'Tips berhasil ditambahkan!');
    }

    public function update(Request $request, Tip $tip)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string|max:50',
        ]);
        $tip->update($validated);
        return redirect()->route('admin.tips.index')->with('success', 'Tips berhasil diperbarui!');
    }

    public function destroy(Tip $tip)
    {
        $tip->delete();
        return redirect()->route('admin.tips.index')->with('success', 'Tips berhasil dihapus!');
    }

    public function today()
    {
        $today = now()->format('Y-m-d');
        $tip = Tip::whereDate('created_at', $today)->first();
        if ($tip) return response()->json($tip);

        return response()->json(null);
    }

    public function generate()
    {
        $apiKey = env('OPENAI_API_KEY');
        if (empty($apiKey)) {
            return redirect()->route('admin.tips.index')->with('error', 'OPENAI_API_KEY belum diatur.');
        }

        try {
            $client = OpenAI::client($apiKey);
            $response = $client->chat()->create([
                'model' => 'gpt-4o-mini',
                'messages' => [
                    ['role' => 'system', 'content' => 'Kamu adalah asisten kesehatan reproduksi untuk remaja putri Indonesia. Hasilkan 1 tips kesehatan dalam format JSON saja tanpa markdown: {"title": "judul pendek", "content": "isi tips 1-2 kalimat", "category": "kesehatan/siklus/nutrisi/mental"}'],
                    ['role' => 'user', 'content' => "Buat tips kesehatan reproduksi untuk remaja putri. Topik: siklus menstruasi, kebersihan, nutrisi, atau kesehatan mental."],
                ],
                'temperature' => 0.8,
                'max_tokens' => 300,
            ]);

            $jsonText = $response->choices[0]->message->content;
            $jsonText = preg_replace('/^```(?:json)?\s*|\s*```$/i', '', trim($jsonText));
            $data = json_decode($jsonText, true, 512, JSON_THROW_ON_ERROR);

            Tip::create([
                'title' => $data['title'] ?? 'Tips Kesehatan',
                'content' => $data['content'] ?? 'Jaga kesehatan reproduksi dengan pola hidup sehat.',
                'category' => $data['category'] ?? 'kesehatan',
            ]);

            return redirect()->route('admin.tips.index')->with('success', 'Tips AI berhasil dibuat!');
        } catch (\Exception $e) {
            \Log::error('AI Tip generate failed: ' . $e->getMessage());
            return redirect()->route('admin.tips.index')->with('error', 'Gagal generate tips AI: ' . $e->getMessage());
        }
    }
}
