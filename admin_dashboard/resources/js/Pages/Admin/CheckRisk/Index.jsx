import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Plus,
  ShieldAlert,
  Edit,
  Trash2,
  CheckCircle,
  XCircle,
  HelpCircle,
} from 'lucide-react';

export default function Index({ questions, recentResults }) {
  const handleDelete = (id) => {
    if (confirm('Yakin ingin menghapus pertanyaan ini beserta opsi jawabannya?')) {
      router.delete(`/admin/check-risk/${id}`);
    }
  };

  return (
    <AdminLayout title="Skrining Deteksi Dini Risiko ISK">
      <Head title="Skrining Check Risk - UtiCare" />

      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Pertanyaan Check Risk ({questions.length})</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Kelola pertanyaan deteksi dini risiko ISK dan pembobotan skor opsi jawaban
            </p>
          </div>
          <Link
            href="/admin/check-risk/create"
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Tambah Pertanyaan
          </Link>
        </div>

        {/* Questions list */}
        <div className="space-y-4">
          {questions.map((q, idx) => (
            <div key={q.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-4">
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-start gap-3">
                  <span className="w-7 h-7 rounded-lg bg-violet-100 text-violet-700 font-bold text-xs flex items-center justify-center shrink-0">
                    {idx + 1}
                  </span>
                  <div>
                    <h3 className="font-bold text-slate-800 text-base">{q.question_text}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <span
                        className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                          q.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500'
                        }`}
                      >
                        {q.is_active ? 'Aktif' : 'Non-Aktif'}
                      </span>
                      <span className="text-xs text-slate-400">Urutan: #{q.question_order}</span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-1 shrink-0">
                  <Link
                    href={`/admin/check-risk/${q.id}/edit`}
                    className="p-2 rounded-lg text-slate-500 hover:text-violet-600 hover:bg-violet-50 transition-colors"
                  >
                    <Edit className="w-4 h-4" />
                  </Link>
                  <button
                    onClick={() => handleDelete(q.id)}
                    className="p-2 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Options */}
              <div className="pl-10 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2">
                {q.options.map((opt) => (
                  <div key={opt.id} className="bg-slate-50 p-2.5 rounded-xl border border-slate-200/80 flex items-center justify-between text-xs">
                    <span className="text-slate-700 font-medium">{opt.option_text}</span>
                    <span
                      className={`font-black px-2 py-0.5 rounded-md ${
                        opt.score >= 2
                          ? 'bg-rose-100 text-rose-700'
                          : opt.score === 1
                          ? 'bg-amber-100 text-amber-700'
                          : 'bg-emerald-100 text-emerald-700'
                      }`}
                    >
                      {opt.score} poin
                    </span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
