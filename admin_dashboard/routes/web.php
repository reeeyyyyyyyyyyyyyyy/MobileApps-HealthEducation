<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ModuleController;
use App\Http\Controllers\Admin\QuizController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\UserController;
use Inertia\Inertia;

// Welcome Page
Route::get('/', function () {
    return Inertia::render('Welcome', [
        'laravelVersion' => app()->version(),
        'phpVersion' => PHP_VERSION,
    ]);
});

// Admin Authentication Routes
Route::get('/admin/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/admin/login', [LoginController::class, 'login']);
Route::post('/admin/logout', [LoginController::class, 'logout'])->name('logout');

// Authenticated Admin Routes
Route::prefix('admin')->middleware('auth')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('admin.dashboard');

    // Modules CRUD
    Route::resource('modules', ModuleController::class)->names([
        'index' => 'admin.modules.index',
        'create' => 'admin.modules.create',
        'store' => 'admin.modules.store',
        'edit' => 'admin.modules.edit',
        'update' => 'admin.modules.update',
        'destroy' => 'admin.modules.destroy',
    ]);

    // Quizzes CRUD
    Route::resource('quizzes', QuizController::class)->names([
        'index' => 'admin.quizzes.index',
        'create' => 'admin.quizzes.create',
        'store' => 'admin.quizzes.store',
        'edit' => 'admin.quizzes.edit',
        'update' => 'admin.quizzes.update',
        'destroy' => 'admin.quizzes.destroy',
    ]);

    // Reports Moderation
    Route::get('reports', [ReportController::class, 'index'])->name('admin.reports.index');
    Route::post('reports/{report}/delete-content', [ReportController::class, 'deleteContent'])->name('admin.reports.delete-content');
    Route::get('reports/export', [ReportController::class, 'export'])->name('admin.reports.export');

    // Users Progress
    Route::get('users', [UserController::class, 'index'])->name('admin.users.index');
    Route::get('users/export', [UserController::class, 'export'])->name('admin.users.export');
});
