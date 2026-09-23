import React from 'react';
import { Head, Link } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Users,
  ClipboardCheck,
  Award,
  BookOpen,
  Droplets,
  ShieldCheck,
  Activity,
  School,
  TrendingUp,
  ArrowRight,
  AlertCircle,
} from 'lucide-react';

export default function Dashboard({
  stats,
  riskDistribution,
  schoolDistribution,
  avgHabits,
  recentRespondents,
  comparisonData,
}) {
  return (
    <AdminLayout title="Dashboard Penelitian">
      <Head title="Dashboard Admin & Penelitian - UtiCare" />

      <div className="space-y-6">
        {/* Banner Title */}
        <div className="bg-gradient-to-r from-violet-600 via-indigo-600 to-purple-600 rounded-2xl p-6 md:p-8 text-white shadow-lg shadow-violet-200">
          <div className="max-w-3xl">
            <span className="inline-block px-3 py-1 bg-white/20 backdrop-blur-md rounded-full text-xs font-bold uppercase tracking-wider mb-3">
              Skripsi Keperawatan
            </span>
            <h2 className="text-2xl md:text-3xl font-extrabold tracking-tight">
              Pengaruh Aplikasi Mobile Berbasis Health Belief Model terhadap Pencegahan Infeksi Saluran Kemih pada Remaja Putri
            </h2>
            <p className="mt-2 text-violet-100 text-sm md:text-base leading-relaxed">
              Monitoring data responden SMA di Bandung, efektivitas intervensi 7 hari, dan kepatuhan kebiasaan pencegahan ISK secara real-time.
            </p>
          </div>
        </div>

        {/* 4 Stat Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-violet-100 flex items-center justify-center text-violet-600">
              <Users className="w-6 h-6" />
            </div>
            <div>
              <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Responden</span>
              <span className="text-2xl font-black text-slate-800">{stats.totalRespondents}</span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-blue-100 flex items-center justify-center text-blue-600">
              <ClipboardCheck className="w-6 h-6" />
            </div>
            <div>
              <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Pre-Test Selesai</span>
              <span className="text-2xl font-black text-slate-800">{stats.completedPretest}</span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-emerald-100 flex items-center justify-center text-emerald-600">
              <Award className="w-6 h-6" />
            </div>
            <div>
              <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Post-Test Selesai</span>
              <span className="text-2xl font-black text-slate-800">{stats.completedPosttest}</span>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center text-amber-600">
              <BookOpen className="w-6 h-6" />
            </div>
            <div>
              <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Materi Edukasi ISK</span>
              <span className="text-2xl font-black text-slate-800">{stats.totalMaterials}</span>
            </div>
          </div>
        </div>

        {/* Comparison: Pre-test vs Post-test (Health Belief Model Effect) */}
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-violet-600" />
                Evaluasi Efektivitas Intervensi HBM (Pre-Test vs Post-Test)
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">
                Rata-rata skor instrumen (Skala 1 - 5) pada 3 domain utama pencegahan ISK
              </p>
            </div>
            <Link
              href="/admin/respondents"
              className="text-xs font-bold text-violet-600 hover:text-violet-700 flex items-center gap-1"
            >
              Lihat Detail Responden <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {comparisonData.map((item) => {
              const diff = (item.posttest - item.pretest).toFixed(2);
              const isPositive = parseFloat(diff) >= 0;
              return (
                <div key={item.variable} className="bg-slate-50 rounded-xl p-4 border border-slate-200/80">
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-sm font-bold text-slate-700">{item.variable}</span>
                    <span
                      className={`text-xs font-extrabold px-2 py-0.5 rounded-full ${
                        isPositive ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-200 text-slate-600'
                      }`}
                    >
                      {isPositive ? `+${diff}` : diff} pts
                    </span>
                  </div>

                  <div className="space-y-3">
                    <div>
                      <div className="flex justify-between text-xs font-semibold text-slate-500 mb-1">
                        <span>Pre-Test</span>
                        <span className="font-bold text-slate-700">{item.pretest} / 5.0</span>
                      </div>
                      <div className="w-full bg-slate-200 rounded-full h-2">
                        <div
                          className="bg-blue-500 h-2 rounded-full transition-all duration-500"
                          style={{ width: `${(item.pretest / 5) * 100}%` }}
                        />
                      </div>
                    </div>

                    <div>
                      <div className="flex justify-between text-xs font-semibold text-slate-500 mb-1">
                        <span>Post-Test</span>
                        <span className="font-bold text-emerald-700">{item.posttest} / 5.0</span>
                      </div>
                      <div className="w-full bg-slate-200 rounded-full h-2">
                        <div
                          className="bg-emerald-500 h-2 rounded-full transition-all duration-500"
                          style={{ width: `${(item.posttest / 5) * 100}%` }}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* 2-Column: Habit Averages & Risk Level Distribution */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Daily Habit Compliance */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2 mb-4">
              <Activity className="w-5 h-5 text-indigo-600" />
              Rata-rata Kepatuhan Kebiasaan Harian
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 rounded-xl bg-blue-50/80 border border-blue-100">
                <div className="flex items-center gap-2 text-blue-600 mb-1">
                  <Droplets className="w-4 h-4" />
                  <span className="text-xs font-bold">Konsumsi Air</span>
                </div>
                <span className="text-2xl font-black text-slate-800">{avgHabits?.avg_water || 0}</span>
                <span className="text-xs text-slate-500 ml-1">gelas/hari</span>
              </div>

              <div className="p-4 rounded-xl bg-violet-50/80 border border-violet-100">
                <div className="flex items-center gap-2 text-violet-600 mb-1">
                  <ShieldCheck className="w-4 h-4" />
                  <span className="text-xs font-bold">Tidak Menahan BAK</span>
                </div>
                <span className="text-2xl font-black text-slate-800">{avgHabits?.pct_no_hold || 0}%</span>
                <span className="text-xs text-slate-500 ml-1">responden</span>
              </div>

              <div className="p-4 rounded-xl bg-emerald-50/80 border border-emerald-100">
                <div className="flex items-center gap-2 text-emerald-600 mb-1">
                  <Activity className="w-4 h-4" />
                  <span className="text-xs font-bold">Aktivitas Fisik</span>
                </div>
                <span className="text-2xl font-black text-slate-800">{avgHabits?.avg_activity || 0}</span>
                <span className="text-xs text-slate-500 ml-1">menit/hari</span>
              </div>

              <div className="p-4 rounded-xl bg-purple-50/80 border border-purple-100">
                <div className="flex items-center gap-2 text-purple-600 mb-1">
                  <Award className="w-4 h-4" />
                  <span className="text-xs font-bold">Skor Kebiasaan</span>
                </div>
                <span className="text-2xl font-black text-slate-800">{avgHabits?.avg_score || 0}</span>
                <span className="text-xs text-slate-500 ml-1">/ 100</span>
              </div>
            </div>
          </div>

          {/* Risk Level Distribution */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2 mb-4">
              <AlertCircle className="w-5 h-5 text-amber-600" />
              Distribusi Risiko ISK Responden
            </h3>

            <div className="space-y-4">
              <div className="flex items-center justify-between p-3.5 bg-emerald-50 rounded-xl border border-emerald-100">
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-emerald-500" />
                  <span className="font-bold text-emerald-900 text-sm">Risiko Rendah</span>
                </div>
                <span className="font-black text-emerald-700 text-lg">{riskDistribution.rendah} responden</span>
              </div>

              <div className="flex items-center justify-between p-3.5 bg-amber-50 rounded-xl border border-amber-100">
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-amber-500" />
                  <span className="font-bold text-amber-900 text-sm">Risiko Sedang</span>
                </div>
                <span className="font-black text-amber-700 text-lg">{riskDistribution.sedang} responden</span>
              </div>

              <div className="flex items-center justify-between p-3.5 bg-rose-50 rounded-xl border border-rose-100">
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-rose-500" />
                  <span className="font-bold text-rose-900 text-sm">Risiko Tinggi</span>
                </div>
                <span className="font-black text-rose-700 text-lg">{riskDistribution.tinggi} responden</span>
              </div>
            </div>
          </div>
        </div>

        {/* 2-Column: School Distribution & Recent Respondents */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* School Distribution */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2 mb-4">
              <School className="w-5 h-5 text-violet-600" />
              Distribusi Asal Sekolah / SMA
            </h3>

            {schoolDistribution.length === 0 ? (
              <p className="text-sm text-slate-400 py-4 text-center">Belum ada data sekolah terdaftar.</p>
            ) : (
              <div className="space-y-3">
                {schoolDistribution.map((s, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-slate-50 rounded-xl">
                    <span className="font-semibold text-slate-700 text-sm">{s.school}</span>
                    <span className="px-2.5 py-1 bg-violet-100 text-violet-700 rounded-lg text-xs font-extrabold">
                      {s.count} siswa
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Recent Respondents */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                <Users className="w-5 h-5 text-violet-600" />
                Responden Terbaru
              </h3>
              <Link href="/admin/respondents" className="text-xs font-bold text-violet-600 hover:text-violet-700">
                Lihat Semua
              </Link>
            </div>

            {recentRespondents.length === 0 ? (
              <p className="text-sm text-slate-400 py-4 text-center">Belum ada responden terdaftar.</p>
            ) : (
              <div className="divide-y divide-slate-100">
                {recentRespondents.map((r) => (
                  <div key={r.id} className="py-3 flex items-center justify-between">
                    <div>
                      <span className="block font-bold text-slate-800 text-sm">{r.full_name || 'Tanpa Nama'}</span>
                      <span className="block text-xs text-slate-400">
                        {r.school || '-'} &bull; Kelas: {r.class || '-'}
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span
                        className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                          r.has_completed_pretest
                            ? 'bg-emerald-100 text-emerald-700'
                            : 'bg-slate-100 text-slate-500'
                        }`}
                      >
                        {r.has_completed_pretest ? 'Pre-test OK' : 'Belum Pre-test'}
                      </span>
                      <Link
                        href={`/admin/respondents/${r.id}`}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-violet-600 hover:bg-violet-50"
                      >
                        <ArrowRight className="w-4 h-4" />
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}