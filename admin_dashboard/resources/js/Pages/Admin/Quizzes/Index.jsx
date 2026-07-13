import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Search, Plus, Edit2, Trash2, Award, ClipboardList } from 'lucide-react';

export default function Index({ quizzes, modules, filters }) {
    const [search, setSearch] = React.useState(filters.search || '');
    const [moduleId, setModuleId] = React.useState(filters.module_id || '');

    React.useEffect(() => {
        const query = {};
        if (search) query.search = search;
        if (moduleId) query.module_id = moduleId;

        const timer = setTimeout(() => {
            router.get('/admin/quizzes', query, {
                preserveState: true,
                replace: true
            });
        }, 300);

        return () => clearTimeout(timer);
    }, [search, moduleId]);

    const handleDelete = (id, title) => {
        if (confirm(`Apakah Anda yakin ingin menghapus kuis "${title}" beserta seluruh soalnya? Tindakan ini tidak dapat dibatalkan.`)) {
            router.delete(`/admin/quizzes/${id}`);
        }
    };

    return (
        <AdminLayout title="Kuis Evaluasi" titleParent="Admin">
            <Head title="Kuis Evaluasi — BloomFem" />

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
                                placeholder="Cari judul kuis..."
                                className="block w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                            />
                        </div>

                        {/* Module Filter */}
                        <select
                            value={moduleId}
                            onChange={(e) => setModuleId(e.target.value)}
                            className="block rounded-xl border border-slate-200 py-2.5 px-3.5 focus:outline-none focus:border-violet-500 text-sm font-semibold transition-all cursor-pointer bg-white max-w-xs"
                        >
                            <option value="">Semua Modul Materi</option>
                            {modules.map((m) => (
                                <option key={m.id} value={m.id}>
                                    {m.title}
                                </option>
                            ))}
                        </select>
                    </div>

                    <Link
                        href="/admin/quizzes/create"
                        className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-98 transition-all rounded-xl shadow-md shadow-violet-100 w-full sm:w-auto justify-center"
                    >
                        <Plus className="w-4 h-4" />
                        Tambah Kuis
                    </Link>
                </div>

                {/* Table View */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-slate-50/50 border-b border-slate-100 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="py-4.5 px-6">Judul Kuis</th>
                                <th className="py-4.5 px-6">Modul Materi</th>
                                <th className="py-4.5 px-6">Hadiah XP</th>
                                <th className="py-4.5 px-6">Jumlah Soal</th>
                                <th className="py-4.5 px-6 text-right">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100 text-sm">
                            {quizzes.data.length > 0 ? (
                                quizzes.data.map((quiz) => (
                                    <tr key={quiz.id} className="hover:bg-slate-50/30 transition-all">
                                        <td className="py-4 px-6 font-bold text-slate-700 max-w-sm">
                                            {quiz.title}
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500 max-w-xs truncate">
                                            {quiz.module ? quiz.module.title : '-'}
                                        </td>
                                        <td className="py-4 px-6">
                                            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-amber-50 text-amber-700 border border-amber-100/60 rounded-lg text-xs font-bold">
                                                <Award className="w-3.5 h-3.5 text-amber-600" />
                                                {quiz.xp_reward} XP
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            <div className="flex items-center gap-1.5">
                                                <ClipboardList className="w-4 h-4 text-slate-300" />
                                                {quiz.questions_count || 0} Soal
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex items-center justify-end gap-1.5">
                                                <Link
                                                    href={`/admin/quizzes/${quiz.id}/edit`}
                                                    className="p-2 text-slate-400 hover:bg-slate-50 hover:text-slate-700 rounded-xl transition-all"
                                                    title="Edit Kuis"
                                                >
                                                    <Edit2 className="w-4 h-4" />
                                                </Link>
                                                <button
                                                    onClick={() => handleDelete(quiz.id, quiz.title)}
                                                    className="p-2 text-slate-400 hover:bg-rose-50 hover:text-rose-600 rounded-xl transition-all"
                                                    title="Hapus Kuis"
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
                                        Tidak ada kuis ditemukan.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {quizzes.links && quizzes.total > quizzes.per_page && (
                    <div className="px-6 py-4 bg-slate-50/30 border-t border-slate-100 flex items-center justify-between gap-4 text-xs font-bold text-slate-400">
                        <div>
                            Menampilkan {quizzes.from || 0} - {quizzes.to || 0} dari {quizzes.total} kuis
                        </div>
                        <div className="flex gap-1.5">
                            {quizzes.links.map((link, idx) => {
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
