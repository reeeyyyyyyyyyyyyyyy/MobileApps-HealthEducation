import React, { useState } from 'react';
import { Head, Link, router, usePage } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Search, Plus, Edit2, Trash2, Eye, ExternalLink, HelpCircle, CheckCircle2, Send } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Badge, Input, Select } from '@/Components/UI';
import UploadButton from '@/Components/UploadButton';

export default function Index({ modules, filters }) {
  const [search, setSearch] = useState(filters.search || '');
  const [category, setCategory] = useState(filters.category || '');
  const [showQuizPrompt, setShowQuizPrompt] = useState(false);
  const [quizModuleId, setQuizModuleId] = useState(null);
  const { warning } = useToast();
  const { props } = usePage();
  const { flash } = props;

  // Post-create quiz prompt
  React.useEffect(() => {
    if (flash?.module_id) {
      setQuizModuleId(flash.module_id);
      setShowQuizPrompt(true);
    }
  }, [flash?.module_id]);

  const goToQuizCreate = () => {
    setShowQuizPrompt(false);
    // Baca questions dari localStorage (disimpan oleh Form saat save)
    let questionsUrl = '';
    const stored = localStorage.getItem('pending_quiz_questions');
    if (stored) {
      const parsed = JSON.parse(stored);
      if (Array.isArray(parsed) && parsed.length > 0) {
        questionsUrl = `&questions=${encodeURIComponent(JSON.stringify(parsed))}`;
      }
      localStorage.removeItem('pending_quiz_questions');
    }
    router.get(`/admin/quizzes/create?module_id=${quizModuleId}${questionsUrl}`);
  };

  React.useEffect(() => {
    const query = {};
    if (search) query.search = search;
    if (category) query.category = category;

    const timer = setTimeout(() => {
      router.get('/admin/modules', query, { preserveState: true, replace: true });
    }, 300);
    return () => clearTimeout(timer);
  }, [search, category]);

  const handleDelete = (id, title) => {
    warning('Hapus Modul?', {
      description: `Modul "${title}" akan dihapus permanen.`,
      preset: 'bouncy',
      duration: 6000,
      action: { label: 'Ya, Hapus', onClick: () => router.delete(`/admin/modules/${id}`), successLabel: 'Terhapus' }
    });
  };

  const getCategoryBadge = (cat) => {
    switch (cat) {
      case 'Pengetahuan': return 'teal';
      case 'Sikap Positif': return 'sage';
      case 'Perilaku Sehat': return 'terracotta';
      default: return 'default';
    }
  };

  return (
    <AdminLayout title="Modul Edukasi" titleParent="Admin">
      <Head title="Modul Edukasi — BloomFem" />
      <div className="bg-white border border-sand-200/80 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-5 border-b border-sand-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
          <div className="flex flex-1 flex-col sm:flex-row gap-3 w-full">
            <div className="relative rounded-xl shadow-sm flex-1 max-w-md w-full">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400"><Search className="h-4 w-4" /></div>
              <Input type="text" value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Cari judul modul..." className="block w-full pl-10 pr-4 py-2.5 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all" />
            </div>
            <Select value={category} onChange={(e) => setCategory(e.target.value)} className="block rounded-xl border border-sand-200 py-2.5 px-3.5 focus:border-teal-500 text-sm font-semibold transition-all cursor-pointer bg-white">
              <option value="">Semua Kategori</option>
              <option value="Pengetahuan">Pengetahuan</option>
              <option value="Sikap Positif">Sikap Positif</option>
              <option value="Perilaku Sehat">Perilaku Sehat</option>
            </Select>
          </div>
          <div className="flex gap-2 w-full sm:w-auto">
            <UploadButton />
            <Link href="/admin/modules/create" className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-98 transition-all rounded-xl shadow-md shadow-teal-200 w-full sm:w-auto justify-center">
              <Plus className="w-4 h-4" /> Tambah Modul
            </Link>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-sand-50/50 border-b border-sand-100 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
                <th className="py-4.5 px-6">Judul Modul</th>
                <th className="py-4.5 px-6">Kategori</th>
                <th className="py-4.5 px-6">Durasi</th>
                <th className="py-4.5 px-6">Status</th>
                <th className="py-4.5 px-6">Total Dilihat</th>
                <th className="py-4.5 px-6 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-sand-100 text-sm">
              {modules.data.length > 0 ? (
                modules.data.map((module) => (
                  <tr key={module.id} className="hover:bg-sand-50/30 transition-all">
                    <td className="py-4 px-6 font-bold text-slate-700 max-w-sm">
                      {module.title}
                      {module.video_url && (
                        <a href={module.video_url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-0.5 ml-2 text-[10px] font-bold text-teal-500 hover:underline">
                          Video <ExternalLink className="w-2.5 h-2.5" />
                        </a>
                      )}
                    </td>
                    <td className="py-4 px-6">
                      <Badge variant={getCategoryBadge(module.category)}>{module.category}</Badge>
                    </td>
                    <td className="py-4 px-6 font-semibold text-slate-500">{module.duration}</td>
                    <td className="py-4 px-6">
                      {module.published == 1 ? (
                        <Badge variant="sage">Published</Badge>
                      ) : module.scheduled_at ? (
                        <Badge variant="amber">Terjadwal: {new Date(module.scheduled_at).toLocaleDateString('id-ID')}</Badge>
                      ) : (
                        <Badge variant="brick">Draft</Badge>
                      )}
                    </td>
                    <td className="py-4 px-6 font-semibold text-slate-500">
                      <div className="flex items-center gap-1.5"><Eye className="w-3.5 h-3.5 text-slate-300" /> {module.view_count || 0}</div>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        {module.published != 1 && !module.scheduled_at && (
                          <button onClick={() => router.put(`/admin/modules/${module.id}/publish`, {}, { preserveScroll: true })} className="p-2 text-sage-600 hover:bg-sage-50 rounded-xl transition-all" title="Posting Sekarang"><Send className="w-4 h-4" /></button>
                        )}
                        <Link href={`/admin/modules/${module.id}/edit`} className="p-2 text-slate-400 hover:bg-sand-50 hover:text-slate-700 rounded-xl transition-all" title="Edit Modul"><Edit2 className="w-4 h-4" /></Link>
                        <button onClick={() => handleDelete(module.id, module.title)} className="p-2 text-slate-400 hover:bg-brick-50 hover:text-brick-600 rounded-xl transition-all" title="Hapus Modul"><Trash2 className="w-4 h-4" /></button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr><td colSpan="5" className="py-12 text-center text-sm font-semibold text-slate-400">Tidak ada modul ditemukan.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        {modules.links && modules.total > modules.per_page && (
          <div className="px-6 py-4 bg-sand-50/30 border-t border-sand-100 flex items-center justify-between gap-4 text-xs font-bold text-slate-400">
            <div>Menampilkan {modules.from || 0} - {modules.to || 0} dari {modules.total} modul</div>
            <div className="flex gap-1.5">
              {modules.links.map((link, idx) => {
                let label = link.label;
                if (label.includes('Previous')) label = 'Sebelumnya';
                else if (label.includes('Next')) label = 'Berikutnya';
                return (
                  <Link key={idx} href={link.url || '#'} disabled={!link.url} className={`px-3 py-1.5 border rounded-lg transition-all ${
                    link.active ? 'bg-teal-600 border-teal-600 text-white shadow-sm' :
                    link.url ? 'bg-white border-sand-200 text-slate-500 hover:bg-sand-50 hover:border-sand-300' :
                    'bg-sand-50 border-sand-100 text-slate-300 cursor-not-allowed'
                  }`} dangerouslySetInnerHTML={{ __html: label }} />
                );
              })}
            </div>
          </div>
        )}
      </div>

      {/* Quiz Creation Prompt Modal */}
      {showQuizPrompt && (
        <>
          <div className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40" onClick={() => setShowQuizPrompt(false)} />
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={() => setShowQuizPrompt(false)}>
            <div className="bg-white rounded-2xl shadow-xl border border-sand-200 p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
              <div className="flex items-start gap-4 mb-5">
                <div className="w-12 h-12 rounded-xl bg-teal-50 flex items-center justify-center flex-shrink-0">
                  <CheckCircle2 className="w-6 h-6 text-teal-600" />
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-slate-800">Modul Berhasil Dibuat!</h3>
                  <p className="text-sm text-slate-500 mt-1">Apakah Anda ingin langsung membuat kuis untuk modul ini?</p>
                </div>
              </div>
              <div className="flex justify-end gap-3">
                <button type="button" onClick={() => setShowQuizPrompt(false)} className="px-5 py-2.5 rounded-xl border border-sand-200 text-slate-500 hover:text-slate-700 hover:bg-sand-50 text-sm font-bold active:scale-98 transition-all">Nanti Saja</button>
                <button type="button" onClick={goToQuizCreate} className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-98 transition-all rounded-xl shadow-md shadow-teal-200">
                  <HelpCircle className="w-4 h-4" /> Ya, Buat Kuis
                </button>
              </div>
            </div>
          </div>
        </>
      )}
    </AdminLayout>
  );
}