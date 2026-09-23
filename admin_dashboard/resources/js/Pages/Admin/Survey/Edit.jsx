import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save } from 'lucide-react';

export default function Edit({ instrument }) {
  const { data, setData, put, processing, errors } = useForm({
    type: instrument.type || 'pretest',
    variable: instrument.variable || 'pengetahuan',
    question_text: instrument.question_text || '',
    question_order: instrument.question_order ?? 1,
    is_active: instrument.is_active ?? true,
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    put(`/admin/survey/${instrument.id}`);
  };

  return (
    <AdminLayout title="Edit Soal Kuesioner">
      <Head title="Edit Soal Kuesioner - UtiCare" />

      <div className="max-w-2xl mx-auto space-y-6">
        <div className="flex items-center gap-3">
          <Link
            href={`/admin/survey?type=${data.type}`}
            className="p-2 bg-white rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h2 className="text-xl font-bold text-slate-800">Edit Soal Kuesioner</h2>
            <p className="text-xs text-slate-400">ID: {instrument.id}</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Tipe Kuesioner *
              </label>
              <select
                value={data.type}
                onChange={(e) => setData('type', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="pretest">Pre-Test (Sebelum Intervensi)</option>
                <option value="posttest">Post-Test (Setelah 7 Hari Intervensi)</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Domain / Variabel *
              </label>
              <select
                value={data.variable}
                onChange={(e) => setData('variable', e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-700"
              >
                <option value="pengetahuan">Pengetahuan (Knowledge)</option>
                <option value="sikap">Sikap (Attitude)</option>
                <option value="perilaku">Perilaku (Behavior)</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Pernyataan / Pertanyaan Instrumen *
            </label>
            <textarea
              rows={4}
              value={data.question_text}
              onChange={(e) => setData('question_text', e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.question_text && <p className="text-xs text-rose-500 mt-1">{errors.question_text}</p>}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Nomor Urutan
              </label>
              <input
                type="number"
                value={data.question_order}
                onChange={(e) => setData('question_order', parseInt(e.target.value) || 1)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
              />
            </div>

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
          </div>

          <div className="pt-4 border-t border-slate-100 flex justify-end gap-2">
            <Link
              href={`/admin/survey?type=${data.type}`}
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
