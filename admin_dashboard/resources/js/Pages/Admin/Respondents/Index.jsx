import React, { useState } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
  Search,
  Filter,
  Download,
  Eye,
  School,
  Calendar,
  CheckCircle2,
  XCircle,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

export default function Index({ respondents, filters, schools }) {
  const [search, setSearch] = useState(filters.search || '');
  const [school, setSchool] = useState(filters.school || '');
  const [pretest, setPretest] = useState(filters.pretest || '');
  const [posttest, setPosttest] = useState(filters.posttest || '');

  const handleFilter = (e) => {
    e.preventDefault();
    router.get('/admin/respondents', { search, school, pretest, posttest }, { preserveState: true });
  };

  const handleReset = () => {
    setSearch('');
    setSchool('');
    setPretest('');
    setPosttest('');
    router.get('/admin/respondents');
  };

  return (
    <AdminLayout title="Data Responden Penelitian">
      <Head title="Responden Penelitian - UtiCare" />

      <div className="space-y-6">
        {/* Top bar with Export */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Daftar Responden ({respondents.total})</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Data responden remaja putri dari 2 SMA di Bandung untuk penelitian ISK
            </p>
          </div>
          <a
            href="/admin/respondents/export"
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors"
          >
            <Download className="w-4 h-4" />
            Export Data SPSS (CSV)
          </a>
        </div>

        {/* Filter Card */}
        <form onSubmit={handleFilter} className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {/* Search */}
            <div className="relative">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Cari nama, kelas, HP..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white"
              />
            </div>

            {/* School Filter */}
            <div>
              <select
                value={school}
                onChange={(e) => setSchool(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white text-slate-700"
              >
                <option value="">Semua Sekolah</option>
                {schools.map((s) => (
                  <option key={s} value={s}>
                    {s}
                  </option>
                ))}
              </select>
            </div>

            {/* Pretest Status */}
            <div>
              <select
                value={pretest}
                onChange={(e) => setPretest(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white text-slate-700"
              >
                <option value="">Status Pre-test</option>
                <option value="yes">Sudah Pre-test</option>
                <option value="no">Belum Pre-test</option>
              </select>
            </div>

            {/* Posttest Status */}
            <div>
              <select
                value={posttest}
                onChange={(e) => setPosttest(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 focus:bg-white text-slate-700"
              >
                <option value="">Status Post-test</option>
                <option value="yes">Sudah Post-test</option>
                <option value="no">Belum Post-test</option>
              </select>
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button
              type="button"
              onClick={handleReset}
              className="px-3.5 py-1.5 text-xs font-semibold text-slate-500 hover:bg-slate-100 rounded-lg"
            >
              Reset
            </button>
            <button
              type="submit"
              className="px-4 py-1.5 text-xs font-bold bg-slate-800 hover:bg-slate-900 text-white rounded-lg transition-colors flex items-center gap-1.5"
            >
              <Filter className="w-3.5 h-3.5" />
              Terapkan Filter
            </button>
          </div>
        </form>

        {/* Respondent Table */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-slate-500 uppercase text-[11px] font-bold tracking-wider border-b border-slate-200">
                <tr>
                  <th className="px-5 py-3.5">Nama Responden</th>
                  <th className="px-5 py-3.5">Sekolah & Kelas</th>
                  <th className="px-5 py-3.5">Usia / Kontak</th>
                  <th className="px-5 py-3.5 text-center">Pre-Test</th>
                  <th className="px-5 py-3.5 text-center">Post-Test</th>
                  <th className="px-5 py-3.5">Tanggal Daftar</th>
                  <th className="px-5 py-3.5 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {respondents.data.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                      Tidak ada responden yang sesuai dengan filter.
                    </td>
                  </tr>
                ) : (
                  respondents.data.map((r) => (
                    <tr key={r.id} className="hover:bg-slate-50/80 transition-colors">
                      <td className="px-5 py-4">
                        <div className="font-bold text-slate-800">{r.full_name || 'Tanpa Nama'}</div>
                        <div className="text-xs text-slate-400 font-mono truncate max-w-[140px]">{r.id}</div>
                      </td>
                      <td className="px-5 py-4">
                        <div className="font-semibold text-slate-700 flex items-center gap-1.5">
                          <School className="w-3.5 h-3.5 text-violet-500" />
                          {r.school || '-'}
                        </div>
                        <div className="text-xs text-slate-400">Kelas: {r.class || '-'}</div>
                      </td>
                      <td className="px-5 py-4">
                        <div className="text-slate-700 font-medium">{r.age ? `${r.age} tahun` : '-'}</div>
                        <div className="text-xs text-slate-400">{r.phone || '-'}</div>
                      </td>
                      <td className="px-5 py-4 text-center">
                        {r.has_completed_pretest ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Selesai
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-500">
                            <XCircle className="w-3.5 h-3.5" /> Belum
                          </span>
                        )}
                      </td>
                      <td className="px-5 py-4 text-center">
                        {r.has_completed_posttest ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Selesai
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-600">
                            <XCircle className="w-3.5 h-3.5" /> Belum
                          </span>
                        )}
                      </td>
                      <td className="px-5 py-4 text-xs text-slate-500">
                        {r.created_at ? new Date(r.created_at).toLocaleDateString('id-ID') : '-'}
                      </td>
                      <td className="px-5 py-4 text-right">
                        <Link
                          href={`/admin/respondents/${r.id}`}
                          className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold bg-violet-50 text-violet-700 hover:bg-violet-100 transition-colors"
                        >
                          <Eye className="w-3.5 h-3.5" /> Detail
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {respondents.links && respondents.links.length > 3 && (
            <div className="px-5 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
              <span className="text-xs text-slate-500">
                Menampilkan {respondents.from || 0} - {respondents.to || 0} dari {respondents.total} responden
              </span>
              <div className="flex items-center gap-1">
                {respondents.links.map((link, idx) => {
                  if (!link.url) {
                    return (
                      <span
                        key={idx}
                        dangerouslySetInnerHTML={{ __html: link.label }}
                        className="px-3 py-1 rounded-lg text-xs text-slate-400"
                      />
                    );
                  }
                  return (
                    <Link
                      key={idx}
                      href={link.url}
                      dangerouslySetInnerHTML={{ __html: link.label }}
                      className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
                        link.active
                          ? 'bg-violet-600 text-white'
                          : 'bg-white text-slate-700 hover:bg-slate-100 border border-slate-200'
                      }`}
                    />
                  );
                })}
              </div>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
