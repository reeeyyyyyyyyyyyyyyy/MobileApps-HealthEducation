<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\EducationMaterial;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class EducationMaterialController extends Controller
{
    public function index(Request $request): Response
    {
        $query = EducationMaterial::query();

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where('title', 'ilike', "%{$search}%")
                  ->orWhere('content', 'ilike', "%{$search}%");
        }

        if ($request->filled('category')) {
            $query->where('category', $request->input('category'));
        }

        if ($request->filled('hbm')) {
            $query->where('hbm_component', $request->input('hbm'));
        }

        $materials = $query->orderBy('sort_order', 'asc')->paginate(12)->withQueryString();

        return Inertia::render('Admin/Education/Index', [
            'materials' => $materials,
            'filters' => $request->only(['search', 'category', 'hbm']),
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Education/Create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|in:pengetahuan_isk,pencegahan,kebersihan,fakta_mitos',
            'hbm_component' => 'required|string|in:perceived_susceptibility,perceived_severity,perceived_benefits,perceived_barriers,cues_to_action,self_efficacy',
            'content' => 'required|string',
            'video_url' => 'nullable|url|max:255',
            'thumbnail_url' => 'nullable|url|max:255',
            'published' => 'required|integer|in:0,1',
            'sort_order' => 'required|integer',
        ]);

        EducationMaterial::create($validated);

        return redirect()->route('admin.education.index')->with('success', 'Materi edukasi berhasil ditambahkan.');
    }

    public function edit(EducationMaterial $education): Response
    {
        return Inertia::render('Admin/Education/Edit', [
            'material' => $education,
        ]);
    }

    public function update(Request $request, EducationMaterial $education): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|in:pengetahuan_isk,pencegahan,kebersihan,fakta_mitos',
            'hbm_component' => 'required|string|in:perceived_susceptibility,perceived_severity,perceived_benefits,perceived_barriers,cues_to_action,self_efficacy',
            'content' => 'required|string',
            'video_url' => 'nullable|url|max:255',
            'thumbnail_url' => 'nullable|url|max:255',
            'published' => 'required|integer|in:0,1',
            'sort_order' => 'required|integer',
        ]);

        $education->update($validated);

        return redirect()->route('admin.education.index')->with('success', 'Materi edukasi berhasil diperbarui.');
    }

    public function destroy(EducationMaterial $education): RedirectResponse
    {
        $education->delete();

        return redirect()->route('admin.education.index')->with('success', 'Materi edukasi berhasil dihapus.');
    }

    public function togglePublish(EducationMaterial $education): RedirectResponse
    {
        $education->update([
            'published' => $education->published === 1 ? 0 : 1,
        ]);

        return back()->with('success', 'Status publikasi materi berhasil diubah.');
    }
}
