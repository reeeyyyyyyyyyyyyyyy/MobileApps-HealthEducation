import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save } from 'lucide-react';

export default function Create() {
  const { data, setData, post, processing, errors } = useForm({
    title: '',
    category: 'pengetahuan_isk',
    hbm_component: 'perceived_susceptibility',
    content: '',
    video_url: '',
    thumbnail_url: '',
    published: 1,
    sort_order: 1,
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    post('/admin/education');
  };

  return (
    <AdminLayout title="Tambah Materi Edukasi ISK">
      <Head title="Tambah Materi Edukasi - UtiCare" />

      <div className="max-w-3xl mx-auto space-y-6">
        <div className="flex items-center gap-3">
          <Link
            href="/admin/education"
            className="p-2 bg-white rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h2 className="text-xl font-bold text-slate-800">Tambah Materi Baru</h2>
            <p className="text-xs text-slate-400">Format materi edukasi pencegahan ISK berbasis Health Belief Model</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-5">
          {/* Judul */}
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Judul Materi *
            </label>
            <input
              type="text"
              value={data.title}
              onChange={(e) => setData('title', e.target.value)}
              placeholder="Contoh: Apa itu Infeksi Saluran Kemih (ISK)?"
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.title && <p className="text-xs text-rose-500 mt-1">{errors.title}</p>}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Kategori */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Kategori *
              </label>
              <select
                value={data.category}
                onChange={(e) => setData('category', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="pengetahuan_isk">Tentang ISK</option>
                <option value="pencegahan">Pencegahan</option>
                <option value="kebersihan">Kebersihan</option>
                <option value="fakta_mitos">Fakta & Mitos</option>
              </select>
              {errors.category && <p className="text-xs text-rose-500 mt-1">{errors.category}</p>}
            </div>

            {/* Komponen HBM */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Komponen Health Belief Model *
              </label>
              <select
                value={data.hbm_component}
                onChange={(e) => setData('hbm_component', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="perceived_susceptibility">Perceived Susceptibility (Kerentanan)</option>
                <option value="perceived_severity">Perceived Severity (Keparahan)</option>
                <option value="perceived_benefits">Perceived Benefits (Manfaat)</option>
                <option value="perceived_barriers">Perceived Barriers (Hambatan)</option>
                <option value="cues_to_action">Cues to Action (Pemicu Aksi)</option>
                <option value="self_efficacy">Self-Efficacy (Efikasi Diri)</option>
              </select>
              {errors.hbm_component && <p className="text-xs text-rose-500 mt-1">{errors.hbm_component}</p>}
            </div>
          </div>

          {/* Konten */}
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Konten Materi Edukasi *
            </label>
            <textarea
              rows={8}
              value={data.content}
              onChange={(e) => setData('content', e.target.value)}
              placeholder="Tuliskan materi edukasi secara lengkap dan mudah dipahami oleh remaja putri..."
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.content && <p className="text-xs text-rose-500 mt-1">{errors.content}</p>}
          </div>

          {/* Video URL */}
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              URL Video YouTube (Opsional)
            </label>
            <input
              type="url"
              value={data.video_url}
              onChange={(e) => setData('video_url', e.target.value)}
              placeholder="https://www.youtube.com/watch?v=..."
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.video_url && <p className="text-xs text-rose-500 mt-1">{errors.video_url}</p>}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Status Publish */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Status Publikasi
              </label>
              <select
                value={data.published}
                onChange={(e) => setData('published', parseInt(e.target.value))}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value={1}>Langsung Terbitkan (Published)</option>
                <option value={0}>Simpan sebagai Draft</option>
              </select>
            </div>

            {/* Urutan */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Nomor Urutan Tampil
              </label>
              <input
                type="number"
                value={data.sort_order}
                onChange={(e) => setData('sort_order', parseInt(e.target.value) || 1)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
              />
            </div>
          </div>

          {/* Submit */}
          <div className="pt-4 border-t border-slate-100 flex justify-end gap-2">
            <Link
              href="/admin/education"
              className="px-4 py-2.5 text-xs font-semibold text-slate-500 hover:bg-slate-100 rounded-xl transition-colors"
            >
              Batal
            </Link>
            <button
              type="submit"
              disabled={processing}
              className="inline-flex items-center gap-2 px-5 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              Simpan Materi
            </button>
          </div>
        </form>
      </div>
    </AdminLayout>
  );
}
