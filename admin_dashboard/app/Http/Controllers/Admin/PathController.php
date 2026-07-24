<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LearningPath;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class PathController extends Controller
{
    public function index()
    {
        $paths = LearningPath::ordered()->get();
        $assignedModuleIds = DB::table('learning_path_modules')->pluck('module_id')->unique()->toArray();
        $modules = DB::table('modules')
            ->where('published', 1)
            ->whereNotIn('id', $assignedModuleIds)
            ->orderBy('title')
            ->get(['id', 'title']);
        $pathModules = DB::table('learning_path_modules')->get();

        return Inertia::render('Admin/Paths/Index', [
            'paths' => $paths,
            'allModules' => $modules,
            'pathModules' => $pathModules,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'icon' => 'nullable|string|max:50',
            'module_ids' => 'nullable|array',
            'module_ids.*' => 'exists:modules,id',
        ]);

        $path = LearningPath::create([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? '',
            'icon' => $validated['icon'] ?? 'route',
        ]);

        if (!empty($validated['module_ids'])) {
            $data = [];
            foreach ($validated['module_ids'] as $i => $modId) {
                $data[] = ['path_id' => $path->id, 'module_id' => $modId, 'sort_order' => $i];
            }
            DB::table('learning_path_modules')->insert($data);
        }

        return redirect()->route('admin.paths.index')->with('success', 'Path berhasil dibuat!');
    }

    public function updateOrder(Request $request, $id)
    {
        $id = (string) $id;
        if (!str_contains($id, '-')) {
            return back()->with('error', 'ID path tidak valid');
        }

        $path = DB::table('learning_paths')->where('id', $id)->first();
        if (!$path) return back()->with('error', 'Path tidak ditemukan');

        $direction = $request->input('direction');
        $swap = $direction === 'up'
            ? DB::table('learning_paths')->where('sort_order', '<', $path->sort_order)->orderBy('sort_order', 'desc')->first()
            : DB::table('learning_paths')->where('sort_order', '>', $path->sort_order)->orderBy('sort_order', 'asc')->first();

        if (!$swap) return back();

        DB::table('learning_paths')->where('id', $path->id)->update(['sort_order' => $swap->sort_order]);
        DB::table('learning_paths')->where('id', $swap->id)->update(['sort_order' => $path->sort_order]);

        return back()->with('success', 'Urutan path berhasil diubah!');
    }

    public function destroy($id)
    {
        DB::table('learning_path_modules')->where('path_id', $id)->delete();
        DB::table('learning_paths')->where('id', $id)->delete();
        return redirect()->route('admin.paths.index')->with('success', 'Path berhasil dihapus!');
    }
}
