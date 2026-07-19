<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class AnnouncementController extends Controller
{
    public function index()
    {
        $announcements = DB::table('announcements')->orderBy('created_at', 'desc')->paginate(10);
        return Inertia::render('Admin/Announcements/Index', ['announcements' => $announcements]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
        ]);
        DB::table('announcements')->insert(['title' => $validated['title'], 'content' => $validated['content']]);
        return redirect()->route('admin.announcements.index')->with('success', 'Pengumuman berhasil dibuat!');
    }

    public function destroy($id)
    {
        DB::table('announcements')->where('id', $id)->delete();
        return redirect()->route('admin.announcements.index')->with('success', 'Pengumuman berhasil dihapus!');
    }
}
