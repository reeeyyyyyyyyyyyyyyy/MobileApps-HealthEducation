import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Search, Plus, Edit2, Trash2, Eye, ExternalLink } from 'lucide-react';

import { gooeyToast } from 'goey-toast';

export default function Index({ modules, filters }) {
    const [search, setSearch] = React.useState(filters.search || '');
    const [category, setCategory] = React.useState(filters.category || '');

    // Sync input updates to url parameters
    React.useEffect(() => {
        const query = {};
        if (search) query.search = search;
        if (category) query.category = category;

        const timer = setTimeout(() => {
            router.get('/admin/modules', query, {
                preserveState: true,
                replace: true
            });
        }, 300);

        return () => clearTimeout(timer);
    }, [search, category]);

    const handleDelete = (id, title) => {
        gooeyToast.warning('Hapus Modul?', {
            description: `Modul "${title}" akan dihapus permanen.`,
            preset: 'bouncy',
            duration: 6000,
            action: {
                label: 'Ya, Hapus',
                onClick: () => {
                    router.delete(`/admin/modules/${id}`);
                },
                successLabel: 'Terhapus'
            }
        });
    };

    const getCategoryBadgeClass = (cat) => {
        switch (cat) {
            case 'Pengetahuan':
                return 'bg-blue-50 text-blue-700 border-blue-100/60';
            case 'Sikap Positif':
                return 'bg-emerald-50 text-emerald-700 border-emerald-100/60';
            case 'Perilaku Sehat':
                return 'bg-amber-50 text-amber-700 border-amber-100/60';
            default:
                return 'bg-slate-50 text-slate-700 border-slate-100/60';
        }
    };

    return (
        <AdminLayout title="Modul Edukasi" titleParent="Admin">
            <Head title="Modul Edukasi — BloomFem" />

            <div className="bg-white border border-slate-200/80 rounded-2xl shadow-sm overflow-hidden">
                {/* Header Filter Controls */}
                <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
                    <div className="flex flex-1 flex-col sm:flex-row gap-3 w-full">
                        {/* Search */}
                        <div className="relative rounded-xl shadow-sm flex-1 max-w-md w-full">
                            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                <Search className="h-4 w-4" />
                            </div>
                            <input
                                type="text"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                placeholder="Cari judul modul..."
                                className="block w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                            />
                        </div>

                        {/* Category Filter */}
                        <select
                            value={category}
                            onChange={(e) => setCategory(e.target.value)}
                            className="block rounded-xl border border-slate-200 py-2.5 px-3.5 focus:outline-none focus:border-violet-500 text-sm font-semibold transition-all cursor-pointer bg-white"
                        >
                            <option value="">Semua Kategori</option>
                            <option value="Pengetahuan">Pengetahuan</option>
                            <option value="Sikap Positif">Sikap Positif</option>
                            <option value="Perilaku Sehat">Perilaku Sehat</option>
                        </select>
                    </div>

                    <Link
                        href="/admin/modules/create"
                        className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-98 transition-all rounded-xl shadow-md shadow-violet-100 w-full sm:w-auto justify-center"
                    >
                        <Plus className="w-4 h-4" />
                        Tambah Modul
                    </Link>
                </div>

                {/* Table View */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-slate-50/50 border-b border-slate-100 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="py-4.5 px-6">Judul Modul</th>
                                <th className="py-4.5 px-6">Kategori</th>
                                <th className="py-4.5 px-6">Durasi</th>
                                <th className="py-4.5 px-6">Total Dilihat</th>
                                <th className="py-4.5 px-6 text-right">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100 text-sm">
                            {modules.data.length > 0 ? (
                                modules.data.map((module) => (
                                    <tr key={module.id} className="hover:bg-slate-50/30 transition-all">
                                        <td className="py-4 px-6 font-bold text-slate-700 max-w-sm">
                                            {module.title}
                                            {module.video_url && (
                                                <a 
                                                    href={module.video_url} 
                                                    target="_blank" 
                                                    rel="noreferrer" 
                                                    className="inline-flex items-center gap-0.5 ml-2 text-[10px] font-bold text-violet-500 hover:underline"
                                                >
                                                    Video <ExternalLink className="w-2.5 h-2.5" />
                                                </a>
                                            )}
                                        </td>
                                        <td className="py-4 px-6">
                                            <span className={`inline-block border px-2.5 py-1 rounded-lg text-xs font-bold ${getCategoryBadgeClass(module.category)}`}>
                                                {module.category}
                                            </span>
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            {module.duration}
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            <div className="flex items-center gap-1.5">
                                                <Eye className="w-3.5 h-3.5 text-slate-300" />
                                                {module.view_count || 0}
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex items-center justify-end gap-1.5">
                                                <Link
                                                    href={`/admin/modules/${module.id}/edit`}
                                                    className="p-2 text-slate-400 hover:bg-slate-50 hover:text-slate-700 rounded-xl transition-all"
                                                    title="Edit Modul"
                                                >
                                                    <Edit2 className="w-4 h-4" />
                                                </Link>
                                                <button
                                                    onClick={() => handleDelete(module.id, module.title)}
                                                    className="p-2 text-slate-400 hover:bg-rose-50 hover:text-rose-600 rounded-xl transition-all"
                                                    title="Hapus Modul"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="5" className="py-12 text-center text-sm font-semibold text-slate-400">
                                        Tidak ada modul ditemukan.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination footer */}
                {modules.links && modules.total > modules.per_page && (
                    <div className="px-6 py-4 bg-slate-50/30 border-t border-slate-100 flex items-center justify-between gap-4 text-xs font-bold text-slate-400">
                        <div>
                            Menampilkan {modules.from || 0} - {modules.to || 0} dari {modules.total} modul
                        </div>
                        <div className="flex gap-1.5">
                            {modules.links.map((link, idx) => {
                                // Skip prev/next if labels contain &laquo; or &raquo; to simplify, or render clean arrows
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
