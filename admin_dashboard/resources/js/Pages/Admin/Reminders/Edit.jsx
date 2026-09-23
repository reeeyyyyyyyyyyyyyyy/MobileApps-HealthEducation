import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save } from 'lucide-react';

export default function Edit({ template }) {
  const { data, setData, put, processing, errors } = useForm({
    title: template.title || '',
    description: template.description || '',
    default_time: template.default_time || '08:00',
    icon_name: template.icon_name || 'water_drop_rounded',
    is_active: template.is_active ?? true,
    sort_order: template.sort_order ?? 1,
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    put(`/admin/reminders/${template.id}`);
  };

  return (
    <AdminLayout title={`Edit Pengingat - ${template.title}`}>
      <Head title={`Edit Pengingat - ${template.title}`} />

      <div className="max-w-2xl mx-auto space-y-6">
        <div className="flex items-center gap-3">
          <Link
            href="/admin/reminders"
            className="p-2 bg-white rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h2 className="text-xl font-bold text-slate-800">Edit Template Pengingat</h2>
            <p className="text-xs text-slate-400">ID: {template.id}</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Judul Pengingat *
            </label>
            <input
              type="text"
              value={data.title}
              onChange={(e) => setData('title', e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.title && <p className="text-xs text-rose-500 mt-1">{errors.title}</p>}
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Deskripsi Motivasi
            </label>
            <textarea
              rows={3}
              value={data.description}
              onChange={(e) => setData('description', e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Waktu Default (WIB) *
              </label>
              <input
                type="time"
                value={data.default_time}
                onChange={(e) => setData('default_time', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
              />
              {errors.default_time && <p className="text-xs text-rose-500 mt-1">{errors.default_time}</p>}
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Icon Identifier
              </label>
              <select
                value={data.icon_name}
                onChange={(e) => setData('icon_name', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="water_drop_rounded">Water Drop (Minum)</option>
                <option value="wc_rounded">Toilet / WC (BAK)</option>
                <option value="clean_hands_rounded">Clean Hands (Kebersihan)</option>
                <option value="fitness_center_rounded">Fitness (Olahraga)</option>
                <option value="nights_stay_rounded">Night (Malam Hari)</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Status
              </label>
              <select
                value={data.is_active ? '1' : '0'}
                onChange={(e) => setData('is_active', e.target.value === '1')}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="1">Aktif</option>
                <option value="0">Non-Aktif</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Nomor Urutan
              </label>
              <input
                type="number"
                value={data.sort_order}
                onChange={(e) => setData('sort_order', parseInt(e.target.value) || 1)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
              />
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 flex justify-end gap-2">
            <Link
              href="/admin/reminders"
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
              Simpan Perubahan
            </button>
          </div>
        </form>
      </div>
    </AdminLayout>
  );
}
