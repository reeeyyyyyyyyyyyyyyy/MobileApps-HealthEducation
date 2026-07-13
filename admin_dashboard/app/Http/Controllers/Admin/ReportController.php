<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\Post;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class ReportController extends Controller
{
    public function index()
    {
        $reports = Report::with(['reporter', 'post', 'comment'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        // Map report type and content dynamically for ease of use in React
        $reports->getCollection()->transform(function ($report) {
            $report->content_type = $report->post_id ? 'Post' : ($report->comment_id ? 'Komentar' : 'Tidak Diketahui');
            $report->reported_content = $report->post ? $report->post->content : ($report->comment ? $report->comment->content : '-');
            return $report;
        });

        return Inertia::render('Admin/Reports/Index', [
            'reports' => $reports,
        ]);
    }

    public function deleteContent(Report $report)
    {
        DB::transaction(function () use ($report) {
            if ($report->post_id) {
                Post::where('id', $report->post_id)->delete();
            } elseif ($report->comment_id) {
                Comment::where('id', $report->comment_id)->delete();
            }
            
            // Delete the report itself or keep it? Filament action deletes the content but keeps the report or deletes both?
            // In the original Filament action (ReportResource.php lines 91-108), it deletes the post or comment, but does not delete the report.
            // Let's delete the content. Since cascade deletion is not defined, we keep the report but the post/comment is deleted.
        });

        return redirect()->route('admin.reports.index')->with('success', 'Konten yang dilaporkan berhasil dihapus dari forum!');
    }

    public function export()
    {
        $reports = Report::with(['reporter', 'post', 'comment'])
            ->orderBy('created_at', 'desc')
            ->get();

        $filename = "laporan-moderasi-" . date('Y-m-d-His') . ".csv";

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
            'Pragma' => 'no-cache',
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Expires' => '0'
        ];

        $callback = function () use ($reports) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID Laporan',
                'Nama Pelapor',
                'Alasan',
                'Jenis Konten',
                'Konten yang Dilaporkan',
                'Tanggal Lapor'
            ]);

            foreach ($reports as $report) {
                $contentType = $report->post_id ? 'Post' : ($report->comment_id ? 'Komentar' : '-');
                $content = $report->post ? $report->post->content : ($report->comment ? $report->comment->content : '-');

                fputcsv($file, [
                    $report->id,
                    $report->reporter ? $report->reporter->full_name : '-',
                    $report->reason,
                    $contentType,
                    strip_tags($content),
                    $report->created_at ? $report->created_at->format('Y-m-d H:i:s') : '-'
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
