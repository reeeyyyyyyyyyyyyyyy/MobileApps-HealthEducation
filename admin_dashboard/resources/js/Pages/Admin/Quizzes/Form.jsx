import React, { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save, Plus, Trash2, HelpCircle, AlertCircle, ChevronDown, ChevronUp } from 'lucide-react';
import { useToast } from '@/hooks/useToast';
import { Button, Input, Select } from '@/Components/UI';

export default function Form({ quiz, modules, preselectedModuleId, preselectedQuestions }) {
  const isEdit = !!quiz;
  const { error, warning } = useToast();
  const [collapsed, setCollapsed] = useState({});

  const { data, setData, post, put, processing, errors } = useForm({
    module_id: quiz?.module_id || preselectedModuleId || (modules.length > 0 ? modules[0].id : ''),
    title: quiz?.title || '',
    xp_reward: quiz?.xp_reward || 100,
    description: quiz?.description || '',
    questions: quiz?.questions
      ? quiz.questions.map(q => ({
          id: q.id,
          question_text: q.question_text || '',
          options: Array.isArray(q.options) ? q.options : ['', '', '', ''],
          correct_index: q.correct_index !== undefined ? q.correct_index : 0,
          explanation: q.explanation || '',
        }))
      : preselectedQuestions?.length > 0
        ? preselectedQuestions.map(q => ({
            question_text: q.question_text || '',
            options: Array.isArray(q.options) ? q.options : ['', '', '', ''],
            correct_index: q.correct_index || 0,
            explanation: q.explanation || '',
          }))
        : []
  });

  React.useEffect(() => {
    const ek = Object.keys(errors);
    if (ek.length > 0) {
      error('Gagal menyimpan kuis!', { description: errors[ek[0]], preset: 'bouncy', duration: 5000 });
    }
  }, [errors, error]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (data.questions.length === 0) {
      warning('Pertanyaan Kosong', { description: 'Tambahkan minimal 1 pertanyaan sebelum menyimpan kuis.', preset: 'bouncy', duration: 4000 });
      return;
    }
    if (isEdit) {
      put(`/admin/quizzes/${quiz.id}`);
    } else {
      post('/admin/quizzes');
    }
  };

  const addQuestion = () => {
    const newIdx = data.questions.length;
    setData('questions', [...data.questions, { question_text: '', options: ['', '', '', ''], correct_index: 0, explanation: '' }]);
    setCollapsed(c => ({ ...c, [newIdx]: false }));
  };

  const removeQuestion = (qIdx) => {
    setData('questions', data.questions.filter((_, i) => i !== qIdx));
    setCollapsed(c => {
      const next = { ...c };
      delete next[qIdx];
      // re-index
      const updated = {};
      Object.keys(next).forEach(k => {
        const i = parseInt(k);
        if (i > qIdx) updated[i - 1] = next[k];
        else updated[i] = next[k];
      });
      return updated;
    });
  };

  const toggleCollapse = (qIdx) => {
    setCollapsed(c => ({ ...c, [qIdx]: !c[qIdx] }));
  };

  const updateQ = (qIdx, f, v) => {
    const u = [...data.questions];
    u[qIdx][f] = v;
    setData('questions', u);
  };

  const updateOpt = (qIdx, oIdx, v) => {
    const u = [...data.questions];
    u[qIdx].options[oIdx] = v;
    setData('questions', u);
  };

  const addOpt = (qIdx) => {
    const u = [...data.questions];
    if (u[qIdx].options.length < 6) {
      u[qIdx].options.push('');
      setData('questions', u);
    }
  };

  const removeOpt = (qIdx, oIdx) => {
    const u = [...data.questions];
    if (u[qIdx].options.length > 2) {
      u[qIdx].options.splice(oIdx, 1);
      if (u[qIdx].correct_index >= u[qIdx].options.length) {
        u[qIdx].correct_index = 0;
      }
      setData('questions', u);
    }
  };

  return (
    <AdminLayout title={isEdit ? 'Edit Kuis Evaluasi' : 'Tambah Kuis Evaluasi'} titleParent="Kuis Evaluasi">
      <Head title={`${isEdit ? 'Edit' : 'Tambah'} Kuis Evaluasi — BloomFem`} />
      <div className="max-w-4xl">
        <Link href="/admin/quizzes" className="inline-flex items-center gap-2 text-xs font-bold text-slate-500 hover:text-slate-800 transition-colors mb-6">
          <ArrowLeft className="w-3.5 h-3.5" /> Kembali ke Daftar Kuis
        </Link>

        <form onSubmit={handleSubmit} className="space-y-8">
          <div className="bg-white border border-sand-200/80 rounded-2xl p-6 shadow-sm">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-6 pb-3 border-b border-sand-100">
              Informasi Kuis
            </h3>
            <div className="space-y-6">
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Judul Kuis</label>
                <Input type="text" value={data.title} onChange={(e) => setData('title', e.target.value)} placeholder="Ketik judul kuis evaluasi..." required error={errors.title} />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Modul Materi Terkait</label>
                  <Select value={data.module_id} onChange={(e) => setData('module_id', e.target.value)} error={errors.module_id} required>
                    <option value="" disabled>Pilih Modul</option>
                    {modules.map(m => (<option key={m.id} value={m.id}>{m.title}</option>))}
                  </Select>
                  {preselectedModuleId && !isEdit && (
                    <p className="text-xs text-teal-600 mt-1 font-semibold">Modul dipilih otomatis dari pembuatan modul sebelumnya.</p>
                  )}
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Hadiah XP Kuis</label>
                  <Input type="number" value={data.xp_reward} onChange={(e) => setData('xp_reward', parseInt(e.target.value) || 0)} placeholder="Contoh: 100" required min="0" error={errors.xp_reward} />
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Deskripsi Kuis</label>
                <textarea value={data.description} onChange={(e) => setData('description', e.target.value)} placeholder="Ketik deskripsi singkat mengenai kuis..." rows="4" className="block w-full px-4 py-3 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all" />
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h3 className="text-sm font-extrabold text-slate-700 tracking-tight flex items-center gap-2">
                <HelpCircle className="w-5 h-5 text-teal-600" />
                Daftar Pertanyaan Kuis ({data.questions.length})
              </h3>
              <button type="button" onClick={addQuestion} className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-bold text-teal-600 bg-teal-50 hover:bg-teal-100 rounded-xl transition-all">
                <Plus className="w-3.5 h-3.5" /> Tambah Soal
              </button>
            </div>

            {errors.questions && (
              <div className="p-4 bg-brick-50 border border-brick-100 rounded-2xl flex items-start gap-3 text-brick-700 text-xs font-bold shadow-sm">
                <AlertCircle className="w-4.5 h-4.5 text-brick-500 flex-shrink-0" />
                <div>{errors.questions}</div>
              </div>
            )}

            {data.questions.map((q, qIdx) => (
              <div key={qIdx} className="bg-white border border-sand-200/80 rounded-2xl shadow-sm overflow-hidden hover:border-teal-200 transition-all duration-200">
                {/* Collapsible Header */}
                <button type="button" onClick={() => toggleCollapse(qIdx)} className="w-full flex items-center justify-between p-4 hover:bg-sand-50 transition-colors">
                  <div className="flex items-center gap-3">
                    <span className="w-8 h-8 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center text-xs font-extrabold">{qIdx + 1}</span>
                    <span className="text-sm font-bold text-slate-700 text-left truncate max-w-xs">
                      {q.question_text || 'Pertanyaan baru'}
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-bold text-slate-400">{q.options.length} opsi</span>
                    {collapsed[qIdx] ? <ChevronDown className="w-4 h-4 text-slate-400" /> : <ChevronUp className="w-4 h-4 text-slate-400" />}
                  </div>
                </button>

                {/* Collapsible Body */}
                {!collapsed[qIdx] && (
                  <div className="px-6 pb-6 pt-2 border-t border-sand-100 space-y-5">
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Pertanyaan</label>
                      <textarea value={q.question_text} onChange={(e) => updateQ(qIdx, 'question_text', e.target.value)} placeholder="Ketik pertanyaan kuis..." rows="2" className="block w-full px-4 py-3 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all" required />
                    </div>

                    <div>
                      <div className="flex justify-between items-center mb-2">
                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider">Pilihan Jawaban (Min 2, Max 6)</label>
                        {q.options.length < 6 && (
                          <button type="button" onClick={() => addOpt(qIdx)} className="text-[10px] font-bold text-teal-600 hover:underline">+ Tambah Pilihan</button>
                        )}
                      </div>
                      <div className="space-y-2">
                        {q.options.map((opt, oIdx) => (
                          <div key={oIdx} className="flex gap-2 items-center">
                            <span className="text-xs font-bold text-slate-300 w-6 text-center">{String.fromCharCode(65 + oIdx)}</span>
                            <input type="text" value={opt} onChange={(e) => updateOpt(qIdx, oIdx, e.target.value)} placeholder={`Ketik opsi ${String.fromCharCode(65 + oIdx)}...`} className="block flex-1 px-4 py-2.5 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all" required />
                            {q.options.length > 2 && (
                              <button type="button" onClick={() => removeOpt(qIdx, oIdx)} className="p-2 text-slate-300 hover:text-brick-600 hover:bg-brick-50 rounded-xl transition-all" title="Hapus Opsi">
                                <Trash2 className="w-3.5 h-3.5" />
                              </button>
                            )}
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                      <div className="md:col-span-1">
                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Jawaban Benar</label>
                        <select value={q.correct_index} onChange={(e) => updateQ(qIdx, 'correct_index', parseInt(e.target.value) || 0)} className="block w-full px-4 py-2.5 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all cursor-pointer bg-white" required>
                          {q.options.map((_, oIdx) => (
                            <option key={oIdx} value={oIdx}>Opsi {String.fromCharCode(65 + oIdx)}</option>
                          ))}
                        </select>
                      </div>
                      <div className="md:col-span-2">
                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Penjelasan Jawaban (Opsional)</label>
                        <input type="text" value={q.explanation} onChange={(e) => updateQ(qIdx, 'explanation', e.target.value)} placeholder="Ketik penjelasan mengapa jawaban ini benar..." className="block w-full px-4 py-2.5 rounded-xl border border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 text-sm font-semibold transition-all" />
                      </div>
                    </div>

                    <div className="flex justify-end">
                      <button type="button" onClick={() => removeQuestion(qIdx)} className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-bold text-brick-600 hover:bg-brick-50 rounded-xl transition-all" title="Hapus Soal">
                        <Trash2 className="w-3.5 h-3.5" /> Hapus Soal
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ))}

            {data.questions.length === 0 && (
              <div className="py-12 bg-white border border-dashed border-sand-200 rounded-2xl flex flex-col items-center justify-center text-center p-6">
                <HelpCircle className="w-10 h-10 text-slate-300 mb-3" />
                <h4 className="text-sm font-bold text-slate-500">Belum ada soal ditambahkan</h4>
                <p className="text-xs text-slate-400 mt-1 mb-4">Tambahkan setidaknya satu soal pilihan ganda untuk kuis ini.</p>
                <button type="button" onClick={addQuestion} className="inline-flex items-center gap-1.5 px-4 py-2 text-xs font-bold text-white bg-teal-600 hover:bg-teal-700 rounded-xl transition-all shadow-md shadow-teal-200">
                  <Plus className="w-3.5 h-3.5" /> Tambah Soal Pertama
                </button>
              </div>
            )}
          </div>

          <div className="flex justify-end gap-3 pt-6 border-t border-sand-200">
            <Link href="/admin/quizzes" className="px-5 py-2.5 rounded-xl border border-sand-200 text-slate-500 hover:text-slate-700 hover:bg-sand-50 text-sm font-bold active:scale-98 transition-all">Batalkan</Link>
            <Button type="submit" disabled={processing || data.questions.length === 0}>
              <Save className="w-4 h-4" /> {isEdit ? 'Perbarui Kuis' : 'Simpan Kuis'}
            </Button>
          </div>
        </form>
      </div>
    </AdminLayout>
  );
}