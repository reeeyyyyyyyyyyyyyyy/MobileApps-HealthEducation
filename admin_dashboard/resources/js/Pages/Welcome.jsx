import React, { useState, useEffect } from 'react';
import { Link, Head, usePage } from '@inertiajs/react';
import { ArrowRight, BookOpen, HelpCircle, Calendar, Heart, MessageSquare } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Animated } from '@/hooks/useScrollReveal';
import { FlowerIcon } from '@/Components/Icons/BloomIcons';

const appMockups = [
  {
    title: "Pelacak Siklus", category: "Kesehatan Reproduksi", icon: Calendar,
    content: (
      <div className="space-y-3">
        <div className="flex justify-between items-center text-[10px] font-bold text-slate-400">
          <span>JULI 2026</span>
          <span className="text-teal-600">HARI KE-3</span>
        </div>
        <div className="grid grid-cols-7 gap-1 text-center text-xs font-bold">
          {['S','S','R','K','J','S','M'].map(d => <span key={d} className="text-slate-300">{d}</span>)}
          <span className="text-slate-300">1</span><span className="text-slate-300">2</span>
          {[3,4,5].map(d => (
            <span key={d} className="w-6 h-6 rounded-full bg-teal-500 text-white flex items-center justify-center mx-auto">{d}</span>
          ))}
          <span className="text-slate-600 flex items-center justify-center">6</span>
          <span className="text-slate-600 flex items-center justify-center">7</span>
        </div>
        <div className="bg-teal-50 border border-teal-100 rounded-xl p-2.5 text-[10px] font-semibold text-teal-700 flex items-center gap-2">
          <Calendar className="w-3.5 h-3.5 flex-shrink-0" />
          Prediksi siklus berikutnya dalam 25 hari.
        </div>
      </div>
    )
  },
  {
    title: "Forum Diskusi", category: "Komunitas", icon: MessageSquare,
    content: (
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-full bg-terracotta-100 flex items-center justify-center text-terracotta-700 font-bold text-[10px]">A</div>
          <div><span className="block text-[10px] font-bold text-slate-700">@anissa_rahma</span><span className="block text-[8px] text-slate-400">2 jam lalu</span></div>
        </div>
        <p className="text-[11px] font-semibold text-slate-500 leading-normal line-clamp-2">Apakah wajar jika mengalami nyeri pinggul yang parah saat hari pertama siklus haid?</p>
        <div className="flex items-center gap-3 text-[9px] font-bold text-slate-400">
          <span className="flex items-center gap-1"><Heart className="w-3 h-3 text-terracotta-500 fill-terracotta-500" /> 18 Suka</span>
          <span className="flex items-center gap-1"><MessageSquare className="w-3 h-3" /> 5 Balasan</span>
        </div>
      </div>
    )
  },
  {
    title: "Mitos vs Fakta", category: "Modul Edukasi", icon: BookOpen,
    content: (
      <div className="space-y-2.5">
        <div className="w-full h-20 rounded-xl bg-teal-50 flex items-center justify-center overflow-hidden relative">
          <BookOpen className="w-8 h-8 text-teal-400/70 z-10" />
        </div>
        <h5 className="text-xs font-bold text-slate-800 leading-snug">Memahami PMS dan Hubungannya dengan Hormon</h5>
        <div className="flex items-center justify-between text-[9px] font-bold text-slate-400">
          <span>PENGETAHUAN</span>
          <span>5 MENIT</span>
        </div>
      </div>
    )
  },
  {
    title: "Evaluasi Pemahaman", category: "Kuis", icon: HelpCircle,
    content: (
      <div className="space-y-3">
        <span className="inline-block text-[9px] font-bold text-slate-400">SOAL KE-2 DARI 5</span>
        <p className="text-[11px] font-bold text-slate-700 leading-snug">Berapa durasi rata-rata siklus haid yang normal?</p>
        <div className="space-y-1.5">
          <div className="px-3 py-1.5 rounded-lg border border-sage-200 bg-sage-50 text-sage-700 text-[10px] font-bold flex justify-between">
            <span>A. 21 s.d. 35 hari</span>
            <span>BENAR</span>
          </div>
          <div className="px-3 py-1.5 rounded-lg border border-sand-200 bg-sand-50 text-slate-400 text-[10px] font-semibold">B. 10 s.d. 15 hari</div>
        </div>
      </div>
    )
  },
];

export default function Welcome() {
  const { auth } = usePage().props;
  const [loading, setLoading] = useState(true);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) { clearInterval(interval); setTimeout(() => setLoading(false), 300); return 100; }
        return prev + 4;
      });
    }, 50);
    return () => clearInterval(interval);
  }, []);

  const marqueeCards = [...appMockups, ...appMockups, ...appMockups];

  return (
    <div className="min-h-screen bg-sand-100 text-slate-800 flex flex-col relative overflow-hidden font-sans">
      <Head title="BloomFem — Portal Administrasi" />

      <AnimatePresence>
        {loading && (
          <motion.div
            key="splash"
            initial={{ opacity: 1 }}
            exit={{ opacity: 0, scale: 1.05, filter: 'blur(4px)' }}
            transition={{ duration: 0.6, ease: 'easeInOut' }}
            className="fixed inset-0 z-50 flex flex-col items-center justify-center"
            style={{ background: 'linear-gradient(135deg, #0F766E 0%, #0B5E57 50%, #083B3A 100%)' }}
          >
            <motion.div
              animate={{ scale: [0.95, 1.04, 0.95], rotate: [0, 2, -2, 0] }}
              transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              className="w-28 h-28 rounded-3xl bg-white/10 backdrop-blur-xl border border-white/20 flex items-center justify-center shadow-2xl"
            >
              <span className="text-white text-5xl font-extrabold">B</span>
            </motion.div>
            <h2 className="text-white font-extrabold text-xl tracking-tight mt-6">BloomFem</h2>
            <p className="text-teal-200 text-[10px] font-bold tracking-[0.2em] uppercase mt-1.5">Portal Administrasi</p>
            <div className="w-36 h-1 bg-white/10 rounded-full overflow-hidden mt-8">
              <motion.div className="h-full bg-white/80" style={{ width: `${progress}%` }} />
            </div>
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.5 }}
              className="text-teal-300/60 text-[10px] font-semibold mt-4"
            >
              Menyiapkan dasbor...
            </motion.p>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Background mesh */}
      <div className="absolute inset-0 pointer-events-none z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] rounded-full bg-teal-500/5 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-terracotta-500/5 blur-[100px]" />
      </div>

      {/* Header */}
      <header className="relative z-10 w-full max-w-6xl mx-auto px-6 py-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-teal-600 flex items-center justify-center text-white font-extrabold shadow-sm">
            B
          </div>
          <span className="font-extrabold tracking-tight text-lg text-slate-800">BloomFem</span>
        </div>
        <div>
          {auth?.user ? (
            <Link href="/admin" className="inline-flex items-center px-4 py-2 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-95 transition-all rounded-xl shadow-md shadow-teal-200">
              Buka Dasbor <ArrowRight className="w-4 h-4 ml-1.5" />
            </Link>
          ) : (
            <Link href="/admin/login" className="inline-flex items-center px-4 py-2 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-95 transition-all rounded-xl shadow-md shadow-teal-200">
              Masuk Admin <ArrowRight className="w-4 h-4 ml-1.5" />
            </Link>
          )}
        </div>
      </header>

      {/* Hero */}
      <main className="relative z-10 w-full max-w-4xl mx-auto px-6 py-8 flex-grow flex flex-col justify-center text-center">
        <Animated animation="fade-up" delay={0}>
          <span className="inline-block text-[11px] font-bold tracking-widest text-teal-600 border border-teal-100 bg-teal-50/80 px-4 py-1.5 rounded-full uppercase mb-5 shadow-sm">
            Kesehatan Reproduksi & Edukasi Remaja
          </span>
        </Animated>

        <Animated animation="fade-up" delay={100}>
          <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight text-slate-900 leading-[1.08]">
            Portal Pengelolaan<br />
            <span className="text-teal-600">Layanan BloomFem</span>
          </h1>
        </Animated>

        <Animated animation="fade-up" delay={200}>
          <p className="mt-5 text-base text-slate-500 leading-relaxed max-w-xl mx-auto font-medium">
            Modul manajemen terintegrasi untuk kuis edukasi, progres pengguna, pelacakan siklus, dan moderasi forum.
          </p>
        </Animated>

        <Animated animation="fade-up" delay={300}>
          <div className="mt-8 flex justify-center">
            {auth?.user ? (
              <Link href="/admin" className="inline-flex items-center gap-2 px-8 py-3.5 font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-teal-200">
                Masuk Dasbor <ArrowRight className="w-4 h-4" />
              </Link>
            ) : (
              <Link href="/admin/login" className="inline-flex items-center gap-2 px-8 py-3.5 font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-95 transition-all rounded-xl shadow-lg shadow-teal-200">
                Mulai Sekarang <ArrowRight className="w-4 h-4" />
              </Link>
            )}
          </div>
        </Animated>
      </main>

      {/* Marquee */}
      <section className="relative z-10 w-full py-8 border-y border-sand-200/50 bg-white/40 overflow-hidden">
        <style>{`
          @keyframes marquee { 0% { transform: translateX(0); } 100% { transform: translateX(-33.33%); } }
          .marquee-track { display: flex; width: max-content; gap: 20px; animation: marquee 40s linear infinite; }
          .marquee-track:hover { animation-play-state: paused; }
        `}</style>
        <div className="marquee-track">
          {marqueeCards.map((mockup, idx) => {
            const Icon = mockup.icon;
            return (
              <div key={idx} className="w-64 flex-shrink-0 bg-white border border-sand-200/70 p-5 rounded-2xl shadow-sm hover:border-teal-200 hover:shadow-md transition-all duration-200 cursor-default">
                <div className="flex items-center gap-3 border-b border-sand-100 pb-3 mb-3">
                  <div className="w-8 h-8 rounded-lg bg-teal-50 text-teal-600 flex items-center justify-center">
                    <Icon className="w-4.5 h-4.5" />
                  </div>
                  <div>
                    <span className="block text-[8px] font-bold text-slate-400 uppercase tracking-wider">{mockup.category}</span>
                    <span className="block text-[11px] font-extrabold text-slate-700 leading-tight">{mockup.title}</span>
                  </div>
                </div>
                <div>{mockup.content}</div>
              </div>
            );
          })}
        </div>
      </section>

      {/* Footer */}
      <footer className="relative z-10 w-full max-w-6xl mx-auto px-6 py-6 flex items-center justify-between text-xs font-semibold text-slate-400">
        <div>&copy; {new Date().getFullYear()} BloomFem Project</div>
        <div className="flex gap-4 text-[10px]">
          <span>BloomFem App Suite</span>
          <span>React + Inertia</span>
        </div>
      </footer>
    </div>
  );
}
