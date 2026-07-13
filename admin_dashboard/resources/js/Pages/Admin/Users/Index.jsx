import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Search, Download, Award, BookOpen, ClipboardList, Shield } from 'lucide-react';

export default function Index({ users, filters }) {
    const [search, setSearch] = React.useState(filters.search || '');

    React.useEffect(() => {
        const query = {};
        if (search) query.search = search;

        const timer = setTimeout(() => {
            router.get('/admin/users', query, {
                preserveState: true,
                replace: true
            });
        }, 300);

        return () => clearTimeout(timer);
    }, [search]);

    return (
        <AdminLayout title="Progres Pengguna" titleParent="Admin">
            <Head title="Progres Pengguna — BloomFem" />

            <div className="bg-white border border-slate-200/80 rounded-2xl shadow-sm overflow-hidden">
                {/* Header Filter Controls */}
                <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
                    <div className="relative rounded-xl shadow-sm flex-1 max-w-md w-full">
                        <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                            <Search className="h-4 w-4" />
                        </div>
                        <input
                            type="text"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            placeholder="Cari username atau nama lengkap..."
                            className="block w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                        />
                    </div>

                    <a
                        href="/admin/users/export"
                        className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 active:scale-98 transition-all rounded-xl shadow-sm w-full sm:w-auto justify-center"
                    >
                        <Download className="w-4 h-4 text-slate-500" />
                        Ekspor Data Pengguna
                    </a>
                </div>

                {/* Table View */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-slate-50/50 border-b border-slate-100 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="py-4.5 px-6">Username</th>
                                <th className="py-4.5 px-6">Nama Lengkap</th>
                                <th className="py-4.5 px-6">Level</th>
                                <th className="py-4.5 px-6">Total XP</th>
                                <th className="py-4.5 px-6">Modul Selesai</th>
                                <th className="py-4.5 px-6">Kuis Lulus</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100 text-sm">
                            {users.data.length > 0 ? (
                                users.data.map((user) => (
                                    <tr key={user.id} className="hover:bg-slate-50/30 transition-all">
                                        <td className="py-4 px-6 font-bold text-slate-700">
                                            {user.username ? `@${user.username}` : '-'}
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            {user.full_name || '-'}
                                        </td>
                                        <td className="py-4 px-6">
                                            <div className="inline-flex items-center gap-1 px-2.5 py-0.5 bg-violet-50 text-violet-700 border border-violet-100/60 rounded-lg text-xs font-bold">
                                                <Shield className="w-3.5 h-3.5 text-violet-500" />
                                                Lvl {user.level || 1}
                                            </div>
                                        </td>
                                        <td className="py-4 px-6">
                                            <div className="inline-flex items-center gap-1 px-2.5 py-0.5 bg-amber-50 text-amber-700 border border-amber-100/60 rounded-lg text-xs font-bold">
                                                <Award className="w-3.5 h-3.5 text-amber-600" />
                                                {user.total_xp || 0} XP
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            <div className="flex items-center gap-1.5">
                                                <BookOpen className="w-4 h-4 text-slate-300" />
                                                {user.modul_selesai || 0}
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 font-semibold text-slate-500">
                                            <div className="flex items-center gap-1.5">
                                                <ClipboardList className="w-4 h-4 text-slate-300" />
                                                {user.passed_quizzes_count || 0}
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="6" className="py-12 text-center text-sm font-semibold text-slate-400">
                                        Tidak ada progres pengguna ditemukan.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {users.links && users.total > users.per_page && (
                    <div className="px-6 py-4 bg-slate-50/30 border-t border-slate-100 flex items-center justify-between gap-4 text-xs font-bold text-slate-400">
                        <div>
                            Menampilkan {users.from || 0} - {users.to || 0} dari {users.total} pengguna
                        </div>
                        <div className="flex gap-1.5">
                            {users.links.map((link, idx) => {
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
