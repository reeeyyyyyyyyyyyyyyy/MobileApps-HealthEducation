import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save } from 'lucide-react';

import { gooeyToast } from 'goey-toast';

export default function Form({ module, categories, icons }) {
    const isEdit = !!module;

    const { data, setData, post, put, processing, errors } = useForm({
        title: module?.title || '',
        category: module?.category || 'Pengetahuan',
        duration: module?.duration || '',
        icon_name: module?.icon_name || 'water_drop_rounded',
        video_url: module?.video_url || '',
        content: module?.content || '',
    });

    React.useEffect(() => {
        const errorKeys = Object.keys(errors);
        if (errorKeys.length > 0) {
            gooeyToast.error('Gagal menyimpan modul!', {
                description: errors[errorKeys[0]],
                preset: 'bouncy',
                duration: 5000
            });
        }
    }, [errors]);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (isEdit) {
            put(`/admin/modules/${module.id}`);
        } else {
            post('/admin/modules');
        }
    };

    return (
        <AdminLayout title={isEdit ? 'Edit Modul Edukasi' : 'Tambah Modul Edukasi'} titleParent="Modul Edukasi">
            <Head title={`${isEdit ? 'Edit' : 'Tambah'} Modul Edukasi — BloomFem`} />

            <div className="max-w-3xl">
                <Link
                    href="/admin/modules"
                    className="inline-flex items-center gap-2 text-xs font-bold text-slate-500 hover:text-slate-800 transition-colors mb-6"
                >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Kembali ke Daftar Modul
                </Link>

                <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* Title */}
                        <div>
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                Judul Modul
                            </label>
                            <input
                                type="text"
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                placeholder="Ketik judul artikel edukasi..."
                                className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                    errors.title ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                }`}
                                required
                            />
                            {errors.title && (
                                <p className="text-xs font-bold text-rose-500 mt-2">{errors.title}</p>
                            )}
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Category */}
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Kategori
                                </label>
                                <select
                                    value={data.category}
                                    onChange={(e) => setData('category', e.target.value)}
                                    className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all cursor-pointer bg-white ${
                                        errors.category ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                    required
                                >
                                    {categories.map((cat) => (
                                        <option key={cat} value={cat}>
                                            {cat}
                                        </option>
                                    ))}
                                </select>
                                {errors.category && (
                                    <p className="text-xs font-bold text-rose-500 mt-2">{errors.category}</p>
                                )}
                            </div>

                            {/* Duration */}
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Durasi Baca (e.g. "5 menit")
                                </label>
                                <input
                                    type="text"
                                    value={data.duration}
                                    onChange={(e) => setData('duration', e.target.value)}
                                    placeholder="Contoh: 5 menit"
                                    className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                        errors.duration ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                    required
                                />
                                {errors.duration && (
                                    <p className="text-xs font-bold text-rose-500 mt-2">{errors.duration}</p>
                                )}
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Icon Name Selection */}
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Ikon Modul
                                </label>
                                <select
                                    value={data.icon_name}
                                    onChange={(e) => setData('icon_name', e.target.value)}
                                    className="block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all cursor-pointer bg-white"
                                    required
                                >
                                    {Object.entries(icons).map(([val, label]) => (
                                        <option key={val} value={val}>
                                            {label}
                                        </option>
                                    ))}
                                </select>
                            </div>

                            {/* Video URL */}
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Link Video YouTube (Opsional)
                                </label>
                                <input
                                    type="url"
                                    value={data.video_url}
                                    onChange={(e) => setData('video_url', e.target.value)}
                                    placeholder="Contoh: https://youtube.com/watch?v=..."
                                    className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                        errors.video_url ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                />
                                {errors.video_url && (
                                    <p className="text-xs font-bold text-rose-500 mt-2">{errors.video_url}</p>
                                )}
                            </div>
                        </div>

                        {/* Content text */}
                        <div>
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                Konten Edukasi Lengkap
                            </label>
                            <textarea
                                value={data.content}
                                onChange={(e) => setData('content', e.target.value)}
                                placeholder="Ketik isi modul edukasi lengkap..."
                                rows="12"
                                className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all font-sans leading-relaxed ${
                                    errors.content ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                }`}
                                required
                            />
                            {errors.content && (
                                <p className="text-xs font-bold text-rose-500 mt-2">{errors.content}</p>
                            )}
                        </div>

                        {/* Action buttons */}
                        <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
                            <Link
                                href="/admin/modules"
                                className="px-5 py-2.5 rounded-xl border border-slate-200 text-slate-500 hover:text-slate-700 hover:bg-slate-50 text-sm font-bold active:scale-98 transition-all"
                            >
                                Batalkan
                            </Link>
                            <button
                                type="submit"
                                disabled={processing}
                                className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-98 transition-all rounded-xl shadow-md shadow-violet-100 disabled:opacity-50"
                            >
                                <Save className="w-4 h-4" />
                                {isEdit ? 'Perbarui Modul' : 'Simpan Modul'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </AdminLayout>
    );
}
