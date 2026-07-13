<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query();

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('username', 'like', '%' . $search . '%')
                  ->orWhere('full_name', 'like', '%' . $search . '%');
            });
        }

        $users = $query->orderBy('full_name', 'asc')
            ->paginate(10)
            ->withQueryString();

        // Dynamically append passed quizzes count for display in React
        $users->getCollection()->transform(function ($user) {
            $user->passed_quizzes_count = $user->userQuizzes()->where('status', 'passed')->count();
            return $user;
        });

        return Inertia::render('Admin/Users/Index', [
            'users' => $users,
            'filters' => $request->only(['search']),
        ]);
    }

    public function export()
    {
        $users = User::orderBy('full_name', 'asc')->get();

        $filename = "progres-pengguna-" . date('Y-m-d-His') . ".csv";

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
            'Pragma' => 'no-cache',
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Expires' => '0'
        ];

        $callback = function () use ($users) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID Pengguna',
                'Username',
                'Nama Lengkap',
                'Level',
                'Total XP',
                'Modul Selesai',
                'Jumlah Kuis Lulus'
            ]);

            foreach ($users as $user) {
                $passedQuizzes = $user->userQuizzes()->where('status', 'passed')->count();

                fputcsv($file, [
                    $user->id,
                    $user->username,
                    $user->full_name,
                    $user->level,
                    $user->total_xp,
                    $user->modul_selesai,
                    $passedQuizzes
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
