<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Module;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Carbon\Carbon;

class ModuleController extends Controller
{
    public function index(Request $request)
    {
        DB::table('modules')
            ->where('published', 0)
            ->whereNotNull('scheduled_at')
            ->where('scheduled_at', '<=', now())
            ->update(['published' => 1]);

        $query = Module::query();
        if ($request->filled('search')) $query->where('title', 'like', '%' . $request->search . '%');
        if ($request->filled('category')) $query->where('category', $request->category);

        $modules = $query->orderBy('title', 'asc')->paginate(10)->withQueryString();

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
            'scheduled_at' => 'nullable',
        ]);

        $validated['published'] = $request->boolean('published') ? 1 : 0;
        if (!empty($validated['scheduled_at'] ?? null)) {
            $validated['published'] = 0;
            try {
                $raw = str_replace('T', ' ', (string)$validated['scheduled_at']);
                $raw = substr($raw, 0, 16);
                $dt = Carbon::createFromFormat('Y-m-d H:i', $raw, 'Asia/Jakarta');
                if ($dt) { $dt->setTimezone('UTC'); $validated['scheduled_at'] = $dt->format('Y-m-d H:i:s'); }
            } catch (\Exception $e) { $validated['scheduled_at'] = null; }
        }

        $module = Module::create($validated);

        if ($request->filled('path_id') && $request->path_id !== 'none') {
            $maxSort = DB::table('learning_path_modules')->where('path_id', $request->path_id)->max('sort_order') ?? 0;
            DB::table('learning_path_modules')->insert(['path_id' => $request->path_id, 'module_id' => $module->id, 'sort_order' => $maxSort + 1]);
        }

        return redirect()->route('admin.modules.index')
            ->with('success', 'Modul edukasi berhasil dibuat!')
            ->with('module_id', $module->id);
    }

    public function edit(Module $module)
    {
        $paths = DB::table('learning_paths')->orderBy('sort_order')->get(['id', 'title']);
        $assignedPath = DB::table('learning_path_modules')->where('module_id', $module->id)->first();

        if ($module->scheduled_at) {
            try {
                $dt = Carbon::parse($module->scheduled_at, 'UTC')->setTimezone('Asia/Jakarta');
                $module->scheduled_at = $dt->format('Y-m-d\TH:i');
            } catch (\Exception $e) {}
        }

        return Inertia::render('Admin/Modules/Form', [
            'module' => $module,
            'categories' => ['Pengetahuan', 'Sikap Positif', 'Perilaku Sehat'],
            'learningPaths' => $paths,
            'assignedPathId' => $assignedPath ? $assignedPath->path_id : 'none',
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
            'published' => 'boolean',
            'scheduled_at' => 'nullable',
        ]);

        $validated['published'] = $request->boolean('published') ? 1 : 0;
        if (!empty($validated['scheduled_at'] ?? null)) {
            $validated['published'] = 0;
            try {
                $raw = str_replace('T', ' ', (string)$validated['scheduled_at']);
                $raw = substr($raw, 0, 16);
                $dt = Carbon::createFromFormat('Y-m-d H:i', $raw, 'Asia/Jakarta');
                if ($dt) { $dt->setTimezone('UTC'); $validated['scheduled_at'] = $dt->format('Y-m-d H:i:s'); }
            } catch (\Exception $e) { $validated['scheduled_at'] = null; }
        } else {
            $validated['scheduled_at'] = null;
        }

        $module->update($validated);

        DB::table('learning_path_modules')->where('module_id', $module->id)->delete();
        if ($request->filled('path_id') && $request->path_id !== 'none') {
            $maxSort = DB::table('learning_path_modules')->where('path_id', $request->path_id)->max('sort_order') ?? 0;
            DB::table('learning_path_modules')->insert(['path_id' => $request->path_id, 'module_id' => $module->id, 'sort_order' => $maxSort + 1]);
        }

        return redirect()->route('admin.modules.index')->with('success', 'Modul edukasi berhasil diperbarui!');
    }

    public function destroy(Module $module)
    {
        $module->delete();
        return redirect()->route('admin.modules.index')->with('success', 'Modul edukasi berhasil dihapus!');
    }

    public function publish(Module $module)
    {
        $module->update(['published' => 1, 'scheduled_at' => null]);
        return redirect()->route('admin.modules.index')->with('success', 'Modul berhasil dipublikasikan!');
    }
}
