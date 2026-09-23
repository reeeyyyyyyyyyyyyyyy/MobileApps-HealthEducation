import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, BookOpen, Route, Droplets, Hand, FlaskConical, Brain, GripVertical, ChevronDown, ChevronUp } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Card, Badge } from '@/Components/UI';
import { DndContext, closestCenter, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy, useSortable, arrayMove } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

function SortablePath({ path, pathModules, allModules, idx }) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: path.id });
  const style = { transform: CSS.Transform.toString(transform), transition, zIndex: isDragging ? 50 : 'auto' };
  const [expanded, setExpanded] = useState(false);

  const pathModIds = (pathModules || []).filter(pm => String(pm.path_id) === String(path.id)).map(pm => pm.module_id);
  const modsInPath = (allModules || []).filter(m => pathModIds.includes(m.id));
  const count = modsInPath.length;

  return (
    <div ref={setNodeRef} style={style} className={`${isDragging ? 'opacity-50' : ''}`}>
      <Card className="hover:border-teal-500/30 transition-all shadow-sm p-0 overflow-hidden">
        {/* Header - always visible */}
        <div className="flex items-start justify-between gap-4 p-5">
          <div className="flex items-start gap-3 flex-1">
            <button {...attributes} {...listeners} className="mt-2 p-1 text-slate-400 hover:text-slate-600 cursor-grab active:cursor-grabbing">
              <GripVertical className="w-4 h-4" />
            </button>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1.5">
                <Badge variant="teal">{path.icon || 'route'}</Badge>
                <span className="text-[10px] text-slate-400 font-medium">Urutan {path.sort_order}</span>
              </div>
              <h4 className="text-base font-extrabold text-slate-800">{path.title}</h4>
              {path.description && <p className="text-xs text-slate-500 mt-1 font-medium">{path.description}</p>}
              <div className="mt-3 flex items-center gap-2">
                <Badge variant="default" className="bg-sand-100 text-slate-700 font-bold">{count} Modul Ditautkan</Badge>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 flex-shrink-0">
            <button onClick={() => setExpanded(!expanded)} className="p-2 text-slate-400 hover:bg-sand-50 rounded-lg transition-colors" title={expanded ? 'Tutup' : 'Lihat Modul'}>
              {expanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
            </button>
            <Button variant="ghost" size="sm"
              onClick={() => { warning('Hapus Path?', { description: `"${path.title}" akan dihapus.`, action: { label: 'Ya', onClick: () => router.delete(`/admin/paths/${path.id}`) } }); }}
              className="text-brick-500 hover:bg-brick-50 hover:text-brick-600"
            >
              <Trash2 className="w-4 h-4" />
            </Button>
          </div>
        </div>

        {/* Expanded module list */}
        {expanded && (
          <div className="border-t border-sand-200 bg-sand-50/50 px-5 py-4 space-y-2">
            {count === 0 ? (
              <p className="text-xs text-slate-400">Belum ada modul dalam path ini. Tambah modul dengan centang saat membuat/pengeditan modul.</p>
            ) : (
              modsInPath.map(m => (
                <div key={m.id} className="flex items-center gap-3 px-3 py-2 rounded-lg bg-white border border-sand-200 shadow-sm">
                  <BookOpen className="w-4 h-4 text-teal-600 flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <span className="text-sm font-semibold text-slate-700 truncate block">{m.title}</span>
                    <span className="text-[10px] text-slate-400">{m.category} · {m.duration}</span>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </Card>
    </div>
  );
}

export default function Index({ paths, allModules, pathModules }) {
  const { success, warning } = useToast();
  const [items, setItems] = useState(paths.map(p => p.id));
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [icon, setIcon] = useState('route');
  const [selectedModules, setSelectedModules] = useState([]);

  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 5 } }));

  const toggleModule = (id) => setSelectedModules(prev => prev.includes(id) ? prev.filter(p => p !== id) : [...prev, id]);

  const iconOptions = [
    { value: 'route', label: 'Route', icon: Route },
    { value: 'water_drop', label: 'Water Drop', icon: Droplets },
    { value: 'clean_hands', label: 'Clean Hands', icon: Hand },
    { value: 'biotech', label: 'Biotech', icon: FlaskConical },
    { value: 'psychology', label: 'Psychology', icon: Brain },
  ];

  const handleSubmit = (e) => {
    e.preventDefault();
    router.post('/admin/paths', { title, description, icon, module_ids: selectedModules }, {
      onSuccess: () => { success('Path berhasil dibuat!'); setShowForm(false); setTitle(''); setDescription(''); setIcon('route'); setSelectedModules([]); }
    });
  };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const oldIdx = items.indexOf(active.id);
    const newIdx = items.indexOf(over.id);
    const newItems = arrayMove(items, oldIdx, newIdx);
    setItems(newItems);

    router.post('/admin/paths/reorder', { ids: newItems.map(id => String(id)) }, { preserveScroll: true });
  };

  return (
    <AdminLayout title="Learning Path" titleParent="Admin">
      <Head title="Learning Path — BloomFem" />
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h2 className="text-lg font-extrabold text-slate-800">Learning Path</h2>
            <p className="text-xs text-slate-500 mt-0.5">Tarik icon ≡ untuk mengurutkan path. Klik ▼ untuk lihat modul.</p>
          </div>
          <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4" /> Buat Path</Button>
        </div>

        {showForm && (
          <Card>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nama Path</label><input value={title} onChange={e => setTitle(e.target.value)} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" required /></div>
                <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Ikon Path</label>
                  <div className="grid grid-cols-5 gap-2 p-3 bg-sand-50/50 border border-sand-200 rounded-xl">
                    {iconOptions.map(o => {
                      const IC = o.icon; const sel = icon === o.value;
                      return <button key={o.value} type="button" onClick={() => setIcon(o.value)} className={`w-10 h-10 rounded-xl flex items-center justify-center border-2 transition-all ${sel ? 'border-teal-500 bg-teal-50 shadow-sm' : 'border-sand-200 hover:border-sand-300 bg-white'}`} title={o.label}><IC className={`w-5 h-5 ${sel ? 'text-teal-600' : 'text-slate-500'}`} /></button>;
                    })}
                  </div>
                </div>
              </div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Deskripsi</label><textarea value={description} onChange={e => setDescription(e.target.value)} rows={2} className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" /></div>
              <div><label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Pilih Modul</label>
                <div className="space-y-1 max-h-52 overflow-y-auto border border-sand-200 rounded-xl p-2 bg-white">
                  {allModules.length === 0 && <p className="text-xs text-slate-400 p-3 text-center">Semua modul sudah terasosiasi dengan path lain.</p>}
                  {allModules.map(m => (
                    <label key={m.id} className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-teal-50/50 cursor-pointer transition-colors">
                      <input type="checkbox" checked={selectedModules.includes(m.id)} onChange={() => toggleModule(m.id)} className="rounded text-teal-600 focus:ring-teal-500 w-4 h-4" />
                      <BookOpen className="w-4 h-4 text-slate-400 flex-shrink-0" />
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
          ) : (
            <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
              <SortableContext items={items} strategy={verticalListSortingStrategy}>
                {items.map((id, idx) => {
                  const path = paths.find(p => String(p.id) === String(id));
                  if (!path) return null;
                  return <SortablePath key={String(path.id)} path={path} pathModules={pathModules} allModules={allModules} idx={idx} />;
                })}
              </SortableContext>
            </DndContext>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
