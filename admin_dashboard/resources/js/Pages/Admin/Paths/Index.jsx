import React from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { useState } from 'react';
import { Plus, Trash2, BookOpen, ArrowUp, ArrowDown } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Card, Badge, Input, Select } from '@/Components/UI';

export default function Index({ paths, allModules, pathModules }) {
  const { success, warning } = useToast();
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [icon, setIcon] = useState('route');
  const [selectedModules, setSelectedModules] = useState([]);

  const toggleModule = (id) => setSelectedModules(prev => prev.includes(id) ? prev.filter(p => p !== id) : [...prev, id]);

  const iconOptions = [
    { value: 'route', label: 'Route (default)' },
    { value: 'water_drop', label: 'Water Drop' },
    { value: 'clean_hands', label: 'Clean Hands' },
    { value: 'biotech', label: 'Biotech' },
    { value: 'psychology', label: 'Psychology' },
  ];

  const handleSubmit = (e) => {
    e.preventDefault();
    router.post('/admin/paths', { title, description, icon, module_ids: selectedModules }, {
      onSuccess: () => { success('Path berhasil dibuat!'); setShowForm(false); setTitle(''); setDescription(''); setIcon('route'); setSelectedModules([]); }
    });
  };

  const swapOrder = (id, direction) => {
    router.put(`/admin/paths/${id}/order`, { direction }, { preserveScroll: true });
  };

  return (
    <AdminLayout title="Learning Path" titleParent="Admin">
      <Head title="Learning Path — BloomFem" />
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-extrabold text-slate-800">Learning Path</h2>
          <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4" /> Buat Path</Button>
        </div>

        {showForm && (
          <Card>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nama Path</label><input value={title} onChange={e => setTitle(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" required /></div>
                <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Ikon</label>
                  <select value={icon} onChange={e => setIcon(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none">
                    {iconOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                  </select>
                </div>
              </div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Deskripsi</label><textarea value={description} onChange={e => setDescription(e.target.value)} rows={2} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" /></div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Pilih Modul</label>
                <div className="space-y-1 max-h-48 overflow-y-auto border border-sand-200 rounded-xl p-2">
                  {allModules.length === 0 && <p className="text-xs text-slate-400 p-2">Semua modul sudah terasosiasi dengan path lain.</p>}
                  {allModules.map(m => (
                    <label key={m.id} className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-sand-50 cursor-pointer">
                      <input type="checkbox" checked={selectedModules.includes(m.id)} onChange={() => toggleModule(m.id)} className="rounded text-teal-600" />
                      <BookOpen className="w-4 h-4 text-slate-400" />
                      <span className="text-sm font-semibold text-slate-700">{m.title}</span>
                    </label>
                  ))}
                </div>
              </div>
              <div className="flex justify-end gap-3"><Button variant="outline" onClick={() => setShowForm(false)}>Batal</Button><Button type="submit">Simpan</Button></div>
            </form>
          </Card>
        )}

        <div className="space-y-3">
          {paths.length === 0 ? (
            <Card className="text-center py-12"><p className="text-sm font-bold text-slate-500">Belum ada learning path.</p></Card>
          ) : paths.map((path, idx) => {
            const pmIds = pathModules.filter(pm => pm.path_id === path.id).map(pm => pm.module_id);
            return (
              <Card key={path.id}>
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <Badge variant="teal">{path.icon || 'route'}</Badge>
                      <span className="text-[10px] text-slate-400">Urutan {path.sort_order}</span>
                    </div>
                    <h4 className="text-sm font-bold text-slate-800">{path.title}</h4>
                    {path.description && <p className="text-xs text-slate-500 mt-1">{path.description}</p>}
                    <Badge variant="default" className="mt-2">{pmIds.length} modul</Badge>
                    <div className="flex flex-wrap gap-1 mt-2">
                      {allModules.filter(m => pmIds.includes(m.id)).map(m => (
                        <span key={m.id} className="text-[10px] bg-sand-50 px-2 py-0.5 rounded text-slate-500">{m.title}</span>
                      ))}
                    </div>
                  </div>
                  <div className="flex flex-col gap-1">
                    {idx > 0 && <button onClick={() => swapOrder(path.id, 'up')} className="p-1.5 text-slate-400 hover:bg-sand-50 rounded-lg" title="Naik"><ArrowUp className="w-4 h-4" /></button>}
                    {idx < paths.length - 1 && <button onClick={() => swapOrder(path.id, 'down')} className="p-1.5 text-slate-400 hover:bg-sand-50 rounded-lg" title="Turun"><ArrowDown className="w-4 h-4" /></button>}
                    <Button variant="ghost" size="sm" onClick={() => { warning('Hapus Path?', { description: `"${path.title}" akan dihapus.`, action: { label: 'Ya', onClick: () => router.delete(`/admin/paths/${path.id}`) } }); }}><Trash2 className="w-3.5 h-3.5" /></Button>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      </div>
    </AdminLayout>
  );
}
