<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DailyTip;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Http\RedirectResponse;
use OpenAI;

class TipController extends Controller
{
    public function index(): Response
    {
        $tips = DailyTip::orderBy('id', 'asc')->paginate(15);
        return Inertia::render('Admin/Tips/Index', ['tips' => $tips]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string|max:50',
            'is_active' => 'required|boolean',
        ]);
        DailyTip::create($validated);
        return redirect()->route('admin.tips.index')->with('success', 'Tips pencegahan ISK berhasil ditambahkan!');
    }

    public function update(Request $request, DailyTip $tip): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string|max:50',
            'is_active' => 'required|boolean',
        ]);
        $tip->update($validated);
        return redirect()->route('admin.tips.index')->with('success', 'Tips pencegahan ISK berhasil diperbarui!');
    }

    public function destroy(DailyTip $tip): RedirectResponse
    {
        $tip->delete();
        return redirect()->route('admin.tips.index')->with('success', 'Tips berhasil dihapus!');
    }

    public function generate(): RedirectResponse
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
                    ['role' => 'system', 'content' => 'Kamu adalah asisten edukasi pencegahan Infeksi Saluran Kemih (ISK) untuk remaja putri Indonesia. Hasilkan 1 tips pencegahan ISK dalam format JSON saja tanpa markdown: {"title": "judul pendek", "content": "isi tips praktis 1-2 kalimat", "category": "hidrasi/kebersihan/kebiasaan/aktivitas/motivasi"}'],
                    ['role' => 'user', 'content' => 'Buat 1 tips baru untuk remaja putri agar terhindar dari infeksi saluran kemih (ISK).'],
                ],
                'temperature' => 0.8,
                'max_tokens' => 300,
            ]);

            $jsonText = $response->choices[0]->message->content;
            $jsonText = preg_replace('/^```(?:json)?\s*|\s*```$/i', '', trim($jsonText));
            $data = json_decode($jsonText, true, 512, JSON_THROW_ON_ERROR);

            DailyTip::create([
                'title' => $data['title'] ?? 'Tips Pencegahan ISK',
                'content' => $data['content'] ?? 'Minum air putih minimal 8 gelas sehari dan jangan menahan buang air kecil.',
                'category' => $data['category'] ?? 'kebiasaan',
                'is_active' => true,
                'created_at' => now(),
            ]);

            return redirect()->route('admin.tips.index')->with('success', 'Tips ISK AI berhasil digenerate!');
        } catch (\Exception $e) {
            \Log::error('AI Tip generate failed: ' . $e->getMessage());
            return redirect()->route('admin.tips.index')->with('error', 'Gagal generate tips AI: ' . $e->getMessage());
        }
    }
}
