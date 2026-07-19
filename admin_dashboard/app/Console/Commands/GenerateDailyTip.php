<?php

namespace App\Console\Commands;

use App\Models\Tip;
use Illuminate\Console\Command;
use OpenAI;

class GenerateDailyTip extends Command
{
    protected $signature = 'tips:generate-daily';
    protected $description = 'Generate daily health tip via AI at 06:00';

    public function handle(): int
    {
        $today = now()->format('Y-m-d');

        // Skip if already have a tip for today
        if (Tip::whereDate('created_at', $today)->exists()) {
            $this->info('Tip already exists for today.');
            return Command::SUCCESS;
        }

        $apiKey = env('OPENAI_API_KEY');
        if (empty($apiKey)) {
            $this->error('OPENAI_API_KEY not set.');
            return Command::FAILURE;
        }

        try {
            $client = OpenAI::client($apiKey);
            $response = $client->chat()->create([
                'model' => 'gpt-4o-mini',
                'messages' => [
                    ['role' => 'system', 'content' => 'Kamu adalah asisten kesehatan reproduksi untuk remaja putri Indonesia. Hasilkan 1 tips kesehatan dalam format JSON saja tanpa markdown: {"title": "judul pendek", "content": "isi tips 1-2 kalimat", "category": "kesehatan/siklus/nutrisi/mental"}'],
                    ['role' => 'user', 'content' => "Buat tips kesehatan reproduksi untuk remaja putri. Hari ini tanggal {$today}. Topik: siklus menstruasi, kebersihan, nutrisi, atau kesehatan mental."],
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

            $this->info('Daily tip generated successfully.');
            return Command::SUCCESS;
        } catch (\Exception $e) {
            \Log::error('Daily tip generation failed: ' . $e->getMessage());
            $this->error('Failed: ' . $e->getMessage());
            return Command::FAILURE;
        }
    }
}
