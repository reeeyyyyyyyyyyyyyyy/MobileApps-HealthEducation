import React from 'react';
import { Link, Head, usePage } from '@inertiajs/react';
import { BookOpen, HelpCircle, AlertTriangle, ArrowRight } from 'lucide-react';
import { motion } from 'framer-motion';

const GithubIcon = (props) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
        <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
    </svg>
);

export default function Welcome() {
    const { auth } = usePage().props;

    return (
        <div className="min-h-screen bg-slate-50 text-slate-800 flex flex-col justify-between relative overflow-hidden font-sans select-none">
            <Head title="BloomFem — Portal Administrasi" />

            {/* Background Animated Gradient Mesh */}
            <div className="absolute inset-0 pointer-events-none z-0">
                <motion.div 
                    animate={{
                        x: [0, -30, 0],
                        y: [0, 20, 0],
                        scale: [1, 1.05, 1]
                    }}
                    transition={{
                        duration: 15,
                        repeat: Infinity,
                        ease: "easeInOut"
                    }}
                    className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] rounded-full bg-violet-600/5 blur-[120px]"
                />
                <motion.div 
                    animate={{
                        x: [0, 40, 0],
                        y: [0, -30, 0],
                        scale: [1, 1.1, 1]
                    }}
                    transition={{
                        duration: 18,
                        repeat: Infinity,
                        ease: "easeInOut"
                    }}
                    className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-indigo-600/5 blur-[100px]"
                />
            </div>

            {/* Header */}
            <header className="relative z-10 w-full max-w-6xl mx-auto px-6 py-6 flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-violet-600 to-indigo-600 flex items-center justify-center text-white font-extrabold text-lg shadow-md shadow-violet-200">
                        B
                    </div>
                    <span className="font-extrabold tracking-tight text-lg text-slate-800">BloomFem</span>
                </div>
                <div>
                    {auth?.user ? (
                        <Link 
                            href="/admin" 
                            className="inline-flex items-center px-4 py-2 text-sm font-semibold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-md shadow-violet-200"
                        >
                            Buka Dasbor
                        </Link>
                    ) : (
                        <Link 
                            href="/admin/login" 
                            className="inline-flex items-center px-4 py-2 text-sm font-semibold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-md shadow-violet-200"
                        >
                            Masuk Admin
                        </Link>
                    )}
                </div>
            </header>

            {/* Hero Section */}
            <main className="relative z-10 w-full max-w-4xl mx-auto px-6 py-12 flex-grow flex flex-col justify-center text-center">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6 }}
                >
                    <span className="inline-block text-[11px] font-bold tracking-widest text-violet-600 border-1.5 border-violet-100 bg-violet-50/50 px-4 py-1.5 rounded-full uppercase mb-6 shadow-sm">
                        Portal Administrasi
                    </span>
                </motion.div>

                <motion.h1 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.1 }}
                    className="text-4xl sm:text-6xl font-extrabold tracking-tight text-slate-900 leading-[1.08]"
                >
                    Kelola Layanan<br />
                    <span className="bg-gradient-to-r from-violet-600 to-indigo-600 bg-clip-text text-transparent">Kesehatan Edukasi</span>
                </motion.h1>

                <motion.p 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.2 }}
                    className="mt-6 text-base sm:text-lg text-slate-500 leading-relaxed max-w-xl mx-auto font-medium"
                >
                    Sistem dasbor terpusat untuk memoderasi forum komunitas, meninjau laporan, dan menganalisis statistik kuis serta modul secara real-time.
                </motion.p>

                <motion.div 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.3 }}
                    className="mt-8 flex flex-wrap justify-center items-center gap-4"
                >
                    {auth?.user ? (
                        <Link 
                            href="/admin" 
                            className="inline-flex items-center gap-2 px-6 py-3 font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-violet-200"
                        >
                            Masuk Dasbor Panel
                            <ArrowRight className="w-4 h-4" />
                        </Link>
                    ) : (
                        <Link 
                            href="/admin/login" 
                            className="inline-flex items-center gap-2 px-6 py-3 font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-violet-200"
                        >
                            Autentikasi Sekarang
                            <ArrowRight className="w-4 h-4" />
                        </Link>
                    )}
                    <a 
                        href="https://github.com/reeeyyyyyyyyyyyyyyy/MobileApps-HealthEducation" 
                        target="_blank" 
                        rel="noreferrer" 
                        className="inline-flex items-center gap-2 px-6 py-3 font-bold text-slate-600 border border-slate-200 hover:border-violet-200 hover:bg-violet-50/20 rounded-xl transition-all"
                    >
                        <GithubIcon className="w-4 h-4" />
                        Github Repositori
                    </a>
                </motion.div>
            </main>

            {/* Features Grid */}
            <section className="relative z-10 w-full max-w-6xl mx-auto px-6 pb-16 grid grid-cols-1 md:grid-cols-3 gap-6">
                <motion.div 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.4 }}
                    className="p-8 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-violet-200 transition-all duration-300"
                >
                    <div className="w-10 h-10 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center mb-5">
                        <BookOpen className="w-5 h-5" />
                    </div>
                    <h3 className="font-bold text-slate-800 text-[15px] mb-2">Manajemen Modul</h3>
                    <p className="text-xs text-slate-400 font-medium leading-relaxed">
                        Kelola konten edukasi kesehatan reproduksi dengan editor lengkap, pengelompokan kategori, dan pemantauan jumlah pembaca.
                    </p>
                </motion.div>

                <motion.div 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.5 }}
                    className="p-8 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-emerald-200 transition-all duration-300"
                >
                    <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center mb-5">
                        <HelpCircle className="w-5 h-5" />
                    </div>
                    <h3 className="font-bold text-slate-800 text-[15px] mb-2">Kuis Interaktif</h3>
                    <p className="text-xs text-slate-400 font-medium leading-relaxed">
                        Buat kuis evaluasi pemahaman dengan pembuatan pertanyaan dinamis, penilaian otomatis, dan XP rewards.
                    </p>
                </motion.div>

                <motion.div 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.6 }}
                    className="p-8 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-rose-200 transition-all duration-300"
                >
                    <div className="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center mb-5">
                        <AlertTriangle className="w-5 h-5" />
                    </div>
                    <h3 className="font-bold text-slate-800 text-[15px] mb-2">Moderasi Laporan</h3>
                    <p className="text-xs text-slate-400 font-medium leading-relaxed">
                        Tinjau dan ambil tindakan cepat terhadap pelanggaran forum, dengan integrasi ekspor data CSV terunduh instan.
                    </p>
                </motion.div>
            </section>

            {/* Footer */}
            <footer className="relative z-10 w-full max-w-6xl mx-auto px-6 py-8 border-t border-slate-200/60 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs font-semibold text-slate-400">
                <div>&copy; {new Date().getFullYear()} BloomFem Project. Seluruh hak cipta dilindungi.</div>
                <div className="flex gap-4 font-mono text-[10px] tracking-wide">
                    <span>Laravel App</span>
                    <span>React + Inertia</span>
                </div>
            </footer>
        </div>
    );
}
