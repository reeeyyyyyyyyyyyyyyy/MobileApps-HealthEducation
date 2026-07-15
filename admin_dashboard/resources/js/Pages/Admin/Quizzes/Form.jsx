import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save, Plus, Trash2, HelpCircle, AlertCircle } from 'lucide-react';

import { gooeyToast } from 'goey-toast';

export default function Form({ quiz, modules }) {
    const isEdit = !!quiz;

    const { data, setData, post, put, processing, errors } = useForm({
        module_id: quiz?.module_id || (modules.length > 0 ? modules[0].id : ''),
        title: quiz?.title || '',
        xp_reward: quiz?.xp_reward || 100,
        description: quiz?.description || '',
        // Format questions for React state
        questions: quiz?.questions ? quiz.questions.map(q => ({
            id: q.id, // Keep ID if edit
            question_text: q.question_text || '',
            options: Array.isArray(q.options) ? q.options : ['', '', '', ''],
            correct_index: q.correct_index !== undefined ? q.correct_index : 0,
            explanation: q.explanation || '',
        })) : []
    });

    React.useEffect(() => {
        const errorKeys = Object.keys(errors);
        if (errorKeys.length > 0) {
            gooeyToast.error('Gagal menyimpan kuis!', {
                description: errors[errorKeys[0]],
                preset: 'bouncy',
                duration: 5000
            });
        }
    }, [errors]);

    const handleSubmit = (e) => {
        e.preventDefault();
        
        if (data.questions.length === 0) {
            gooeyToast.warning('Pertanyaan Kosong', {
                description: 'Tambahkan minimal 1 pertanyaan sebelum menyimpan kuis.',
                preset: 'bouncy',
                duration: 4000
            });
            return;
        }

        if (isEdit) {
            put(`/admin/quizzes/${quiz.id}`);
        } else {
            post('/admin/quizzes');
        }
    };

    // Question Repeater Actions
    const addQuestion = () => {
        const newQuestion = {
            question_text: '',
            options: ['', '', '', ''],
            correct_index: 0,
            explanation: '',
        };
        setData('questions', [...data.questions, newQuestion]);
    };

    const removeQuestion = (qIndex) => {
        setData('questions', data.questions.filter((_, idx) => idx !== qIndex));
    };

    const updateQuestionField = (qIndex, field, value) => {
        const updated = [...data.questions];
        updated[qIndex][field] = value;
        setData('questions', updated);
    };

    // Option Repeater Actions
    const updateOptionText = (qIndex, oIndex, value) => {
        const updated = [...data.questions];
        updated[qIndex].options[oIndex] = value;
        setData('questions', updated);
    };

    const addOption = (qIndex) => {
        const updated = [...data.questions];
        if (updated[qIndex].options.length < 6) {
            updated[qIndex].options.push('');
            setData('questions', updated);
        }
    };

    const removeOption = (qIndex, oIndex) => {
        const updated = [...data.questions];
        if (updated[qIndex].options.length > 2) {
            updated[qIndex].options.splice(oIndex, 1);
            // Adjust correct_index if out of bounds
            if (updated[qIndex].correct_index >= updated[qIndex].options.length) {
                updated[qIndex].correct_index = 0;
            }
            setData('questions', updated);
        }
    };

    return (
        <AdminLayout title={isEdit ? 'Edit Kuis Evaluasi' : 'Tambah Kuis Evaluasi'} titleParent="Kuis Evaluasi">
            <Head title={`${isEdit ? 'Edit' : 'Tambah'} Kuis Evaluasi — BloomFem`} />

            <div className="max-w-4xl">
                <Link
                    href="/admin/quizzes"
                    className="inline-flex items-center gap-2 text-xs font-bold text-slate-500 hover:text-slate-800 transition-colors mb-6"
                >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Kembali ke Daftar Kuis
                </Link>

                <form onSubmit={handleSubmit} className="space-y-8">
                    {/* Section 1: Quiz Meta Info */}
                    <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm">
                        <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-6 pb-3 border-b border-slate-100">
                            Informasi Kuis
                        </h3>
                        <div className="space-y-6">
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Judul Kuis
                                </label>
                                <input
                                    type="text"
                                    value={data.title}
                                    onChange={(e) => setData('title', e.target.value)}
                                    placeholder="Ketik judul kuis evaluasi..."
                                    className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                        errors.title ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                    required
                                />
                                {errors.title && (
                                    <p className="text-xs font-bold text-rose-500 mt-2">{errors.title}</p>
                                )}
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {/* Associated Module */}
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                        Modul Materi Terkait
                                    </label>
                                    <select
                                        value={data.module_id}
                                        onChange={(e) => setData('module_id', e.target.value)}
                                        className="block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all cursor-pointer bg-white"
                                        required
                                    >
                                        <option value="" disabled>Pilih Modul</option>
                                        {modules.map((m) => (
                                            <option key={m.id} value={m.id}>
                                                {m.title}
                                            </option>
                                        ))}
                                    </select>
                                    {errors.module_id && (
                                        <p className="text-xs font-bold text-rose-500 mt-2">{errors.module_id}</p>
                                    )}
                                </div>

                                {/* XP Reward */}
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                        Hadiah XP Kuis
                                    </label>
                                    <input
                                        type="number"
                                        value={data.xp_reward}
                                        onChange={(e) => setData('xp_reward', parseInt(e.target.value) || 0)}
                                        placeholder="Contoh: 100"
                                        className={`block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                            errors.xp_reward ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                        }`}
                                        required
                                        min="0"
                                    />
                                    {errors.xp_reward && (
                                        <p className="text-xs font-bold text-rose-500 mt-2">{errors.xp_reward}</p>
                                    )}
                                </div>
                            </div>

                            {/* Description */}
                            <div>
                                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                    Deskripsi Kuis
                                </label>
                                <textarea
                                    value={data.description}
                                    onChange={(e) => setData('description', e.target.value)}
                                    placeholder="Ketik deskripsi singkat mengenai kuis..."
                                    rows="4"
                                    className="block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Section 2: Question Repeater */}
                    <div className="space-y-6">
                        <div className="flex justify-between items-center">
                            <h3 className="text-sm font-extrabold text-slate-700 tracking-tight flex items-center gap-2">
                                <HelpCircle className="w-5 h-5 text-violet-500" />
                                Daftar Pertanyaan Kuis ({data.questions.length})
                            </h3>
                            <button
                                type="button"
                                onClick={addQuestion}
                                className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-bold text-violet-600 bg-violet-50 hover:bg-violet-100 rounded-xl transition-all"
                            >
                                <Plus className="w-3.5 h-3.5" />
                                Tambah Soal
                            </button>
                        </div>

                        {errors.questions && (
                            <div className="p-4 bg-rose-50 border border-rose-100 rounded-2xl flex items-start gap-3 text-rose-700 text-xs font-bold shadow-sm">
                                <AlertCircle className="w-4.5 h-4.5 text-rose-500 flex-shrink-0" />
                                <div>{errors.questions}</div>
                            </div>
                        )}

                        {data.questions.map((q, qIdx) => (
                            <div key={qIdx} className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm relative group hover:border-violet-200 transition-all duration-200">
                                {/* Remove Question Button */}
                                <button
                                    type="button"
                                    onClick={() => removeQuestion(qIdx)}
                                    className="absolute top-4 right-4 p-2 text-slate-300 hover:bg-rose-50 hover:text-rose-600 rounded-xl transition-all"
                                    title="Hapus Soal"
                                >
                                    <Trash2 className="w-4 h-4" />
                                </button>

                                <span className="inline-block text-[10px] font-bold tracking-widest text-slate-400 uppercase bg-slate-100 px-3 py-1 rounded-lg mb-4">
                                    Soal ke-{qIdx + 1}
                                </span>

                                <div className="space-y-5">
                                    {/* Question Text */}
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                            Pertanyaan
                                        </label>
                                        <textarea
                                            value={q.question_text}
                                            onChange={(e) => updateQuestionField(qIdx, 'question_text', e.target.value)}
                                            placeholder="Ketik pertanyaan kuis..."
                                            rows="2"
                                            className="block w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                                            required
                                        />
                                    </div>

                                    {/* Options Repeater */}
                                    <div>
                                        <div className="flex justify-between items-center mb-2">
                                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider">
                                                Pilihan Jawaban (Min 2, Max 6)
                                            </label>
                                            {q.options.length < 6 && (
                                                <button
                                                    type="button"
                                                    onClick={() => addOption(qIdx)}
                                                    className="text-[10px] font-bold text-violet-600 hover:underline"
                                                >
                                                    + Tambah Pilihan
                                                </button>
                                            )}
                                        </div>

                                        <div className="space-y-2">
                                            {q.options.map((opt, oIdx) => (
                                                <div key={oIdx} className="flex gap-2 items-center">
                                                    <span className="text-xs font-bold text-slate-300 w-6 text-center">
                                                        {String.fromCharCode(65 + oIdx)}
                                                    </span>
                                                    <input
                                                        type="text"
                                                        value={opt}
                                                        onChange={(e) => updateOptionText(qIdx, oIdx, e.target.value)}
                                                        placeholder={`Ketik opsi ${String.fromCharCode(65 + oIdx)}...`}
                                                        className="block flex-1 px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                                                        required
                                                    />
                                                    {q.options.length > 2 && (
                                                        <button
                                                            type="button"
                                                            onClick={() => removeOption(qIdx, oIdx)}
                                                            className="p-2 text-slate-300 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-all"
                                                            title="Hapus Opsi"
                                                        >
                                                            <Trash2 className="w-3.5 h-3.5" />
                                                        </button>
                                                    )}
                                                </div>
                                            ))}
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                                        {/* Correct Option Index */}
                                        <div className="md:col-span-1">
                                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                                Jawaban Benar
                                            </label>
                                            <select
                                                value={q.correct_index}
                                                onChange={(e) => updateQuestionField(qIdx, 'correct_index', parseInt(e.target.value) || 0)}
                                                className="block w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all cursor-pointer bg-white"
                                                required
                                            >
                                                {q.options.map((_, oIdx) => (
                                                    <option key={oIdx} value={oIdx}>
                                                        Opsi {String.fromCharCode(65 + oIdx)} (Indeks {oIdx})
                                                    </option>
                                                ))}
                                            </select>
                                        </div>

                                        {/* Explanation */}
                                        <div className="md:col-span-2">
                                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                                Penjelasan Jawaban (Opsional)
                                            </label>
                                            <input
                                                type="text"
                                                value={q.explanation}
                                                onChange={(e) => updateQuestionField(qIdx, 'explanation', e.target.value)}
                                                placeholder="Ketik penjelasan mengapa jawaban ini benar..."
                                                className="block w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all"
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))}

                        {data.questions.length === 0 && (
                            <div className="py-12 bg-white border border-dashed border-slate-200 rounded-2xl flex flex-col items-center justify-center text-center p-6">
                                <HelpCircle className="w-10 h-10 text-slate-300 mb-3" />
                                <h4 className="text-sm font-bold text-slate-500">Belum ada soal ditambahkan</h4>
                                <p className="text-xs text-slate-400 mt-1 mb-4">Tambahkan setidaknya satu soal pilihan ganda untuk kuis ini.</p>
                                <button
                                    type="button"
                                    onClick={addQuestion}
                                    className="inline-flex items-center gap-1.5 px-4 py-2 text-xs font-bold text-white bg-violet-600 hover:bg-violet-700 rounded-xl transition-all shadow-md shadow-violet-100"
                                >
                                    <Plus className="w-3.5 h-3.5" />
                                    Tambah Soal Pertama
                                </button>
                            </div>
                        )}
                    </div>

                    {/* Action buttons */}
                    <div className="flex justify-end gap-3 pt-6 border-t border-slate-200">
                        <Link
                            href="/admin/quizzes"
                            className="px-5 py-2.5 rounded-xl border border-slate-200 text-slate-500 hover:text-slate-700 hover:bg-slate-50 text-sm font-bold active:scale-98 transition-all"
                        >
                            Batalkan
                        </Link>
                        <button
                            type="submit"
                            disabled={processing || data.questions.length === 0}
                            className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-98 transition-all rounded-xl shadow-md shadow-violet-100 disabled:opacity-50"
                        >
                            <Save className="w-4 h-4" />
                            {isEdit ? 'Perbarui Kuis' : 'Simpan Kuis'}
                        </button>
                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
