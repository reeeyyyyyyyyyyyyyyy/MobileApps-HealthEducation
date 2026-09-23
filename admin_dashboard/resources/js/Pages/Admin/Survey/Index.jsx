import React, { useState } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Plus,
  ClipboardCheck,
  Edit,
  Trash2,
  Filter,
} from 'lucide-react';

export default function Index({ instruments, currentType, currentVariable }) {
  const [type, setType] = useState(currentType || 'pretest');
  const [variable, setVariable] = useState(currentVariable || 'all');

  const handleSwitchType = (newType) => {
    setType(newType);
    router.get('/admin/survey', { type: newType, variable }, { preserveState: true });
  };

  const handleSwitchVariable = (newVar) => {
    setVariable(newVar);
    router.get('/admin/survey', { type, variable: newVar }, { preserveState: true });
  };

  const handleDelete = (id) => {
    if (confirm('Yakin ingin menghapus instrumen pertanyaan kuesioner ini?')) {
      router.delete(`/admin/survey/${id}`);
    }
  };

  const varColors = {
    pengetahuan: 'bg-blue-100 text-blue-700 border-blue-200',
    sikap: 'bg-emerald-100 text-emerald-700 border-emerald-200',
    perilaku: 'bg-purple-100 text-purple-700 border-purple-200',
  };

  return (
    <AdminLayout title="Instrumen Kuesioner Penelitian">
      <Head title="Instrumen Kuesioner - UtiCare" />

      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Instrumen Kuesioner Penelitian</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Kelola pertanyaan Skala Likert untuk Pre-test dan Post-test (Pengetahuan, Sikap, Perilaku)
            </p>
          </div>
          <Link
            href={`/admin/survey/create?type=${type}&variable=${variable !== 'all' ? variable : 'pengetahuan'}`}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Tambah Soal Kuesioner
          </Link>
        </div>

        {/* Type Tabs (Pre-test vs Post-test) */}
        <div className="flex bg-slate-200/70 p-1 rounded-xl max-w-sm">
          <button
            onClick={() => handleSwitchType('pretest')}
            className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${
              type === 'pretest' ? 'bg-white text-violet-700 shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Pre-Test Instrumen
          </button>
          <button
            onClick={() => handleSwitchType('posttest')}
            className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${
              type === 'posttest' ? 'bg-white text-violet-700 shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Post-Test Instrumen
          </button>
        </div>

        {/* Variable Filter Buttons */}
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => handleSwitchVariable('all')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-colors ${
              variable === 'all'
                ? 'bg-slate-800 text-white'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            Semua Domain ({instruments.length})
          </button>
          <button
            onClick={() => handleSwitchVariable('pengetahuan')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-colors ${
              variable === 'pengetahuan'
                ? 'bg-blue-600 text-white'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            Pengetahuan
          </button>
          <button
            onClick={() => handleSwitchVariable('sikap')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-colors ${
              variable === 'sikap'
                ? 'bg-emerald-600 text-white'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            Sikap
          </button>
          <button
            onClick={() => handleSwitchVariable('perilaku')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-colors ${
              variable === 'perilaku'
                ? 'bg-purple-600 text-white'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            Perilaku
          </button>
        </div>

        {/* Questions list */}
        <div className="space-y-3">
          {instruments.length === 0 ? (
            <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-400 text-sm">
              Belum ada instrumen pada kategori ini.
            </div>
          ) : (
            instruments.map((item, idx) => (
              <div key={item.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-3">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-start gap-3">
                    <span className="w-7 h-7 rounded-lg bg-violet-50 text-violet-700 font-bold text-xs flex items-center justify-center shrink-0">
                      {idx + 1}
                    </span>
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <span
                          className={`text-[10px] font-extrabold uppercase px-2 py-0.5 rounded-full border ${
                            varColors[item.variable] || 'bg-slate-100 text-slate-600'
                          }`}
                        >
                          {item.variable}
                        </span>
                        <span className="text-xs text-slate-400">Urutan: #{item.question_order}</span>
                      </div>
                      <h3 className="font-bold text-slate-800 text-base">{item.question_text}</h3>
                    </div>
                  </div>

                  <div className="flex items-center gap-1 shrink-0">
                    <Link
                      href={`/admin/survey/${item.id}/edit`}
                      className="p-2 rounded-lg text-slate-500 hover:text-violet-600 hover:bg-violet-50"
                    >
                      <Edit className="w-4 h-4" />
                    </Link>
                    <button
                      onClick={() => handleDelete(item.id)}
                      className="p-2 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {/* Options display */}
                <div className="pl-10 flex flex-wrap gap-2">
                  {item.options?.map((opt) => (
                    <span
                      key={opt.id}
                      className="px-2.5 py-1 rounded-lg bg-slate-50 border border-slate-200 text-xs font-semibold text-slate-600 flex items-center gap-1.5"
                    >
                      <span>{opt.option_text}</span>
                      <span className="w-4 h-4 rounded-full bg-violet-100 text-violet-700 font-bold text-[10px] flex items-center justify-center">
                        {opt.score}
                      </span>
                    </span>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
