import React, { useState } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, Sparkles, Bot } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Badge, Card } from '@/Components/UI';

export default function Index({ tips }) {
  const { success, warning } = useToast();
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState(null);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [category, setCategory] = useState('umum');

  const openCreate = () => { setEditing(null); setTitle(''); setContent(''); setCategory('umum'); setShowForm(true); };
  const openEdit = (tip) => { setEditing(tip.id); setTitle(tip.title); setContent(tip.content); setCategory(tip.category); setShowForm(true); };
  const closeForm = () => { setShowForm(false); setEditing(null); };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!window.confirm('Simpan tips harian ini?')) return;
    if (editing) {
      router.put(`/admin/tips/${editing}`, { title, content, category }, { onSuccess: () => { success('Tips diperbarui!'); closeForm(); } });
    } else {
      router.post('/admin/tips', { title, content, category }, { onSuccess: () => { success('Tips ditambahkan!'); closeForm(); } });
    }
  };

  const handleDelete = (id, t) => {
    warning('Hapus Tips?', { description: `Tips "${t}" akan dihapus.`, preset: 'bouncy', duration: 6000, action: { label: 'Ya, Hapus', onClick: () => router.delete(`/admin/tips/${id}`), successLabel: 'Terhapus' } });
  };

  return (
    <AdminLayout title="Tips Harian" titleParent="Admin">
      <Head title="Tips Harian — BloomFem" />
      <div className="space-y-6">
        <div className="flex justify-between items-center gap-3">
          <h2 className="text-lg font-extrabold text-slate-800">Kelola Tips Harian</h2>
          <div className="flex gap-2">
            <Button variant="outline" onClick={() => router.post('/admin/tips/generate', {}, { onSuccess: () => success('Tips AI berhasil dibuat!') })}>
              <Bot className="w-4 h-4" /> Tambah via AI
            </Button>
            <Button onClick={openCreate}><Plus className="w-4 h-4" /> Tambah Tips</Button>
          </div>
        </div>

        {showForm && (
          <Card>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Judul</label><input value={title} onChange={e => setTitle(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 outline-none" required /></div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Konten</label><textarea value={content} onChange={e => setContent(e.target.value)} rows={3} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 outline-none" required /></div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Kategori</label>
                <select value={category} onChange={e => setCategory(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 outline-none">
                  <option value="umum">Umum</option>
                  <option value="kesehatan">Kesehatan</option>
                  <option value="siklus">Siklus</option>
                  <option value="nutrisi">Nutrisi</option>
                  <option value="mental">Kesehatan Mental</option>
                </select>
              </div>
              <div className="flex justify-end gap-3">
                <Button variant="outline" onClick={closeForm}>Batal</Button>
                <Button type="submit">{editing ? 'Perbarui' : 'Simpan'}</Button>
              </div>
            </form>
          </Card>
        )}

        <div className="space-y-3">
          {tips.data.length === 0 ? (
            <Card className="text-center py-12">
              <Sparkles className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-sm font-bold text-slate-500">Belum ada tips harian</p>
              <p className="text-xs text-slate-400 mt-1">Klik "Tambah Tips" untuk membuat tips pertama.</p>
            </Card>
          ) : tips.data.map(tip => (
            <Card key={tip.id} hover>
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <Badge variant="teal">{tip.category}</Badge>
                  </div>
                  <h4 className="text-sm font-bold text-slate-800">{tip.title}</h4>
                  <p className="text-xs text-slate-500 mt-1">{tip.content}</p>
                  <p className="text-[10px] text-slate-400 mt-2">{new Date(tip.created_at).toLocaleDateString('id-ID')}</p>
                </div>
                <div className="flex gap-1 flex-shrink-0">
                  <Button variant="ghost" size="sm" onClick={() => openEdit(tip)}>Edit</Button>
                  <Button variant="ghost" size="sm" onClick={() => handleDelete(tip.id, tip.title)}><Trash2 className="w-3.5 h-3.5" /></Button>
                </div>
              </div>
            </Card>
          ))}
        </div>

        {tips.links && tips.total > tips.per_page && (
          <div className="flex justify-center gap-2 mt-4">
            {tips.links.map((link, idx) => {
              let label = link.label;
              if (label.includes('Previous')) label = '‹'; else if (label.includes('Next')) label = '›';
              return <Link key={idx} href={link.url || '#'} disabled={!link.url} className={`px-3 py-1.5 text-xs font-bold rounded-lg ${link.active ? 'bg-teal-600 text-white' : link.url ? 'bg-white border border-sand-200 text-slate-500' : 'text-slate-300 cursor-not-allowed'}`} dangerouslySetInnerHTML={{ __html: label }} />;
            })}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}