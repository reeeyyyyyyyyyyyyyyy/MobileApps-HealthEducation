import React, { useEffect } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { gooeyToast, GooeyToaster } from 'goey-toast';
import { Lock, Mail, ArrowRight } from 'lucide-react';
import 'goey-toast/styles.css';

export default function Login() {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    useEffect(() => {
        // Show validation errors as gooey toasts for extra premium feel
        const errorKeys = Object.keys(errors);
        if (errorKeys.length > 0) {
            gooeyToast.error(errors[errorKeys[0]]);
        }
    }, [errors]);

    const handleSubmit = (e) => {
        e.preventDefault();
        post('/admin/login', {
            onError: () => reset('password'),
        });
    };

    return (
        <div className="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden select-none">
            <Head title="Masuk Admin — BloomFem" />
            <GooeyToaster position="top-right" theme="light" />

            {/* Background blur blobs */}
            <div className="absolute inset-0 pointer-events-none z-0">
                <div className="absolute top-[20%] left-[30%] w-72 h-72 rounded-full bg-violet-500/5 blur-[80px]" />
                <div className="absolute bottom-[20%] right-[30%] w-72 h-72 rounded-full bg-indigo-500/5 blur-[80px]" />
            </div>

            <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10">
                <div className="flex justify-center mb-6">
                    <Link href="/" className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-violet-600 to-indigo-600 flex items-center justify-center text-white font-extrabold text-2xl shadow-lg shadow-violet-200">
                        B
                    </Link>
                </div>
                <h2 className="text-center text-3xl font-extrabold text-slate-800 tracking-tight leading-none">
                    Masuk Portal Admin
                </h2>
                <p className="mt-2 text-center text-sm font-medium text-slate-400">
                    Masukkan akun administrator BloomFem Anda
                </p>
            </div>

            <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10">
                <div className="bg-white py-8 px-4 border border-slate-200/80 shadow-md sm:rounded-2xl sm:px-10">
                    <form className="space-y-6" onSubmit={handleSubmit}>
                        {/* Email Field */}
                        <div>
                            <label htmlFor="email" className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                Alamat Email
                            </label>
                            <div className="relative rounded-xl shadow-sm">
                                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                    <Mail className="h-[18px] w-[18px]" />
                                </div>
                                <input
                                    id="email"
                                    name="email"
                                    type="email"
                                    required
                                    value={data.email}
                                    onChange={(e) => setData('email', e.target.value)}
                                    placeholder="nama@bloomfem.com"
                                    className={`block w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                        errors.email ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                />
                            </div>
                        </div>

                        {/* Password Field */}
                        <div>
                            <label htmlFor="password" className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                                Kata Sandi
                            </label>
                            <div className="relative rounded-xl shadow-sm">
                                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                    <Lock className="h-[18px] w-[18px]" />
                                </div>
                                <input
                                    id="password"
                                    name="password"
                                    type="password"
                                    required
                                    value={data.password}
                                    onChange={(e) => setData('password', e.target.value)}
                                    placeholder="••••••••"
                                    className={`block w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:border-violet-500 focus:ring-3 focus:ring-violet-500/10 text-sm font-semibold transition-all ${
                                        errors.password ? 'border-rose-300 focus:border-rose-500 focus:ring-rose-500/10' : ''
                                    }`}
                                />
                            </div>
                        </div>

                        {/* Remember Me Box */}
                        <div className="flex items-center justify-between">
                            <div className="flex items-center">
                                <input
                                    id="remember"
                                    name="remember"
                                    type="checkbox"
                                    checked={data.remember}
                                    onChange={(e) => setData('remember', e.target.checked)}
                                    className="h-4.5 w-4.5 text-violet-600 focus:ring-violet-500 border-slate-200 rounded-lg cursor-pointer transition-all"
                                />
                                <label htmlFor="remember" className="ml-2 block text-xs font-bold text-slate-400 cursor-pointer select-none">
                                    Ingat perangkat ini
                                </label>
                            </div>
                        </div>

                        {/* Submit Button */}
                        <div>
                            <button
                                type="submit"
                                disabled={processing}
                                className="w-full flex justify-center items-center gap-2 py-3 px-4 border border-transparent rounded-xl shadow-md shadow-violet-200 text-sm font-bold text-white bg-violet-600 hover:bg-violet-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-violet-500 active:scale-98 transition-all disabled:opacity-50"
                            >
                                {processing ? 'Memproses...' : 'Masuk Sekarang'}
                                <ArrowRight className="w-4 h-4" />
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
}
