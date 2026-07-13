<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Module;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ModuleController extends Controller
{
    public function index(Request $request)
    {
        $query = Module::query();

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $modules = $query->orderBy('title', 'asc')
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('Admin/Modules/Index', [
            'modules' => $modules,
            'filters' => $request->only(['search', 'category']),
        ]);
    }

    public function create()
    {
        return Inertia::render('Admin/Modules/Form', [
            'module' => null,
            'categories' => ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat'],
            'icons' => [
                'psychology_rounded' => 'Psychology (Mitos/Fakta)',
                'volunteer_activism_rounded' => 'Volunteer Activism (Kelola Nyeri)',
                'favorite_rounded' => 'Favorite (Bangga Tubuhmu)',
                'healing_rounded' => 'Healing (Kesehatan)',
                'clean_hands_rounded' => 'Clean Hands (Kebersihan)',
                'restaurant_rounded' => 'Restaurant (Nutrisi)',
                'checkroom_rounded' => 'Checkroom (Pembalut)',
                'self_improvement_rounded' => 'Self Improvement (PMS)',
                'water_drop_rounded' => 'Water Drop (Menstruasi)',
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|in:Pengetahuan,Sikap Positif,Perilaku Sehat',
            'duration' => 'required|string|max:50',
            'icon_name' => 'required|string|max:50',
            'video_url' => 'nullable|url|max:255',
            'content' => 'required|string',
        ]);

        Module::create($validated);

        return redirect()->route('admin.modules.index')->with('success', 'Modul edukasi berhasil dibuat!');
    }

    public function edit(Module $module)
    {
        return Inertia::render('Admin/Modules/Form', [
            'module' => $module,
            'categories' => ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat'],
            'icons' => [
                'psychology_rounded' => 'Psychology (Mitos/Fakta)',
                'volunteer_activism_rounded' => 'Volunteer Activism (Kelola Nyeri)',
                'favorite_rounded' => 'Favorite (Bangga Tubuhmu)',
                'healing_rounded' => 'Healing (Kesehatan)',
                'clean_hands_rounded' => 'Clean Hands (Kebersihan)',
                'restaurant_rounded' => 'Restaurant (Nutrisi)',
                'checkroom_rounded' => 'Checkroom (Pembalut)',
                'self_improvement_rounded' => 'Self Improvement (PMS)',
                'water_drop_rounded' => 'Water Drop (Menstruasi)',
            ],
        ]);
    }

    public function update(Request $request, Module $module)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|in:Pengetahuan,Sikap Positif,Perilaku Sehat',
            'duration' => 'required|string|max:50',
            'icon_name' => 'required|string|max:50',
            'video_url' => 'nullable|url|max:255',
            'content' => 'required|string',
        ]);

        $module->update($validated);

        return redirect()->route('admin.modules.index')->with('success', 'Modul edukasi berhasil diperbarui!');
    }

    public function destroy(Module $module)
    {
        $module->delete();

        return redirect()->route('admin.modules.index')->with('success', 'Modul edukasi berhasil dihapus!');
    }
}
