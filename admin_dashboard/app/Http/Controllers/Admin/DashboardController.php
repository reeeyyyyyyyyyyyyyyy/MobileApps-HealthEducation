<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Post;
use App\Models\Report;
use App\Models\Module;
use App\Models\UserQuiz;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'totalUsers' => User::count(),
            'totalPosts' => Post::count(),
            'totalReports' => Report::count(),
        ];

        $popularModules = Module::orderBy('view_count', 'desc')
            ->take(5)
            ->get(['title', 'view_count']);

        $passedCount = UserQuiz::where('status', 'passed')->count();
        $failedCount = UserQuiz::where('status', 'failed')->count();

        $quizRatio = [
            ['name' => 'Lulus', 'value' => $passedCount],
            ['name' => 'Gagal', 'value' => $failedCount],
        ];

        return Inertia::render('Admin/Dashboard', [
            'stats' => $stats,
            'popularModules' => $popularModules,
            'quizRatio' => $quizRatio,
        ]);
    }
}
