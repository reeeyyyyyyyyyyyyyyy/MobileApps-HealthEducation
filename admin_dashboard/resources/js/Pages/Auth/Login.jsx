import React, { useEffect } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { gooeyToast, GooeyToaster } from 'goey-toast';
import { Lock, Mail, ArrowRight } from 'lucide-react';
import 'goey-toast/styles.css';
import { motion } from 'framer-motion';

export default function Login() {
  const { data, setData, post, processing, errors, reset } = useForm({
    email: '', password: '', remember: false,
  });

  useEffect(() => {
    const keys = Object.keys(errors);
    if (keys.length > 0) gooeyToast.error(errors[keys[0]], { preset: 'bouncy', duration: 5000 });
  }, [errors]);

  const handleSubmit = (e) => {
    e.preventDefault();
    post('/admin/login', { onError: () => reset('password') });
  };

  return (
    <div className="min-h-screen bg-sand-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden select-none">
      <Head title="Masuk Admin — BloomFem" />
      <GooeyToaster position="top-right" theme="light" />

      <div className="absolute inset-0 pointer-events-none z-0">
        <div className="absolute top-[15%] left-[25%] w-80 h-80 rounded-full bg-teal-500/5 blur-[100px]" />
        <div className="absolute bottom-[15%] right-[25%] w-80 h-80 rounded-full bg-terracotta-500/5 blur-[100px]" />
      </div>

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <div className="flex justify-center mb-6">
          <Link href="/" className="w-14 h-14 rounded-2xl bg-teal-600 flex items-center justify-center text-white font-extrabold text-2xl shadow-lg shadow-teal-200">
            B
          </Link>
        </div>
        <h2 className="text-center text-3xl font-extrabold text-slate-800 tracking-tight">Masuk Portal Admin</h2>
        <p className="mt-2 text-center text-sm font-medium text-slate-400">Masukkan akun administrator BloomFem Anda</p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.4 }} className="bg-white py-8 px-4 border border-sand-200/80 shadow-md sm:rounded-2xl sm:px-10">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="email" className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Alamat Email</label>
              <div className="relative rounded-xl shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400"><Mail className="h-[18px] w-[18px]" /></div>
                <input id="email" type="email" required value={data.email} onChange={(e) => setData('email', e.target.value)}
                  placeholder="nama@bloomfem.com"
                  className={`block w-full pl-10 pr-4 py-3 rounded-xl border text-sm font-semibold transition-all outline-none ${
                    errors.email ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
                  }`}
                />
              </div>
            </div>
            <div>
              <label htmlFor="password" className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Kata Sandi</label>
              <div className="relative rounded-xl shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400"><Lock className="h-[18px] w-[18px]" /></div>
                <input id="password" type="password" required value={data.password} onChange={(e) => setData('password', e.target.value)}
                  placeholder="••••••••"
                  className={`block w-full pl-10 pr-4 py-3 rounded-xl border text-sm font-semibold transition-all outline-none ${
                    errors.password ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
                  }`}
                />
              </div>
            </div>
            <div className="flex items-center">
              <input id="remember" type="checkbox" checked={data.remember} onChange={(e) => setData('remember', e.target.checked)}
                className="h-4.5 w-4.5 text-teal-600 focus:ring-teal-500 border-sand-200 rounded-lg cursor-pointer transition-all"
              />
              <label htmlFor="remember" className="ml-2 block text-xs font-bold text-slate-400 cursor-pointer select-none">Ingat perangkat ini</label>
            </div>
            <div>
              <button type="submit" disabled={processing}
                className="w-full flex justify-center items-center gap-2 py-3 px-4 rounded-xl shadow-md shadow-teal-200 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 active:scale-[0.97] transition-all disabled:opacity-50"
              >
                {processing ? (
                  <><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> Memproses...</>
                ) : (
                  <>Masuk Sekarang <ArrowRight className="w-4 h-4" /></>
                )}
              </button>
            </div>
          </form>
        </motion.div>
      </div>
    </div>
  );
}
