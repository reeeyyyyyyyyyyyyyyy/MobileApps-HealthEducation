<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Module;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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
        $paths = DB::table('learning_paths')->orderBy('sort_order')->get(['id', 'title']);

        return Inertia::render('Admin/Modules/Form', [
            'module' => null,
            'categories' => ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat'],
            'learningPaths' => $paths,
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
            'published' => 'boolean',
            'scheduled_at' => 'nullable|date',
        ]);

        $validated['published'] = $request->boolean('published');
        if (!empty($validated['scheduled_at'] ?? null)) {
            $validated['published'] = false;
        }

        $module = Module::create($validated);

        // Jika ada path_id, assign modul ke path tersebut
        if ($request->filled('path_id') && $request->path_id !== 'none') {
            $maxSort = DB::table('learning_path_modules')
                ->where('path_id', $request->path_id)
                ->max('sort_order') ?? 0;
            DB::table('learning_path_modules')->insert([
                'path_id' => $request->path_id,
                'module_id' => $module->id,
                'sort_order' => $maxSort + 1,
            ]);
        }

        return redirect()->route('admin.modules.index')
            ->with('success', 'Modul edukasi berhasil dibuat!')
            ->with('module_id', $module->id);
    }

    public function edit(Module $module)
    {
        return Inertia::render('Admin/Modules/Form', [
            'module' => $module,
            'categories' => ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat'],
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

    public function publish(Module $module)
    {
        $module->update(['published' => true, 'scheduled_at' => null]);

        return redirect()->route('admin.modules.index')->with('success', 'Modul berhasil dipublikasikan!');
    }
}