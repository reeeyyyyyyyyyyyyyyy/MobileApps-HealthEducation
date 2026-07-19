import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, Megaphone } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Card } from '@/Components/UI';

export default function Index({ announcements }) {
  const { success, warning } = useToast();
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    router.post('/admin/announcements', { title, content }, {
      onSuccess: () => { success('Pengumuman dibuat!'); setShowForm(false); setTitle(''); setContent(''); }
    });
  };

  return (
    <AdminLayout title="Pengumuman" titleParent="Admin">
      <Head title="Pengumuman — BloomFem" />
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-extrabold text-slate-800">Pengumuman</h2>
          <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4" /> Buat Pengumuman</Button>
        </div>
        {showForm && (
          <Card><form onSubmit={handleSubmit} className="space-y-4">
            <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Judul</label><input value={title} onChange={e => setTitle(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" required /></div>
            <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Konten</label><textarea value={content} onChange={e => setContent(e.target.value)} rows={3} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" required /></div>
            <div className="flex justify-end gap-3"><Button variant="outline" onClick={() => setShowForm(false)}>Batal</Button><Button type="submit">Simpan</Button></div>
          </form></Card>
        )}
        <div className="space-y-3">
          {announcements.data.length === 0 ? (
            <Card className="text-center py-12"><Megaphone className="w-10 h-10 text-slate-300 mx-auto mb-3" /><p className="text-sm font-bold text-slate-500">Belum ada pengumuman.</p></Card>
          ) : announcements.data.map(a => (
            <Card key={a.id} hover>
              <div className="flex items-start justify-between">
                <div>
                  <h4 className="text-sm font-bold text-slate-800">{a.title}</h4>
                  <p className="text-xs text-slate-500 mt-1">{a.content}</p>
                  <p className="text-[10px] text-slate-400 mt-2">{new Date(a.created_at).toLocaleDateString('id-ID')}</p>
                </div>
                <Button variant="ghost" size="sm" onClick={() => { warning('Hapus?', { description: `"${a.title}" akan dihapus.`, action: { label: 'Ya', onClick: () => router.delete(`/admin/announcements/${a.id}`) } }); }}><Trash2 className="w-3.5 h-3.5" /></Button>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
