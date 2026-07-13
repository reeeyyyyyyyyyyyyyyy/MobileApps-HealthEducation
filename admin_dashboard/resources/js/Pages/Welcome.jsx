import React, { useState, useEffect } from 'react';
import { Link, Head, usePage } from '@inertiajs/react';
import { BookOpen, HelpCircle, AlertTriangle, ArrowRight, Calendar, Heart, ShieldAlert, Sparkles, MessageSquare } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const GithubIcon = (props) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
        <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
    </svg>
);

export default function Welcome() {
    const { auth } = usePage().props;
    const [loading, setLoading] = useState(true);
    const [progress, setProgress] = useState(0);

    // Simulate Splash Screen Loading
    useEffect(() => {
        const interval = setInterval(() => {
            setProgress((prev) => {
                if (prev >= 100) {
                    clearInterval(interval);
                    setTimeout(() => setLoading(false), 300);
                    return 100;
                }
                return prev + 4;
            });
        }, 50);

        return () => clearInterval(interval);
    }, []);

    // Mockup Cards representing BloomFem application screens
    const appMockups = [
        {
            title: "Pelacak Hari Haid",
            category: "Kesehatan Reproduksi",
            icon: Calendar,
            content: (
                <div className="space-y-3 font-sans">
                    <div className="flex justify-between items-center text-[10px] font-bold text-slate-400">
                        <span>JUNI 2026</span>
                        <span className="text-violet-600">MENSTRUASI HARI KE-3</span>
                    </div>
                    <div className="grid grid-cols-7 gap-1.5 text-center text-xs font-bold">
                        <span className="text-slate-300">S</span><span className="text-slate-300">S</span><span className="text-slate-300">R</span><span className="text-slate-300">K</span><span className="text-slate-300">J</span><span className="text-slate-300">S</span><span className="text-slate-300">M</span>
                        <span className="text-slate-300">1</span><span className="text-slate-300">2</span>
                        <span className="w-6 h-6 rounded-full bg-violet-600 text-white flex items-center justify-center mx-auto shadow-sm shadow-violet-200">3</span>
                        <span className="w-6 h-6 rounded-full bg-violet-500 text-white flex items-center justify-center mx-auto">4</span>
                        <span className="w-6 h-6 rounded-full bg-violet-400 text-white flex items-center justify-center mx-auto">5</span>
                        <span className="text-slate-600 flex items-center justify-center">6</span>
                        <span className="text-slate-600 flex items-center justify-center">7</span>
                    </div>
                    <div className="bg-violet-50/50 border border-violet-100/50 rounded-xl p-2.5 text-[10px] font-semibold text-violet-700 flex items-center gap-2">
                        <Sparkles className="w-3.5 h-3.5 flex-shrink-0" />
                        Prediksi siklus berikutnya dalam 25 hari.
                    </div>
                </div>
            )
        },
        {
            title: "Forum Diskusi",
            category: "Komunitas Komunitas",
            icon: MessageSquare,
            content: (
                <div className="space-y-3">
                    <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded-full bg-rose-100 flex items-center justify-center text-rose-700 font-bold text-[10px]">A</div>
                        <div>
                            <span className="block text-[10px] font-bold text-slate-700">@anissa_rahma</span>
                            <span className="block text-[8px] text-slate-400 leading-none">2 jam yang lalu</span>
                        </div>
                    </div>
                    <p className="text-[11px] font-semibold text-slate-500 leading-normal line-clamp-2">
                        Apakah wajar jika mengalami nyeri pinggul yang parah saat hari pertama siklus haid?
                    </p>
                    <div className="flex items-center gap-3 text-[9px] font-bold text-slate-400">
                        <span className="flex items-center gap-1"><Heart className="w-3 h-3 text-rose-500 fill-rose-500" /> 18 Suka</span>
                        <span className="flex items-center gap-1"><MessageSquare className="w-3 h-3" /> 5 Balasan</span>
                    </div>
                </div>
            )
        },
        {
            title: "Mitos vs Fakta Siklus",
            category: "Modul Edukasi",
            icon: BookOpen,
            content: (
                <div className="space-y-2.5">
                    <div className="w-full h-20 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 overflow-hidden relative">
                        <div className="absolute inset-0 bg-gradient-to-tr from-violet-500/20 to-indigo-500/20" />
                        <BookOpen className="w-8 h-8 text-violet-500/60 z-10" />
                    </div>
                    <h5 className="text-xs font-bold text-slate-800 leading-snug">
                        Memahami PMS dan Hubungannya dengan Hormon
                    </h5>
                    <div className="flex items-center justify-between text-[9px] font-bold text-slate-400">
                        <span>KATEGORI: PENGETAHUAN</span>
                        <span>⏱️ 5 MENIT</span>
                    </div>
                </div>
            )
        },
        {
            title: "Evaluasi Pemahaman",
            category: "Kuis Edukasi",
            icon: HelpCircle,
            content: (
                <div className="space-y-3">
                    <span className="inline-block text-[9px] font-bold text-slate-400">SOAL KE-2 DARI 5</span>
                    <p className="text-[11px] font-bold text-slate-700 leading-snug">
                        Berapa durasi rata-rata siklus haid yang normal?
                    </p>
                    <div className="space-y-1.5">
                        <div className="px-3 py-1.5 rounded-lg border border-emerald-100 bg-emerald-50 text-emerald-700 text-[10px] font-bold flex justify-between">
                            <span>A. 21 s.d. 35 hari</span>
                            <span>PILIHAN BENAR</span>
                        </div>
                        <div className="px-3 py-1.5 rounded-lg border border-slate-100 bg-slate-50 text-slate-400 text-[10px] font-semibold">
                            B. 10 s.d. 15 hari
                        </div>
                    </div>
                </div>
            )
        },
    ];

    // Double mockups to create seamless loop
    const marqueeMockups = [...appMockups, ...appMockups, ...appMockups];

    return (
        <div className="min-h-screen bg-slate-50 text-slate-800 flex flex-col justify-between relative overflow-hidden font-sans select-none">
            <Head title="BloomFem — Portal Administrasi" />

            <AnimatePresence>
                {/* ── Splash Screen ────────────────────────────────── */}
                {loading && (
                    <motion.div
                        key="splash"
                        initial={{ opacity: 1 }}
                        exit={{ opacity: 0, y: -40 }}
                        transition={{ duration: 0.5, ease: "easeInOut" }}
                        className="fixed inset-0 bg-slate-900 z-50 flex flex-col items-center justify-center"
                    >
                        <div className="flex flex-col items-center">
                            {/* Breathing App Icon Logo */}
                            <motion.div
                                animate={{ 
                                    scale: [0.93, 1.05, 0.93]
                                }}
                                transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                                className="w-24 h-24 rounded-3xl overflow-hidden shadow-xl shadow-violet-500/20 border border-white/10"
                            >
                                <img 
                                    src="/bloomfem_app_icon.png" 
                                    alt="BloomFem Logo" 
                                    className="w-full h-full object-cover"
                                />
                            </motion.div>

                            <h2 className="text-white font-extrabold text-lg tracking-tight mt-5">
                                BloomFem
                            </h2>
                            <p className="text-slate-400 text-[10px] font-bold tracking-widest uppercase mt-1.5">
                                Portal Administrasi
                            </p>

                            {/* Minimal Loading Bar */}
                            <div className="w-36 h-1 bg-slate-800 rounded-full overflow-hidden mt-8">
                                <motion.div 
                                    className="h-full bg-violet-500"
                                    style={{ width: `${progress}%` }}
                                />
                            </div>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>

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
                    <div className="w-8 h-8 rounded-xl overflow-hidden shadow-sm border border-slate-200/50">
                        <img 
                            src="/bloomfem_app_icon.png" 
                            alt="Logo" 
                            className="w-full h-full object-cover"
                        />
                    </div>
                    <span className="font-extrabold tracking-tight text-lg text-slate-800">
                        BloomFem
                    </span>
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
            <main className="relative z-10 w-full max-w-4xl mx-auto px-6 py-8 flex-grow flex flex-col justify-center text-center">
                <motion.div
                    initial={{ opacity: 0, y: 15 }}
                    animate={!loading ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.5 }}
                >
                    <span className="inline-block text-[11px] font-bold tracking-widest text-violet-600 border border-violet-100 bg-violet-50/50 px-4 py-1.5 rounded-full uppercase mb-5 shadow-sm">
                        Layanan Kesehatan Reproduksi & Edukasi
                    </span>
                </motion.div>

                <motion.h1 
                    initial={{ opacity: 0, y: 15 }}
                    animate={!loading ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.5, delay: 0.1 }}
                    className="text-4xl sm:text-6xl font-extrabold tracking-tight text-slate-900 leading-[1.08]"
                >
                    Portal Pengelolaan<br />
                    <span className="bg-gradient-to-r from-violet-600 to-indigo-600 bg-clip-text text-transparent">Layanan BloomFem</span>
                </motion.h1>

                <motion.p 
                    initial={{ opacity: 0, y: 15 }}
                    animate={!loading ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.5, delay: 0.2 }}
                    className="mt-5 text-base text-slate-500 leading-relaxed max-w-xl mx-auto font-medium"
                >
                    Modul manajemen terintegrasi untuk meninjau kuis, progres edukasi, pelacakan siklus bulanan, serta perlindungan moderasi forum bagi pengguna BloomFem.
                </motion.p>

                <motion.div 
                    initial={{ opacity: 0, y: 15 }}
                    animate={!loading ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.5, delay: 0.3 }}
                    className="mt-8 flex justify-center items-center"
                >
                    {auth?.user ? (
                        <Link 
                            href="/admin" 
                            className="inline-flex items-center gap-2 px-8 py-3.5 font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-violet-200"
                        >
                            Masuk Dasbor Panel
                            <ArrowRight className="w-4 h-4" />
                        </Link>
                    ) : (
                        <Link 
                            href="/admin/login" 
                            className="inline-flex items-center gap-2 px-8 py-3.5 font-bold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-violet-200"
                        >
                            Autentikasi Sekarang
                            <ArrowRight className="w-4 h-4" />
                        </Link>
                    )}
                </motion.div>
            </main>

            {/* ── Infinite Mockup Card Scrolling Marquee ────────────────── */}
            <section className="relative z-10 w-full py-8 border-y border-slate-200/50 bg-slate-100/30 overflow-hidden flex items-center select-none">
                <style>{`
                    @keyframes marquee-scroll {
                        0% { transform: translate3d(0, 0, 0); }
                        100% { transform: translate3d(-33.33%, 0, 0); }
                    }
                    .animate-marquee-scroll {
                        display: flex;
                        width: max-content;
                        gap: 20px;
                        animation: marquee-scroll 35s linear infinite;
                    }
                    .animate-marquee-scroll:hover {
                        animation-play-state: paused;
                    }
                `}</style>
                <div className="animate-marquee-scroll">
                    {marqueeMockups.map((mockup, idx) => {
                        const Icon = mockup.icon;
                        return (
                            <div 
                                key={idx} 
                                className="w-64 flex-shrink-0 bg-white border border-slate-200/70 p-5 rounded-2xl shadow-sm cursor-default hover:border-violet-300 transition-all duration-200"
                            >
                                <div className="flex items-center gap-3 border-b border-slate-100 pb-3 mb-3">
                                    <div className="w-8 h-8 rounded-lg bg-violet-50 text-violet-600 flex items-center justify-center">
                                        <Icon className="w-4.5 h-4.5" />
                                    </div>
                                    <div>
                                        <span className="block text-[8px] font-bold text-slate-400 uppercase tracking-wider">{mockup.category}</span>
                                        <span className="block text-[11px] font-extrabold text-slate-700 leading-tight">{mockup.title}</span>
                                    </div>
                                </div>
                                <div>
                                    {mockup.content}
                                </div>
                            </div>
                        );
                    })}
                </div>
            </section>

            {/* Footer */}
            <footer className="relative z-10 w-full max-w-6xl mx-auto px-6 py-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs font-semibold text-slate-400">
                <div>&copy; {new Date().getFullYear()} BloomFem Project. Seluruh hak cipta dilindungi.</div>
                <div className="flex gap-4 font-mono text-[10px] tracking-wide">
                    <span>BloomFem App Suite</span>
                    <span>React + Inertia</span>
                </div>
            </footer>
        </div>
    );
}
