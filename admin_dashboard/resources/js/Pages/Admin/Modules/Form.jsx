import React, { useState } from 'react';
import { Head, Link, useForm, usePage } from '@inertiajs/react';
import { useToast } from '@/hooks/useToast';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save, Video, AlertCircle, Upload } from 'lucide-react';
import IconPicker from '@/Components/UI/IconPicker';
import RichTextEditor from '@/Components/UI/RichTextEditor';

export default function Form({ module, categories, learningPaths, assignedPathId }) {
    const isEdit = !!module;
    const { error } = useToast();
    const [showConfirm, setShowConfirm] = useState(false);
    const { props } = usePage();
    const uploadResult = props.flash?.upload_result;

    const { data, setData, post, put, processing, errors } = useForm({
        title: module?.title || uploadResult?.title || '',
        category: module?.category || uploadResult?.category || 'Pengetahuan',
        duration: module?.duration || uploadResult?.duration || '',
        icon_name: module?.icon_name || 'psychology_rounded',
        video_url: module?.video_url || '',
        content: module?.content || uploadResult?.content || '',
        published: module ? !!module.published : true,
        scheduled_at: module?.scheduled_at || '',
        path_id: assignedPathId || 'none',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        setShowConfirm(true);
    };

    const confirmSubmit = () => {
        setShowConfirm(false);
        if (isEdit) {
            put(`/admin/modules/${module.id}`, {
                onError: (err) => error(err.message || 'Gagal memperbarui modul'),
            });
        } else {
            // Simpan questions ke localStorage sebelum redirect
            if (uploadResult?.questions?.length > 0) {
                localStorage.setItem('pending_quiz_questions', JSON.stringify(uploadResult.questions));
            }
            post('/admin/modules', {
                onError: (err) => error(err.message || 'Gagal membuat modul'),
            });
        }
    };

    return (
        <AdminLayout title={isEdit ? 'Edit Modul Edukasi' : 'Tambah Modul Edukasi'} titleParent="Modul Edukasi">
            <Head title={`${isEdit ? 'Edit' : 'Tambah'} Modul Edukasi — BloomFem`} />

            <div className="max-w-4xl">
                <Link href="/admin/modules" className="inline-flex items-center gap-2 text-xs font-bold text-slate-500 hover:text-slate-800 transition-colors mb-6">
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Kembali ke Daftar Modul
                </Link>

                {uploadResult && (
                    <div className="mb-6 p-4 bg-teal-50 border border-teal-200 rounded-2xl flex items-start gap-3">
                        <Upload className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
                        <div>
                            <p className="text-sm font-bold text-teal-800">Hasil Upload File</p>
                            <p className="text-xs text-teal-600 mt-0.5">Data dari file telah diisikan otomatis. Silakan review dan sesuaikan sebelum menyimpan.</p>
                            {uploadResult.questions?.length > 0 && (
                                <p className="text-xs font-bold text-teal-700 mt-1.5">{uploadResult.questions.length} soal kuis terdeteksi dari file.</p>
                            )}
                        </div>
                    </div>
                )}

                <div className="bg-white border border-sand-200/80 rounded-2xl p-6 shadow-sm">
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
                                className={`block w-full px-4 py-3 rounded-xl border text-sm font-semibold transition-all ${
                                    errors.title ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
                                }`}
                                required
                            />
                            {errors.title && (
                                <p className="text-xs font-bold text-brick-500 mt-2">{errors.title}</p>
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
                                    className={`block w-full px-4 py-3 rounded-xl border text-sm font-semibold transition-all cursor-pointer bg-white ${
                                        errors.category ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
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
                                    <p className="text-xs font-bold text-brick-500 mt-2">{errors.category}</p>
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
                                    className={`block w-full px-4 py-3 rounded-xl border text-sm font-semibold transition-all ${
                                        errors.duration ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
                                    }`}
                                    required
                                />
                                {errors.duration && (
                                    <p className="text-xs font-bold text-brick-500 mt-2">{errors.duration}</p>
                                )}
                            </div>
                        </div>

                        {/* Icon Picker Visual */}
                        <div>
                            <IconPicker
                                value={data.icon_name}
                                onChange={(val) => setData('icon_name', val)}
                                label="Ikon Modul"
                            />
                            <p className="text-xs text-slate-400 mt-1">Ikon akan tampil di kartu modul pada aplikasi Flutter & dashboard.</p>
                        </div>

                        {/* Video URL */}
                        <div className="relative">
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2 flex items-center gap-1.5">
                                <Video className="w-4 h-4" />
                                Link Video YouTube (Opsional)
                            </label>
                            <input
                                type="url"
                                value={data.video_url}
                                onChange={(e) => setData('video_url', e.target.value)}
                                placeholder="Contoh: https://youtube.com/watch?v=..."
                                className={`block w-full px-4 py-3 rounded-xl border text-sm font-semibold transition-all ${
                                    errors.video_url ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
                                }`}
                            />
                            {errors.video_url && (
                                <p className="text-xs font-bold text-brick-500 mt-2">{errors.video_url}</p>
                            )}
                        </div>

                        {/* Learning Path (Opsional) */}
                        {learningPaths?.length > 0 && (
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Learning Path (Opsional)
                                </label>
                                <select
                                    value={data.path_id || 'none'}
                                    onChange={(e) => setData('path_id', e.target.value)}
                                    className="block w-full px-4 py-3 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all cursor-pointer bg-white"
                                >
                                    <option value="none">Tidak ada (modul mandiri)</option>
                                    {learningPaths.map(p => (
                                        <option key={p.id} value={p.id}>{p.title}</option>
                                    ))}
                                </select>
                            </div>
                        )}

                        {/* Scheduling */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Status Publikasi</label>
                                <div className="flex items-center gap-4 px-4 py-3 rounded-xl border border-sand-200 bg-white">
                                    <label className="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="publish_status" checked={data.published && !data.scheduled_at} onChange={() => { setData('published', true); setData('scheduled_at', ''); }} className="text-teal-600" />
                                        <span className="text-sm font-semibold text-slate-700">Posting sekarang</span>
                                    </label>
                                    <label className="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="publish_status" checked={!data.published && !data.scheduled_at} onChange={() => { setData('published', false); setData('scheduled_at', ''); }} className="text-teal-600" />
                                        <span className="text-sm font-semibold text-slate-700">Draft</span>
                                    </label>
                                    <label className="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="publish_status" checked={!!data.scheduled_at} onChange={() => { const now = new Date(); setData('published', false); setData('scheduled_at', now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0')+'-'+String(now.getDate()).padStart(2,'0')+'T'+String(now.getHours()).padStart(2,'0')+':'+String(now.getMinutes()).padStart(2,'0')); }} className="text-teal-600" />
                                        <span className="text-sm font-semibold text-slate-700">Jadwalkan</span>
                                    </label>
                                </div>
                            </div>
                            {data.scheduled_at !== '' && (
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Tanggal Rilis</label>
                                    <input type="datetime-local" value={data.scheduled_at} onChange={(e) => setData('scheduled_at', e.target.value)} className="w-full px-4 py-3 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" />
                                </div>
                            )}
                            {!data.published && !data.scheduled_at && (
                                <div className="flex items-center text-xs text-teal-600 font-semibold">
                                    <span>Modul akan disimpan sebagai draft. Kamu bisa publikasikan nanti dari halaman daftar modul.</span>
                                </div>
                            )}
                        </div>

                        {/* Rich Text Editor */}
                        <div>
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                Konten Edukasi Lengkap
                            </label>
                            <RichTextEditor
                                value={data.content}
                                onChange={(val) => setData('content', val)}
                                label="Konten Edukasi"
                                placeholder="Tulis konten edukasi di sini... (heading, bold, italic, list, gambar, link, blockquote, dll)"
                            />
                            {errors.content && (
                                <p className="text-xs font-bold text-brick-500 mt-2">{errors.content}</p>
                            )}
                        </div>

                        {/* Action buttons */}
                        <div className="flex justify-end gap-3 pt-4 border-t border-sand-100">
                            <Link
                                href="/admin/modules"
                                className="px-5 py-2.5 rounded-xl border border-sand-200 text-slate-500 hover:text-slate-700 hover:bg-sand-50 text-sm font-bold active:scale-98 transition-all"
                            >
                                Batalkan
                            </Link>
                            <button
                                type="submit"
                                disabled={processing}
                                className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-98 transition-all rounded-xl shadow-md shadow-teal-200 disabled:opacity-50"
                            >
                                <Save className="w-4 h-4" />
                                {isEdit ? 'Perbarui Modul' : 'Simpan Modul'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            {/* Confirmation Modal */}
            {showConfirm && (
                <>
                    <div className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40" onClick={() => setShowConfirm(false)} />
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={() => setShowConfirm(false)}>
                        <div className="bg-white rounded-2xl shadow-xl border border-sand-200 p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
                            <div className="flex items-start gap-4 mb-5">
                                <div className="w-12 h-12 rounded-xl bg-teal-50 flex items-center justify-center flex-shrink-0">
                                    <AlertCircle className="w-6 h-6 text-teal-600" />
                                </div>
                                <div>
                                    <h3 className="text-base font-extrabold text-slate-800">{isEdit ? 'Perbarui Modul?' : 'Simpan Modul?'}</h3>
                                    <p className="text-sm text-slate-500 mt-1">
                                        {isEdit ? 'Perubahan akan langsung tampil di aplikasi BloomFem.' : 'Modul akan langsung ditampilkan di aplikasi BloomFem untuk pengguna.'}
                                    </p>
                                </div>
                            </div>
                            <div className="flex justify-end gap-3">
                                <button type="button" onClick={() => setShowConfirm(false)} className="px-5 py-2.5 rounded-xl border border-sand-200 text-slate-500 hover:text-slate-700 hover:bg-sand-50 text-sm font-bold active:scale-98 transition-all">Batal</button>
                                <button type="button" onClick={confirmSubmit} className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-98 transition-all rounded-xl shadow-md shadow-teal-200">
                                    <Save className="w-4 h-4" /> Ya, Simpan
                                </button>
                            </div>
                        </div>
                    </div>
                </>
            )}
        </AdminLayout>
    );
}