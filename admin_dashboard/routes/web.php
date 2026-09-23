<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\RespondentController;
use App\Http\Controllers\Admin\EducationMaterialController;
use App\Http\Controllers\Admin\CheckRiskController;
use App\Http\Controllers\Admin\ReminderTemplateController;
use App\Http\Controllers\Admin\SurveyInstrumentController;
use App\Http\Controllers\Admin\TipController;
use Inertia\Inertia;

// Landing / Redirect
Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

// Admin Auth
Route::get('/admin/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/admin/login', [LoginController::class, 'login']);
Route::post('/admin/logout', [LoginController::class, 'logout'])->name('logout');

// Authenticated Admin Routes
Route::prefix('admin')->middleware('auth')->group(function () {
    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('admin.dashboard');

    // Responden Penelitian
    Route::get('respondents/export', [RespondentController::class, 'export'])->name('admin.respondents.export');
    Route::get('respondents', [RespondentController::class, 'index'])->name('admin.respondents.index');
    Route::get('respondents/{id}', [RespondentController::class, 'show'])->name('admin.respondents.show');

    // Materi Edukasi ISK (HBM)
    Route::resource('education', EducationMaterialController::class)->names([
        'index' => 'admin.education.index',
        'create' => 'admin.education.create',
        'store' => 'admin.education.store',
        'edit' => 'admin.education.edit',
        'update' => 'admin.education.update',
        'destroy' => 'admin.education.destroy',
    ]);
    Route::put('education/{education}/publish', [EducationMaterialController::class, 'togglePublish'])->name('admin.education.publish');

    // Skrining Risiko ISK (Check Risk)
    Route::resource('check-risk', CheckRiskController::class)->names([
        'index' => 'admin.check-risk.index',
        'create' => 'admin.check-risk.create',
        'store' => 'admin.check-risk.store',
        'edit' => 'admin.check-risk.edit',
        'update' => 'admin.check-risk.update',
        'destroy' => 'admin.check-risk.destroy',
    ]);

    // Template Pengingat Kebiasaan
    Route::resource('reminders', ReminderTemplateController::class)->names([
        'index' => 'admin.reminders.index',
        'create' => 'admin.reminders.create',
        'store' => 'admin.reminders.store',
        'edit' => 'admin.reminders.edit',
        'update' => 'admin.reminders.update',
        'destroy' => 'admin.reminders.destroy',
    ]);

    // Instrumen Kuesioner (Pre-test & Post-test)
    Route::resource('survey', SurveyInstrumentController::class)->names([
        'index' => 'admin.survey.index',
        'create' => 'admin.survey.create',
        'store' => 'admin.survey.store',
        'edit' => 'admin.survey.edit',
        'update' => 'admin.survey.update',
        'destroy' => 'admin.survey.destroy',
    ]);

    // Tips Harian Pencegahan ISK
    Route::get('tips', [TipController::class, 'index'])->name('admin.tips.index');
    Route::post('tips', [TipController::class, 'store'])->name('admin.tips.store');
    Route::post('tips/generate', [TipController::class, 'generate'])->name('admin.tips.generate');
    Route::put('tips/{tip}', [TipController::class, 'update'])->name('admin.tips.update');
    Route::delete('tips/{tip}', [TipController::class, 'destroy'])->name('admin.tips.destroy');
});
