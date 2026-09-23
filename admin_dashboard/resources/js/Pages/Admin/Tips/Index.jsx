import React, { useState } from 'react';
import { Head, useForm, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Plus,
  Sparkles,
  Edit,
  Trash2,
  X,
  Save,
  CheckCircle,
  XCircle,
} from 'lucide-react';

export default function Index({ tips }) {
  const [modalOpen, setModalOpen] = useState(false);
  const [editingTip, setEditingTip] = useState(null);
  const [isGenerating, setIsGenerating] = useState(false);

  const { data, setData, post, put, reset, errors, processing } = useForm({
    title: '',
    content: '',
    category: 'kebiasaan',
    is_active: true,
  });

  const openCreateModal = () => {
    setEditingTip(null);
    reset();
    setData({
      title: '',
      content: '',
      category: 'kebiasaan',
      is_active: true,
    });
    setModalOpen(true);
  };

  const openEditModal = (tip) => {
    setEditingTip(tip);
    setData({
      title: tip.title,
      content: tip.content,
      category: tip.category,
      is_active: tip.is_active,
    });
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingTip(null);
    reset();
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (editingTip) {
      put(`/admin/tips/${editingTip.id}`, {
        onSuccess: () => closeModal(),
      });
    } else {
      post('/admin/tips', {
        onSuccess: () => closeModal(),
      });
    }
  };

  const handleDelete = (id, title) => {
    if (confirm(`Hapus tips "${title}"?`)) {
      router.delete(`/admin/tips/${id}`);
    }
  };

  const handleGenerateAI = () => {
    setIsGenerating(true);
    router.post(
      '/admin/tips/generate',
      {},
      {
        onFinish: () => setIsGenerating(false),
      }
    );
  };

  return (
    <AdminLayout title="Tips Harian Pencegahan ISK">
      <Head title="Tips Harian - UtiCare" />

      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Tips Edukasi Harian ({tips.total})</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Tips ringkas yang muncul di beranda aplikasi mobile setiap hari
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleGenerateAI}
              disabled={isGenerating}
              className="inline-flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-700 hover:to-indigo-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-all disabled:opacity-50"
            >
              <Sparkles className={`w-4 h-4 ${isGenerating ? 'animate-spin' : ''}`} />
              {isGenerating ? 'Sedang Membuat...' : 'Generate Tips AI'}
            </button>

            <button
              onClick={openCreateModal}
              className="inline-flex items-center gap-2 px-4 py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-xl font-bold text-sm transition-colors"
            >
              <Plus className="w-4 h-4" />
              Tambah Manual
            </button>
          </div>
        </div>

        {/* Tips Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {tips.data.map((t) => (
            <div key={t.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between gap-2 mb-2">
                  <span className="text-[10px] font-extrabold uppercase px-2.5 py-0.5 rounded-full bg-violet-100 text-violet-700">
                    {t.category}
                  </span>
                  <span
                    className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                      t.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500'
                    }`}
                  >
                    {t.is_active ? 'Aktif' : 'Non-Aktif'}
                  </span>
                </div>

                <h3 className="font-bold text-slate-800 text-base">{t.title}</h3>
                <p className="text-xs text-slate-600 mt-2 leading-relaxed">{t.content}</p>
              </div>

              <div className="pt-4 mt-4 border-t border-slate-100 flex items-center justify-between">
                <span className="text-[11px] text-slate-400">
                  {t.created_at ? new Date(t.created_at).toLocaleDateString('id-ID') : '-'}
                </span>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => openEditModal(t)}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-violet-600 hover:bg-violet-50"
                  >
                    <Edit className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(t.id, t.title)}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Modal Create/Edit */}
        {modalOpen && (
          <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-2xl border border-slate-200 p-6 w-full max-w-lg shadow-xl space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="font-bold text-slate-800 text-lg">
                  {editingTip ? 'Edit Tips Harian' : 'Tambah Tips Harian Baru'}
                </h3>
                <button onClick={closeModal} className="p-1 text-slate-400 hover:text-slate-600">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Judul Tips *
                  </label>
                  <input
                    type="text"
                    value={data.title}
                    onChange={(e) => setData('title', e.target.value)}
                    placeholder="Contoh: Basuh dari Depan ke Belakang"
                    className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
                  />
                  {errors.title && <p className="text-xs text-rose-500 mt-1">{errors.title}</p>}
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Kategori *
                  </label>
                  <select
                    value={data.category}
                    onChange={(e) => setData('category', e.target.value)}
                    className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
                  >
                    <option value="hidrasi">Hidrasi & Air Putih</option>
                    <option value="kebersihan">Kebersihan Genital</option>
                    <option value="kebiasaan">Kebiasaan BAK</option>
                    <option value="aktivitas">Aktivitas Fisik</option>
                    <option value="motivasi">Motivasi Sehat</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Isi Pesan Tips *
                  </label>
                  <textarea
                    rows={4}
                    value={data.content}
                    onChange={(e) => setData('content', e.target.value)}
                    placeholder="Tuliskan 1-2 kalimat tips praktis pencegahan ISK..."
                    className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
                  />
                  {errors.content && <p className="text-xs text-rose-500 mt-1">{errors.content}</p>}
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Status
                  </label>
                  <select
                    value={data.is_active ? '1' : '0'}
                    onChange={(e) => setData('is_active', e.target.value === '1')}
                    className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
                  >
                    <option value="1">Aktif</option>
                    <option value="0">Non-Aktif</option>
                  </select>
                </div>

                <div className="pt-3 border-t border-slate-100 flex justify-end gap-2">
                  <button
                    type="button"
                    onClick={closeModal}
                    className="px-4 py-2 text-xs font-semibold text-slate-500 hover:bg-slate-100 rounded-xl"
                  >
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={processing}
                    className="inline-flex items-center gap-2 px-5 py-2 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 disabled:opacity-50"
                  >
                    <Save className="w-4 h-4" />
                    Simpan
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}