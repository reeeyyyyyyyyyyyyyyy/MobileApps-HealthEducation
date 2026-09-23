<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SurveyInstrument;
use App\Models\SurveyOption;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SurveyInstrumentController extends Controller
{
    public function index(Request $request): Response
    {
        $type = $request->input('type', 'pretest');
        $variable = $request->input('variable', 'all');

        $query = SurveyInstrument::with('options')->where('type', $type);

        if ($variable !== 'all') {
            $query->where('variable', $variable);
        }

        $instruments = $query->orderBy('variable', 'asc')->orderBy('question_order', 'asc')->get();

        return Inertia::render('Admin/Survey/Index', [
            'instruments' => $instruments,
            'currentType' => $type,
            'currentVariable' => $variable,
        ]);
    }

    public function create(Request $request): Response
    {
        return Inertia::render('Admin/Survey/Create', [
            'defaultType' => $request->input('type', 'pretest'),
            'defaultVariable' => $request->input('variable', 'pengetahuan'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'type' => 'required|in:pretest,posttest',
            'variable' => 'required|in:pengetahuan,sikap,perilaku',
            'question_text' => 'required|string',
            'question_order' => 'required|integer',
            'is_active' => 'required|boolean',
        ]);

        $instrument = SurveyInstrument::create([
            'type' => $validated['type'],
            'variable' => $validated['variable'],
            'question_text' => $validated['question_text'],
            'question_order' => $validated['question_order'],
            'is_active' => $validated['is_active'],
            'created_at' => now(),
        ]);

        // Create standard 5-point Likert options
        $defaultOptions = [
            ['text' => 'Sangat Setuju', 'score' => 5, 'order' => 1],
            ['text' => 'Setuju', 'score' => 4, 'order' => 2],
            ['text' => 'Ragu-ragu', 'score' => 3, 'order' => 3],
            ['text' => 'Tidak Setuju', 'score' => 2, 'order' => 4],
            ['text' => 'Sangat Tidak Setuju', 'score' => 1, 'order' => 5],
        ];

        foreach ($defaultOptions as $opt) {
            SurveyOption::create([
                'instrument_id' => $instrument->id,
                'option_text' => $opt['text'],
                'score' => $opt['score'],
                'option_order' => $opt['order'],
            ]);
        }

        return redirect()->route('admin.survey.index', ['type' => $validated['type']])
            ->with('success', 'Instrumen kuesioner berhasil ditambahkan.');
    }

    public function edit(SurveyInstrument $survey): Response
    {
        $survey->load('options');

        return Inertia::render('Admin/Survey/Edit', [
            'instrument' => $survey,
        ]);
    }

    public function update(Request $request, SurveyInstrument $survey): RedirectResponse
    {
        $validated = $request->validate([
            'type' => 'required|in:pretest,posttest',
            'variable' => 'required|in:pengetahuan,sikap,perilaku',
            'question_text' => 'required|string',
            'question_order' => 'required|integer',
            'is_active' => 'required|boolean',
        ]);

        $survey->update($validated);

        return redirect()->route('admin.survey.index', ['type' => $validated['type']])
            ->with('success', 'Instrumen kuesioner berhasil diperbarui.');
    }

    public function destroy(SurveyInstrument $survey): RedirectResponse
    {
        $type = $survey->type;
        SurveyOption::where('instrument_id', $survey->id)->delete();
        $survey->delete();

        return redirect()->route('admin.survey.index', ['type' => $type])
            ->with('success', 'Instrumen kuesioner berhasil dihapus.');
    }
}
