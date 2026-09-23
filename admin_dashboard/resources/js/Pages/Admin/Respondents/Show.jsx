import React, { useState } from 'react';
import { Head, Link } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  ArrowLeft,
  User,
  School,
  Calendar,
  Phone,
  Droplets,
  ShieldCheck,
  Activity,
  Award,
  ClipboardCheck,
  AlertCircle,
  Clock,
} from 'lucide-react';

export default function Show({
  respondent,
  habits,
  risks,
  pretestResponses,
  posttestResponses,
}) {
  const [tab, setTab] = useState('overview');

  const pretestByVariable = {
    pengetahuan: pretestResponses.filter((r) => r.variable === 'pengetahuan'),
    sikap: pretestResponses.filter((r) => r.variable === 'sikap'),
    perilaku: pretestResponses.filter((r) => r.variable === 'perilaku'),
  };

  const posttestByVariable = {
    pengetahuan: posttestResponses.filter((r) => r.variable === 'pengetahuan'),
    sikap: posttestResponses.filter((r) => r.variable === 'sikap'),
    perilaku: posttestResponses.filter((r) => r.variable === 'perilaku'),
  };

  const totalPretestScore = pretestResponses.reduce((acc, r) => acc + (r.score || 0), 0);
  const totalPosttestScore = posttestResponses.reduce((acc, r) => acc + (r.score || 0), 0);

  return (
    <AdminLayout title={`Detail Responden - ${respondent.full_name || 'Responden'}`}>
      <Head title={`Detail Responden - ${respondent.full_name || 'Responden'}`} />

      <div className="space-y-6">
        {/* Back button & header */}
        <div className="flex items-center gap-3">
          <Link
            href="/admin/respondents"
            className="p-2 bg-white rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h2 className="text-xl font-bold text-slate-800">{respondent.full_name || 'Tanpa Nama'}</h2>
            <p className="text-xs text-slate-400">ID: {respondent.id}</p>
          </div>
        </div>

        {/* Profile Demographics Card */}
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Sekolah</span>
              <span className="block font-bold text-slate-800 text-sm flex items-center gap-1">
                <School className="w-4 h-4 text-violet-600" />
                {respondent.school || '-'}
              </span>
            </div>
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Kelas</span>
              <span className="block font-bold text-slate-800 text-sm">{respondent.class || '-'}</span>
            </div>
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Usia</span>
              <span className="block font-bold text-slate-800 text-sm">{respondent.age ? `${respondent.age} thn` : '-'}</span>
            </div>
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Kontak WA</span>
              <span className="block font-bold text-slate-800 text-sm">{respondent.phone || '-'}</span>
            </div>
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Pre-Test</span>
              <span
                className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-bold ${
                  respondent.has_completed_pretest
                    ? 'bg-emerald-100 text-emerald-700'
                    : 'bg-slate-100 text-slate-500'
                }`}
              >
                {respondent.has_completed_pretest ? 'Selesai' : 'Belum'}
              </span>
            </div>
            <div className="space-y-1">
              <span className="text-xs font-semibold text-slate-400">Post-Test</span>
              <span
                className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-bold ${
                  respondent.has_completed_posttest
                    ? 'bg-emerald-100 text-emerald-700'
                    : 'bg-amber-100 text-amber-700'
                }`}
              >
                {respondent.has_completed_posttest ? 'Selesai' : 'Belum'}
              </span>
            </div>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="flex border-b border-slate-200 space-x-4">
          <button
            onClick={() => setTab('overview')}
            className={`pb-3 text-sm font-bold border-b-2 transition-colors ${
              tab === 'overview'
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-slate-400 hover:text-slate-600'
            }`}
          >
            Log Kebiasaan ({habits.length} Hari)
          </button>
          <button
            onClick={() => setTab('pretest')}
            className={`pb-3 text-sm font-bold border-b-2 transition-colors ${
              tab === 'pretest'
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-slate-400 hover:text-slate-600'
            }`}
          >
            Jawaban Pre-Test ({pretestResponses.length} Soal)
          </button>
          <button
            onClick={() => setTab('posttest')}
            className={`pb-3 text-sm font-bold border-b-2 transition-colors ${
              tab === 'posttest'
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-slate-400 hover:text-slate-600'
            }`}
          >
            Jawaban Post-Test ({posttestResponses.length} Soal)
          </button>
          <button
            onClick={() => setTab('risks')}
            className={`pb-3 text-sm font-bold border-b-2 transition-colors ${
              tab === 'risks'
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-slate-400 hover:text-slate-600'
            }`}
          >
            Riwayat Check Risk ({risks.length})
          </button>
        </div>

        {/* Tab Content: Daily Habits Log */}
        {tab === 'overview' && (
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div className="p-4 border-b border-slate-100 flex items-center justify-between">
              <h3 className="font-bold text-slate-800 text-sm">Catatan Kebiasaan Harian Responden</h3>
            </div>
            {habits.length === 0 ? (
              <div className="p-8 text-center text-slate-400 text-sm">Belum ada catatan kebiasaan harian.</div>
            ) : (
              <table className="w-full text-left text-sm text-slate-600">
                <thead className="bg-slate-50 text-slate-500 uppercase text-[11px] font-bold border-b border-slate-200">
                  <tr>
                    <th className="px-5 py-3">Tanggal</th>
                    <th className="px-5 py-3">Air Minum</th>
                    <th className="px-5 py-3">Tidak Menahan BAK</th>
                    <th className="px-5 py-3">Kebersihan Genital</th>
                    <th className="px-5 py-3">Aktivitas Fisik</th>
                    <th className="px-5 py-3 text-right">Skor Kebiasaan</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {habits.map((h) => (
                    <tr key={h.id} className="hover:bg-slate-50/80">
                      <td className="px-5 py-3 font-semibold text-slate-700">{h.log_date}</td>
                      <td className="px-5 py-3">{h.water_intake} gelas</td>
                      <td className="px-5 py-3">
                        {h.no_hold_urine ? (
                          <span className="text-emerald-600 font-bold text-xs">Ya (Baik)</span>
                        ) : (
                          <span className="text-rose-500 font-bold text-xs">Menahan BAK</span>
                        )}
                      </td>
                      <td className="px-5 py-3 capitalize">{h.genital_hygiene}</td>
                      <td className="px-5 py-3">{h.physical_activity} menit</td>
                      <td className="px-5 py-3 text-right">
                        <span
                          className={`font-black text-xs px-2.5 py-1 rounded-full ${
                            h.habit_score >= 80
                              ? 'bg-emerald-100 text-emerald-700'
                              : h.habit_score >= 50
                              ? 'bg-amber-100 text-amber-700'
                              : 'bg-rose-100 text-rose-700'
                          }`}
                        >
                          {h.habit_score} / 100
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        )}

        {/* Tab Content: Pre-test Responses */}
        {tab === 'pretest' && (
          <div className="space-y-6">
            <div className="bg-violet-50 p-4 rounded-xl border border-violet-100 flex items-center justify-between">
              <span className="text-sm font-bold text-violet-900">Total Skor Pre-Test Responden</span>
              <span className="text-xl font-black text-violet-700">{totalPretestScore} / 150</span>
            </div>

            {['pengetahuan', 'sikap', 'perilaku'].map((vKey) => {
              const list = pretestByVariable[vKey] || [];
              const subtotal = list.reduce((acc, i) => acc + (i.score || 0), 0);
              return (
                <div key={vKey} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-3">
                  <div className="flex items-center justify-between border-b border-slate-100 pb-3">
                    <h4 className="font-bold text-slate-800 uppercase text-xs tracking-wider">
                      Domain: {vKey} ({list.length} Pertanyaan)
                    </h4>
                    <span className="text-xs font-bold bg-slate-100 text-slate-700 px-2.5 py-1 rounded-lg">
                      Subtotal: {subtotal} / {list.length * 5}
                    </span>
                  </div>
                  {list.map((r, idx) => (
                    <div key={idx} className="flex items-start justify-between py-2 text-sm">
                      <span className="text-slate-700 pr-4">{idx + 1}. {r.question_text}</span>
                      <span className="font-bold text-violet-700 shrink-0 px-2 py-0.5 bg-violet-50 rounded text-xs">
                        {r.option_text} ({r.score} pts)
                      </span>
                    </div>
                  ))}
                </div>
              );
            })}
          </div>
        )}

        {/* Tab Content: Post-test Responses */}
        {tab === 'posttest' && (
          <div className="space-y-6">
            <div className="bg-emerald-50 p-4 rounded-xl border border-emerald-100 flex items-center justify-between">
              <span className="text-sm font-bold text-emerald-900">Total Skor Post-Test Responden</span>
              <span className="text-xl font-black text-emerald-700">{totalPosttestScore} / 150</span>
            </div>

            {['pengetahuan', 'sikap', 'perilaku'].map((vKey) => {
              const list = posttestByVariable[vKey] || [];
              const subtotal = list.reduce((acc, i) => acc + (i.score || 0), 0);
              return (
                <div key={vKey} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-3">
                  <div className="flex items-center justify-between border-b border-slate-100 pb-3">
                    <h4 className="font-bold text-slate-800 uppercase text-xs tracking-wider">
                      Domain: {vKey} ({list.length} Pertanyaan)
                    </h4>
                    <span className="text-xs font-bold bg-slate-100 text-slate-700 px-2.5 py-1 rounded-lg">
                      Subtotal: {subtotal} / {list.length * 5}
                    </span>
                  </div>
                  {list.map((r, idx) => (
                    <div key={idx} className="flex items-start justify-between py-2 text-sm">
                      <span className="text-slate-700 pr-4">{idx + 1}. {r.question_text}</span>
                      <span className="font-bold text-emerald-700 shrink-0 px-2 py-0.5 bg-emerald-50 rounded text-xs">
                        {r.option_text} ({r.score} pts)
                      </span>
                    </div>
                  ))}
                </div>
              );
            })}
          </div>
        )}

        {/* Tab Content: Risk Screening Logs */}
        {tab === 'risks' && (
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            {risks.length === 0 ? (
              <div className="p-8 text-center text-slate-400 text-sm">Belum ada riwayat check risk.</div>
            ) : (
              <table className="w-full text-left text-sm text-slate-600">
                <thead className="bg-slate-50 text-slate-500 uppercase text-[11px] font-bold border-b border-slate-200">
                  <tr>
                    <th className="px-5 py-3">Tanggal Skrining</th>
                    <th className="px-5 py-3">Total Skor</th>
                    <th className="px-5 py-3 text-right">Kategori Risiko</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {risks.map((rk) => (
                    <tr key={rk.id}>
                      <td className="px-5 py-3 font-semibold text-slate-700">
                        {rk.created_at ? new Date(rk.created_at).toLocaleString('id-ID') : '-'}
                      </td>
                      <td className="px-5 py-3 font-bold text-slate-800">{rk.total_score} poin</td>
                      <td className="px-5 py-3 text-right">
                        <span
                          className={`font-black text-xs px-2.5 py-1 rounded-full uppercase ${
                            rk.risk_level === 'rendah'
                              ? 'bg-emerald-100 text-emerald-700'
                              : rk.risk_level === 'sedang'
                              ? 'bg-amber-100 text-amber-700'
                              : 'bg-rose-100 text-rose-700'
                          }`}
                        >
                          {rk.risk_level}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
