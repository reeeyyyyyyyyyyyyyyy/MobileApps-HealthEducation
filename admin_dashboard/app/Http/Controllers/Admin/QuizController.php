<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use App\Models\Module;
use App\Models\Question;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class QuizController extends Controller
{
    public function index(Request $request)
    {
        $query = Quiz::with('module')->withCount('questions');

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('module_id')) {
            $query->where('module_id', $request->module_id);
        }

        $quizzes = $query->orderBy('title', 'asc')
            ->paginate(10)
            ->withQueryString();

        $modules = Module::orderBy('title', 'asc')->get(['id', 'title']);

        return Inertia::render('Admin/Quizzes/Index', [
            'quizzes' => $quizzes,
            'modules' => $modules,
            'filters' => $request->only(['search', 'module_id']),
        ]);
    }

    public function create()
    {
        $modules = Module::orderBy('title', 'asc')->get(['id', 'title']);

        return Inertia::render('Admin/Quizzes/Form', [
            'quiz' => null,
            'modules' => $modules,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'module_id' => 'required|exists:modules,id',
            'title' => 'required|string|max:255',
            'xp_reward' => 'required|integer|min:0',
            'description' => 'nullable|string',
            'questions' => 'required|array|min:1',
            'questions.*.question_text' => 'required|string',
            'questions.*.options' => 'required|array|min:2',
            'questions.*.correct_index' => 'required|integer|min:0',
            'questions.*.explanation' => 'nullable|string',
        ]);

        DB::transaction(function () use ($validated) {
            $quiz = Quiz::create([
                'module_id' => $validated['module_id'],
                'title' => $validated['title'],
                'xp_reward' => $validated['xp_reward'],
                'description' => $validated['description'] ?? null,
            ]);

            foreach ($validated['questions'] as $q) {
                Question::create([
                    'quiz_id' => $quiz->id,
                    'question_text' => $q['question_text'],
                    'options' => $q['options'],
                    'correct_index' => $q['correct_index'],
                    'explanation' => $q['explanation'] ?? null,
                ]);
            }
        });

        return redirect()->route('admin.quizzes.index')->with('success', 'Kuis beserta soal berhasil dibuat!');
    }

    public function edit(Quiz $quiz)
    {
        $quiz->load('questions');
        $modules = Module::orderBy('title', 'asc')->get(['id', 'title']);

        return Inertia::render('Admin/Quizzes/Form', [
            'quiz' => $quiz,
            'modules' => $modules,
        ]);
    }

    public function update(Request $request, Quiz $quiz)
    {
        $validated = $request->validate([
            'module_id' => 'required|exists:modules,id',
            'title' => 'required|string|max:255',
            'xp_reward' => 'required|integer|min:0',
            'description' => 'nullable|string',
            'questions' => 'required|array|min:1',
            'questions.*.question_text' => 'required|string',
            'questions.*.options' => 'required|array|min:2',
            'questions.*.correct_index' => 'required|integer|min:0',
            'questions.*.explanation' => 'nullable|string',
        ]);

        DB::transaction(function () use ($quiz, $validated) {
            $quiz->update([
                'module_id' => $validated['module_id'],
                'title' => $validated['title'],
                'xp_reward' => $validated['xp_reward'],
                'description' => $validated['description'] ?? null,
            ]);

            // Re-sync questions
            $quiz->questions()->delete();

            foreach ($validated['questions'] as $q) {
                Question::create([
                    'quiz_id' => $quiz->id,
                    'question_text' => $q['question_text'],
                    'options' => $q['options'],
                    'correct_index' => $q['correct_index'],
                    'explanation' => $q['explanation'] ?? null,
                ]);
            }
        });

        return redirect()->route('admin.quizzes.index')->with('success', 'Kuis beserta soal berhasil diperbarui!');
    }

    public function destroy(Quiz $quiz)
    {
        DB::transaction(function () use ($quiz) {
            $quiz->questions()->delete();
            $quiz->delete();
        });

        return redirect()->route('admin.quizzes.index')->with('success', 'Kuis beserta soal berhasil dihapus!');
    }
}
