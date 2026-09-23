<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ReminderTemplate;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ReminderTemplateController extends Controller
{
    public function index(): Response
    {
        $templates = ReminderTemplate::orderBy('sort_order', 'asc')->get();

        return Inertia::render('Admin/Reminders/Index', [
            'templates' => $templates,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Reminders/Create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'default_time' => 'required|string',
            'icon_name' => 'required|string',
            'is_active' => 'required|boolean',
            'sort_order' => 'required|integer',
        ]);

        ReminderTemplate::create($validated);

        return redirect()->route('admin.reminders.index')->with('success', 'Template pengingat berhasil ditambahkan.');
    }

    public function edit(ReminderTemplate $reminder): Response
    {
        return Inertia::render('Admin/Reminders/Edit', [
            'template' => $reminder,
        ]);
    }

    public function update(Request $request, ReminderTemplate $reminder): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'default_time' => 'required|string',
            'icon_name' => 'required|string',
            'is_active' => 'required|boolean',
            'sort_order' => 'required|integer',
        ]);

        $reminder->update($validated);

        return redirect()->route('admin.reminders.index')->with('success', 'Template pengingat berhasil diperbarui.');
    }

    public function destroy(ReminderTemplate $reminder): RedirectResponse
    {
        $reminder->delete();

        return redirect()->route('admin.reminders.index')->with('success', 'Template pengingat berhasil dihapus.');
    }
}
