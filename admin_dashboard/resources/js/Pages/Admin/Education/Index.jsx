import React, { useState } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Plus,
  Search,
  BookOpen,
  Eye,
  Edit,
  Trash2,
  CheckCircle,
  XCircle,
  Video,
} from 'lucide-react';

export default function Index({ materials, filters }) {
  const [search, setSearch] = useState(filters.search || '');
  const [category, setCategory] = useState(filters.category || '');
  const [hbm, setHbm] = useState(filters.hbm || '');

  const handleFilter = (e) => {
    e.preventDefault();
    router.get('/admin/education', { search, category, hbm }, { preserveState: true });
  };

  const handleTogglePublish = (id) => {
    router.put(`/admin/education/${id}/publish`, {}, { preserveScroll: true });
  };

  const handleDelete = (id, title) => {
    if (confirm(`Yakin ingin menghapus materi "${title}"?`)) {
      router.delete(`/admin/education/${id}`);
    }
  };

  const hbmLabels = {
    perceived_susceptibility: { label: 'Kerentanan', color: 'bg-rose-100 text-rose-700' },
    perceived_severity: { label: 'Keparahan', color: 'bg-amber-100 text-amber-700' },
    perceived_benefits: { label: 'Manfaat', color: 'bg-emerald-100 text-emerald-700' },
    perceived_barriers: { label: 'Hambatan', color: 'bg-purple-100 text-purple-700' },
    cues_to_action: { label: 'Pemicu', color: 'bg-blue-100 text-blue-700' },
    self_efficacy: { label: 'Efikasi Diri', color: 'bg-cyan-100 text-cyan-700' },
  };

  return (
    <AdminLayout title="Materi Edukasi ISK (Health Belief Model)">
      <Head title="Materi Edukasi ISK - UtiCare" />

      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Materi Edukasi ({materials.total})</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Kelola materi edukasi pencegahan ISK terpetakan ke 6 komponen Health Belief Model
            </p>
          </div>
          <Link
            href="/admin/education/create"
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Tambah Materi Baru
          </Link>
        </div>

        {/* Filter */}
        <form onSubmit={handleFilter} className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-wrap gap-3">
          <div className="flex-1 min-w-[200px] relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Cari materi..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
          </div>

          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
          >
            <option value="">Semua Kategori</option>
            <option value="pengetahuan_isk">Tentang ISK</option>
            <option value="pencegahan">Pencegahan</option>
            <option value="kebersihan">Kebersihan</option>
            <option value="fakta_mitos">Fakta & Mitos</option>
          </select>

          <select
            value={hbm}
            onChange={(e) => setHbm(e.target.value)}
            className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
          >
            <option value="">Semua Komponen HBM</option>
            <option value="perceived_susceptibility">Kerentanan (Susceptibility)</option>
            <option value="perceived_severity">Keparahan (Severity)</option>
            <option value="perceived_benefits">Manfaat (Benefits)</option>
            <option value="perceived_barriers">Hambatan (Barriers)</option>
            <option value="cues_to_action">Pemicu (Cues to Action)</option>
            <option value="self_efficacy">Efikasi Diri (Self-Efficacy)</option>
          </select>

          <button
            type="submit"
            className="px-4 py-2 text-xs font-bold bg-slate-800 hover:bg-slate-900 text-white rounded-xl"
          >
            Filter
          </button>
        </form>

        {/* Materials List */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {materials.data.map((m) => {
            const hbmBadge = hbmLabels[m.hbm_component] || { label: 'Umum', color: 'bg-slate-100 text-slate-600' };

            return (
              <div key={m.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between gap-2 mb-3">
                    <span className={`text-[11px] font-extrabold px-2.5 py-0.5 rounded-full ${hbmBadge.color}`}>
                      {hbmBadge.label}
                    </span>
                    <button
                      onClick={() => handleTogglePublish(m.id)}
                      className={`text-xs font-bold px-2.5 py-0.5 rounded-full flex items-center gap-1 ${
                        m.published === 1
                          ? 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'
                          : 'bg-slate-100 text-slate-500 hover:bg-slate-200'
                      }`}
                    >
                      {m.published === 1 ? <CheckCircle className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                      {m.published === 1 ? 'Published' : 'Draft'}
                    </button>
                  </div>

                  <h3 className="font-bold text-slate-800 text-base leading-snug line-clamp-2">{m.title}</h3>
                  <p className="text-xs text-slate-500 mt-2 line-clamp-3 leading-relaxed">{m.content}</p>
                </div>

                <div className="pt-4 mt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-400">
                  <div className="flex items-center gap-3">
                    <span className="flex items-center gap-1">
                      <Eye className="w-3.5 h-3.5" /> {m.view_count || 0}
                    </span>
                    {m.video_url && (
                      <span className="flex items-center gap-1 text-violet-600 font-semibold">
                        <Video className="w-3.5 h-3.5" /> Video
                      </span>
                    )}
                  </div>

                  <div className="flex items-center gap-1">
                    <Link
                      href={`/admin/education/${m.id}/edit`}
                      className="p-1.5 rounded-lg text-slate-500 hover:text-violet-600 hover:bg-violet-50"
                    >
                      <Edit className="w-4 h-4" />
                    </Link>
                    <button
                      onClick={() => handleDelete(m.id, m.title)}
                      className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </AdminLayout>
  );
}
