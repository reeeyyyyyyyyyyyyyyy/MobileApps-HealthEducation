<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RiskQuestion;
use App\Models\RiskOption;
use App\Models\RiskResult;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class CheckRiskController extends Controller
{
    public function index(): Response
    {
        $questions = RiskQuestion::with('options')->orderBy('question_order', 'asc')->get();
        $recentResults = RiskResult::with('user')->orderBy('created_at', 'desc')->paginate(10);

        return Inertia::render('Admin/CheckRisk/Index', [
            'questions' => $questions,
            'recentResults' => $recentResults,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/CheckRisk/Create');
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'question_text' => 'required|string',
            'question_order' => 'required|integer',
            'is_active' => 'required|boolean',
            'options' => 'required|array|min:2',
            'options.*.option_text' => 'required|string',
            'options.*.score' => 'required|integer|min:0|max:10',
            'options.*.option_order' => 'required|integer',
        ]);

        $question = RiskQuestion::create([
            'question_text' => $request->input('question_text'),
            'question_order' => $request->input('question_order'),
            'is_active' => $request->input('is_active'),
            'created_at' => now(),
        ]);

        foreach ($request->input('options') as $opt) {
            RiskOption::create([
                'question_id' => $question->id,
                'option_text' => $opt['option_text'],
                'score' => $opt['score'],
                'option_order' => $opt['option_order'],
            ]);
        }

        return redirect()->route('admin.check-risk.index')->with('success', 'Pertanyaan Check Risk berhasil ditambahkan.');
    }

    public function edit(RiskQuestion $check_risk): Response
    {
        $check_risk->load('options');

        return Inertia::render('Admin/CheckRisk/Edit', [
            'question' => $check_risk,
        ]);
    }

    public function update(Request $request, RiskQuestion $check_risk): RedirectResponse
    {
        $request->validate([
            'question_text' => 'required|string',
            'question_order' => 'required|integer',
            'is_active' => 'required|boolean',
            'options' => 'required|array|min:2',
            'options.*.option_text' => 'required|string',
            'options.*.score' => 'required|integer|min:0|max:10',
            'options.*.option_order' => 'required|integer',
        ]);

        $check_risk->update([
            'question_text' => $request->input('question_text'),
            'question_order' => $request->input('question_order'),
            'is_active' => $request->input('is_active'),
        ]);

        // Delete old options and re-insert
        RiskOption::where('question_id', $check_risk->id)->delete();

        foreach ($request->input('options') as $opt) {
            RiskOption::create([
                'question_id' => $check_risk->id,
                'option_text' => $opt['option_text'],
                'score' => $opt['score'],
                'option_order' => $opt['option_order'],
            ]);
        }

        return redirect()->route('admin.check-risk.index')->with('success', 'Pertanyaan Check Risk berhasil diperbarui.');
    }

    public function destroy(RiskQuestion $check_risk): RedirectResponse
    {
        RiskOption::where('question_id', $check_risk->id)->delete();
        $check_risk->delete();

        return redirect()->route('admin.check-risk.index')->with('success', 'Pertanyaan Check Risk berhasil dihapus.');
    }
}
