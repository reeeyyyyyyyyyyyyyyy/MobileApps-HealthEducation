import React, { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Plus, Trash2, Save } from 'lucide-react';

export default function Edit({ question }) {
  const { data, setData, put, processing, errors } = useForm({
    question_text: question.question_text || '',
    question_order: question.question_order ?? 1,
    is_active: question.is_active ?? true,
    options: question.options && question.options.length > 0 ? question.options.map((o) => ({
      option_text: o.option_text,
      score: o.score,
      option_order: o.option_order,
    })) : [
      { option_text: 'Tidak pernah', score: 0, option_order: 1 },
      { option_text: 'Kadang-kadang (1-2x)', score: 1, option_order: 2 },
      { option_text: 'Sering (>3x)', score: 2, option_order: 3 },
    ],
  });

  const addOption = () => {
    setData('options', [
      ...data.options,
      { option_text: '', score: 0, option_order: data.options.length + 1 },
    ]);
  };

  const removeOption = (idx) => {
    if (data.options.length <= 2) {
      alert('Minimal harus ada 2 opsi jawaban.');
      return;
    }
    const updated = data.options.filter((_, i) => i !== idx);
    setData('options', updated);
  };

  const updateOption = (idx, field, val) => {
    const updated = [...data.options];
    updated[idx][field] = val;
    setData('options', updated);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    put(`/admin/check-risk/${question.id}`);
  };

  return (
    <AdminLayout title="Edit Pertanyaan Check Risk">
      <Head title="Edit Pertanyaan Check Risk - UtiCare" />

      <div className="max-w-3xl mx-auto space-y-6">
        <div className="flex items-center gap-3">
          <Link
            href="/admin/check-risk"
            className="p-2 bg-white rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h2 className="text-xl font-bold text-slate-800">Edit Pertanyaan Check Risk</h2>
            <p className="text-xs text-slate-400">ID Pertanyaan: {question.id}</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-5">
          {/* Teks Pertanyaan */}
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Pertanyaan Skrining ISK *
            </label>
            <textarea
              rows={3}
              value={data.question_text}
              onChange={(e) => setData('question_text', e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
            />
            {errors.question_text && <p className="text-xs text-rose-500 mt-1">{errors.question_text}</p>}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Urutan Pertanyaan
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
                Status Pertanyaan
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

          {/* Opsi Jawaban */}
          <div className="space-y-3 pt-3 border-t border-slate-100">
            <div className="flex items-center justify-between">
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                Opsi Jawaban & Skor *
              </label>
              <button
                type="button"
                onClick={addOption}
                className="inline-flex items-center gap-1 text-xs font-bold text-violet-600 hover:text-violet-700"
              >
                <Plus className="w-3.5 h-3.5" /> Tambah Opsi
              </button>
            </div>

            <div className="space-y-2">
              {data.options.map((opt, idx) => (
                <div key={idx} className="flex items-center gap-3 bg-slate-50 p-3 rounded-xl border border-slate-200">
                  <div className="flex-1">
                    <input
                      type="text"
                      placeholder={`Teks Opsi ${idx + 1}`}
                      value={opt.option_text}
                      onChange={(e) => updateOption(idx, 'option_text', e.target.value)}
                      className="w-full px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                    />
                  </div>

                  <div className="w-24">
                    <input
                      type="number"
                      placeholder="Skor"
                      min="0"
                      max="10"
                      value={opt.score}
                      onChange={(e) => updateOption(idx, 'score', parseInt(e.target.value) || 0)}
                      className="w-full px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-sm text-center focus:outline-none focus:ring-2 focus:ring-violet-500 font-bold"
                    />
                  </div>

                  <button
                    type="button"
                    onClick={() => removeOption(idx)}
                    className="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Submit */}
          <div className="pt-4 border-t border-slate-100 flex justify-end gap-2">
            <Link
              href="/admin/check-risk"
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
