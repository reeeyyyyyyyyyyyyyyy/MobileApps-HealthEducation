import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Download, AlertTriangle, Trash2, Eye, ShieldCheck } from 'lucide-react';

import { gooeyToast } from 'goey-toast';

export default function Index({ reports }) {
    const [selectedReport, setSelectedReport] = React.useState(null);

    const handleDeleteContent = (reportId, reporterName) => {
        gooeyToast.warning('Hapus Konten Forum?', {
            description: `Konten yang dilaporkan oleh "${reporterName}" akan dihapus permanen.`,
            preset: 'bouncy',
            duration: 6000,
            action: {
                label: 'Ya, Hapus',
                onClick: () => {
                    router.post(`/admin/reports/${reportId}/delete-content`);
                },
                successLabel: 'Terhapus'
            }
        });
    };

    return (
        <AdminLayout title="Laporan Moderasi" titleParent="Admin">
            <Head title="Laporan Moderasi — BloomFem" />

            <div className="bg-white border border-slate-200/80 rounded-2xl shadow-sm overflow-hidden">
                {/* Header controls */}
                <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
                    <div>
                        <h3 className="text-sm font-bold text-slate-700">Daftar Laporan Forum</h3>
                        <p className="text-xs text-slate-400 mt-1">Moderasi laporan postingan dan komentar bermasalah di komunitas.</p>
                    </div>

                    <a
                        href="/admin/reports/export"
                        className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 active:scale-98 transition-all rounded-xl shadow-sm w-full sm:w-auto justify-center"
                    >
                        <Download className="w-4 h-4 text-slate-500" />
                        Ekspor Laporan
                    </a>
                </div>

                {/* Table View */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-slate-50/50 border-b border-slate-100 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="py-4.5 px-6">Nama Pelapor</th>
                                <th className="py-4.5 px-6">Alasan</th>
                                <th className="py-4.5 px-6">Jenis Konten</th>
                                <th className="py-4.5 px-6">Tanggal Lapor</th>
                                <th className="py-4.5 px-6 text-right">Tindakan</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100 text-sm">
                            {reports.data.length > 0 ? (
                                reports.data.map((report) => (
                                    <React.Fragment key={report.id}>
                                        <tr className="hover:bg-slate-50/30 transition-all">
                                            <td className="py-4.5 px-6 font-bold text-slate-700">
                                                {report.reporter ? report.reporter.full_name : '-'}
                                            </td>
                                            <td className="py-4.5 px-6 font-semibold text-slate-500 max-w-xs truncate">
                                                {report.reason}
                                            </td>
                                            <td className="py-4.5 px-6">
                                                <span className={`inline-block border px-2.5 py-1 rounded-lg text-xs font-bold ${
                                                    report.content_type === 'Post' 
                                                        ? 'bg-indigo-50 text-indigo-700 border-indigo-100/60' 
                                                        : 'bg-teal-50 text-teal-700 border-teal-100/60'
                                                }`}>
                                                    {report.content_type}
                                                </span>
                                            </td>
                                            <td className="py-4.5 px-6 font-semibold text-slate-400">
                                                {new Date(report.created_at).toLocaleString('id-ID', {
                                                    day: '2-digit',
                                                    month: 'short',
                                                    year: 'numeric',
                                                    hour: '2-digit',
                                                    minute: '2-digit'
                                                })}
                                            </td>
                                            <td className="py-4.5 px-6 text-right">
                                                <div className="flex items-center justify-end gap-1.5">
                                                    <button
                                                        onClick={() => setSelectedReport(selectedReport === report.id ? null : report.id)}
                                                        className={`p-2 rounded-xl transition-all ${
                                                            selectedReport === report.id 
                                                                ? 'bg-violet-50 text-violet-700' 
                                                                : 'text-slate-400 hover:bg-slate-50 hover:text-slate-700'
                                                        }`}
                                                        title="Lihat Detail Konten"
                                                    >
                                                        <Eye className="w-4 h-4" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleDeleteContent(report.id, report.reporter ? report.reporter.full_name : 'User')}
                                                        className="p-2 text-slate-400 hover:bg-rose-50 hover:text-rose-600 rounded-xl transition-all"
                                                        title="Hapus Konten Forum"
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                        {/* Expanded Content View Row */}
                                        {selectedReport === report.id && (
                                            <tr className="bg-slate-50/20">
                                                <td colSpan="5" className="px-6 py-4.5 border-b border-slate-100">
                                                    <div className="bg-white border border-slate-200/60 rounded-xl p-4.5 shadow-inner">
                                                        <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2.5">
                                                            Konten yang Dilaporkan
                                                        </h4>
                                                        <div className="text-xs text-slate-600 leading-relaxed max-w-3xl whitespace-pre-wrap font-semibold border-l-3 border-violet-200 pl-3">
                                                            {report.reported_content}
                                                        </div>
                                                        {(!report.post && !report.comment) && (
                                                            <div className="flex items-center gap-1.5 text-xs font-bold text-rose-500 mt-2.5">
                                                                <AlertTriangle className="w-4 h-4" />
                                                                Konten asli sudah dihapus sebelumnya.
                                                            </div>
                                                        )}
                                                    </div>
                                                </td>
                                            </tr>
                                        )}
                                    </React.Fragment>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="5" className="py-12 text-center text-sm font-semibold text-slate-400">
                                        <div className="flex flex-col items-center justify-center">
                                            <ShieldCheck className="w-10 h-10 text-emerald-500/80 mb-2" />
                                            Tidak ada laporan moderasi yang masuk.
                                        </div>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {reports.links && reports.total > reports.per_page && (
                    <div className="px-6 py-4 bg-slate-50/30 border-t border-slate-100 flex items-center justify-between gap-4 text-xs font-bold text-slate-400">
                        <div>
                            Menampilkan {reports.from || 0} - {reports.to || 0} dari {reports.total} laporan
                        </div>
                        <div className="flex gap-1.5">
                            {reports.links.map((link, idx) => {
                                let label = link.label;
                                if (label.includes('Previous')) label = 'Sebelumnya';
                                else if (label.includes('Next')) label = 'Berikutnya';

                                return (
                                    <Link
                                        key={idx}
                                        href={link.url || '#'}
                                        disabled={!link.url}
                                        className={`px-3 py-1.5 border rounded-lg transition-all ${
                                            link.active
                                                ? 'bg-violet-600 border-violet-600 text-white shadow-sm'
                                                : link.url
                                                ? 'bg-white border-slate-200 text-slate-500 hover:bg-slate-50 hover:border-slate-300'
                                                : 'bg-slate-50 border-slate-100 text-slate-300 cursor-not-allowed'
                                        }`}
                                        dangerouslySetInnerHTML={{ __html: label }}
                                    />
                                );
                            })}
                        </div>
                    </div>
                )}
            </div>
        </AdminLayout>
    );
}
