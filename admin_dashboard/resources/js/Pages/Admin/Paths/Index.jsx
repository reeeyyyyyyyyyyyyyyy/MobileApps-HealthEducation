import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, BookOpen, ArrowUp, ArrowDown, Route, Droplets, Hand, FlaskConical, Brain, Heart, Shield, Sparkles, Award, Compass, Layers } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Card, Badge } from '@/Components/UI';

const iconOptions = [
  { value: 'route', label: 'Route', icon: Route },
  { value: 'water_drop', label: 'Tetes Air', icon: Droplets },
  { value: 'clean_hands', label: 'Kebersihan', icon: Hand },
  { value: 'biotech', label: 'Biologi & Sains', icon: FlaskConical },
  { value: 'psychology', label: 'Psikologi', icon: Brain },
  { value: 'heart', label: 'Kesehatan', icon: Heart },
  { value: 'shield', label: 'Perlindungan', icon: Shield },
  { value: 'sparkles', label: 'Fitur Utama', icon: Sparkles },
  { value: 'award', label: 'Prestasi', icon: Award },
  { value: 'compass', label: 'Panduan', icon: Compass },
  { value: 'layers', label: 'Tingkatan', icon: Layers },
];

export default function Index({ paths, allModules, pathModules }) {
  const { success, warning } = useToast();
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [icon, setIcon] = useState('route');
  const [selectedModules, setSelectedModules] = useState([]);

  const toggleModule = (id) => setSelectedModules(prev => prev.includes(id) ? prev.filter(p => p !== id) : [...prev, id]);

  const handleSubmit = (e) => {
    e.preventDefault();
    router.post('/admin/paths', { title, description, icon, module_ids: selectedModules }, {
      onSuccess: () => { 
        success('Learning Path berhasil dibuat!'); 
        setShowForm(false); 
        setTitle(''); 
        setDescription(''); 
        setIcon('route'); 
        setSelectedModules([]); 
      }
    });
  };

  const swapOrder = (id, direction) => {
    router.put(`/admin/paths/${id}/order`, { direction }, { preserveScroll: true });
  };

  const renderPathIcon = (iconName) => {
    const found = iconOptions.find(o => o.value === iconName);
    const IconComp = found ? found.icon : Route;
    return <IconComp className="w-4 h-4 text-teal-600" />;
  };

  return (
    <AdminLayout title="Learning Path" titleParent="Admin">
      <Head title="Learning Path — BloomFem" />
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h2 className="text-lg font-extrabold text-slate-800">Learning Path</h2>
            <p className="text-xs text-slate-500 mt-0.5">Kelola urutan dan isi kurikulum belajar bertahap untuk aplikasi Flutter.</p>
          </div>
          <Button onClick={() => setShowForm(!showForm)} className="bg-teal-600 hover:bg-teal-700 text-white">
            <Plus className="w-4 h-4 mr-1" /> Buat Path Baru
          </Button>
        </div>

        {showForm && (
          <Card className="border-2 border-teal-500/20 bg-white">
            <form onSubmit={handleSubmit} className="space-y-5">
              <h3 className="text-sm font-extrabold text-slate-800 border-b border-sand-100 pb-3">Tambah Learning Path</h3>
              
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nama Path</label>
                <input 
                  value={title} 
                  onChange={e => setTitle(e.target.value)} 
                  placeholder="Contoh: Dasar Menstruasi"
                  className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" 
                  required 
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Pilih Ikon Visual Path</label>
                <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-11 gap-2 p-3 bg-sand-50/50 border border-sand-200 rounded-xl">
                  {iconOptions.map(o => {
                    const IconComp = o.icon;
                    const isSelected = icon === o.value;
                    return (
                      <button 
                        key={o.value} 
                        type="button" 
                        onClick={() => setIcon(o.value)}
                        className={`flex flex-col items-center justify-center p-2.5 rounded-xl border-2 transition-all cursor-pointer ${
                          isSelected ? 'border-teal-600 bg-teal-50 shadow-sm text-teal-700' : 'border-sand-200 bg-white hover:border-sand-300 text-slate-600'
                        }`}
                        title={o.label}
                      >
                        <IconComp className={`w-5 h-5 mb-1 ${isSelected ? 'text-teal-600' : 'text-slate-500'}`} />
                        <span className="text-[9px] font-bold truncate max-w-full">{o.label}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Deskripsi Path</label>
                <textarea 
                  value={description} 
                  onChange={e => setDescription(e.target.value)} 
                  rows={2} 
                  placeholder="Jelaskan ringkasan materi dalam path ini..."
                  className="w-full px-4 py-2.5 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 outline-none" 
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Pilih Modul untuk Path ini</label>
                <div className="space-y-1 max-h-52 overflow-y-auto border border-sand-200 rounded-xl p-2 bg-white">
                  {allModules.length === 0 && <p className="text-xs text-slate-400 p-3 text-center">Semua modul publikasi sudah terasosiasi dengan path lain.</p>}
                  {allModules.map(m => (
                    <label key={m.id} className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-teal-50/50 cursor-pointer transition-colors">
                      <input 
                        type="checkbox" 
                        checked={selectedModules.includes(m.id)} 
                        onChange={() => toggleModule(m.id)} 
                        className="rounded text-teal-600 focus:ring-teal-500 w-4 h-4" 
                      />
                      <BookOpen className="w-4 h-4 text-teal-600" />
                      <span className="text-sm font-semibold text-slate-700">{m.title}</span>
                    </label>
                  ))}
                </div>
              </div>

              <div className="flex justify-end gap-3 pt-3 border-t border-sand-100">
                <Button variant="outline" onClick={() => setShowForm(false)}>Batal</Button>
                <Button type="submit" className="bg-teal-600 hover:bg-teal-700 text-white">Simpan Path</Button>
              </div>
            </form>
          </Card>
        )}

        <div className="space-y-3">
          {paths.length === 0 ? (
            <Card className="text-center py-12"><p className="text-sm font-bold text-slate-500">Belum ada learning path.</p></Card>
          ) : paths.map((path, idx) => {
            const pmIds = pathModules.filter(pm => pm.path_id === path.id).map(pm => pm.module_id);
            return (
              <Card key={path?.id || `path-${idx}`} className="hover:border-teal-500/30 transition-all shadow-sm">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1.5">
                      <div className="w-7 h-7 rounded-lg bg-teal-50 border border-teal-100 flex items-center justify-center">
                        {renderPathIcon(path.icon)}
                      </div>
                      <Badge variant="teal">Urutan #{path.sort_order}</Badge>
                    </div>
                    <h4 className="text-base font-extrabold text-slate-800">{path.title}</h4>
                    {path.description && <p className="text-xs text-slate-500 mt-1 font-medium">{path.description}</p>}
                    <div className="mt-3 flex items-center gap-2">
                      <Badge variant="default" className="bg-sand-100 text-slate-700 font-bold">{pmIds.length} Modul Ditautkan</Badge>
                    </div>
                  </div>

                  <div className="flex items-center gap-1.5 bg-sand-50 p-1.5 rounded-xl border border-sand-200">
                    <div className="flex flex-col gap-1">
                      {idx > 0 && (
                        <button 
                          onClick={() => swapOrder(path.id, 'up')} 
                          className="p-1.5 text-slate-600 hover:bg-teal-50 hover:text-teal-600 rounded-lg transition-colors" 
                          title="Naikkan Urutan"
                        >
                          <ArrowUp className="w-4 h-4" />
                        </button>
                      )}
                      {idx < paths.length - 1 && (
                        <button 
                          onClick={() => swapOrder(path.id, 'down')} 
                          className="p-1.5 text-slate-600 hover:bg-teal-50 hover:text-teal-600 rounded-lg transition-colors" 
                          title="Turunkan Urutan"
                        >
                          <ArrowDown className="w-4 h-4" />
                        </button>
                      )}
                    </div>

                    <Button 
                      variant="ghost" 
                      size="sm" 
                      onClick={() => { 
                        warning('Hapus Path?', { 
                          description: `"${path.title}" akan dihapus dari daftar path.`, 
                          action: { 
                            label: 'Ya, Hapus', 
                            onClick: () => router.delete(`/admin/paths/${path.id}`) 
                          } 
                        }); 
                      }}
                      className="text-brick-500 hover:bg-brick-50 hover:text-brick-600"
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
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
