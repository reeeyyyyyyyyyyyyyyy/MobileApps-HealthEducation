<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ModuleController;
use App\Http\Controllers\Admin\QuizController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\PathController;
use App\Http\Controllers\Admin\AnnouncementController;
use App\Http\Controllers\Admin\UploadController;
use App\Http\Controllers\Admin\TipController;
use Inertia\Inertia;

// Welcome Page
Route::get('/', function () {
    return Inertia::render('Welcome', [
        'laravelVersion' => app()->version(),
        'phpVersion' => PHP_VERSION,
    ]);
});

// Public tip endpoint for Flutter (no auth required)
Route::get('/api/tips/today', [TipController::class, 'today']);

// Admin routes with auth
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
    Route::put('modules/{module}/publish', [ModuleController::class, 'publish'])->name('admin.modules.publish');

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

    // Upload & Parse
    Route::post('upload/parse', [UploadController::class, 'parse'])->name('admin.upload.parse');
    Route::post('upload/store-questions', [UploadController::class, 'storeQuestions'])->name('admin.upload.store-questions');

    // Daily Tips
    Route::get('tips', [TipController::class, 'index'])->name('admin.tips.index');
    Route::post('tips', [TipController::class, 'store'])->name('admin.tips.store');
    Route::post('tips/generate', [TipController::class, 'generate'])->name('admin.tips.generate');
    Route::put('tips/{tip}', [TipController::class, 'update'])->name('admin.tips.update');
    Route::delete('tips/{tip}', [TipController::class, 'destroy'])->name('admin.tips.destroy');

    // Learning Paths
    Route::get('paths', [PathController::class, 'index'])->name('admin.paths.index');
    Route::post('paths', [PathController::class, 'store'])->name('admin.paths.store');
    Route::post('paths/reorder', [PathController::class, 'reorder'])->name('admin.paths.reorder');
    Route::put('paths/{id}/order', [PathController::class, 'updateOrder'])->name('admin.paths.update-order');
    Route::delete('paths/{id}', [PathController::class, 'destroy'])->name('admin.paths.destroy');

    // Announcements
    Route::get('announcements', [AnnouncementController::class, 'index'])->name('admin.announcements.index');
    Route::post('announcements', [AnnouncementController::class, 'store'])->name('admin.announcements.store');
    Route::delete('announcements/{id}', [AnnouncementController::class, 'destroy'])->name('admin.announcements.destroy');
});
