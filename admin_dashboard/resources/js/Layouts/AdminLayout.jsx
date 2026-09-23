import React, { useEffect, useState } from 'react';
import { Link, usePage, router } from '@inertiajs/react';
import { gooeyToast, GooeyToaster } from 'goey-toast';
import {
  LayoutDashboard,
  Users,
  BookOpen,
  ShieldAlert,
  BellRing,
  ClipboardCheck,
  Sparkles,
  LogOut,
  Menu,
  X,
  HeartHandshake,
  Download,
} from 'lucide-react';
import 'goey-toast/styles.css';

export default function AdminLayout({ children, title }) {
  const { props, url } = usePage();
  const { auth, flash } = props;
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    if (flash?.success) gooeyToast.success(flash.success, { preset: 'bouncy', duration: 4000 });
    if (flash?.error) gooeyToast.error(flash.error, { preset: 'bouncy', duration: 4000 });
  }, [flash]);

  const nav = [
    { name: 'Dashboard', href: '/admin', icon: LayoutDashboard, current: url === '/admin' },
    { name: 'Responden Penelitian', href: '/admin/respondents', icon: Users, current: url.startsWith('/admin/respondents') },
    { name: 'Materi Edukasi ISK', href: '/admin/education', icon: BookOpen, current: url.startsWith('/admin/education') },
    { name: 'Skrining Check Risk', href: '/admin/check-risk', icon: ShieldAlert, current: url.startsWith('/admin/check-risk') },
    { name: 'Template Pengingat', href: '/admin/reminders', icon: BellRing, current: url.startsWith('/admin/reminders') },
    { name: 'Kuesioner Pre/Post Test', href: '/admin/survey', icon: ClipboardCheck, current: url.startsWith('/admin/survey') },
    { name: 'Tips Harian ISK', href: '/admin/tips', icon: Sparkles, current: url.startsWith('/admin/tips') },
  ];

  const handleLogout = (e) => {
    e.preventDefault();
    router.post('/admin/logout');
  };

  const NavLink = ({ item, mobile }) => {
    const Icon = item.icon;
    return (
      <Link
        href={item.href}
        onClick={() => mobile && setMobileOpen(false)}
        className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 ${
          item.current
            ? 'bg-violet-600 text-white shadow-sm shadow-violet-200'
            : 'text-slate-600 hover:bg-violet-50 hover:text-violet-700'
        }`}
      >
        <Icon className={`w-[18px] h-[18px] ${item.current ? 'text-white' : 'text-slate-400'}`} />
        <span>{item.name}</span>
      </Link>
    );
  };

  return (
    <div className="min-h-screen bg-slate-50 flex font-sans text-slate-800">
      <GooeyToaster position="top-right" theme="light" />

      {/* Sidebar Desktop */}
      <aside className="hidden md:flex md:w-64 md:flex-col md:fixed md:inset-y-0 bg-white border-r border-slate-200/80 p-4 z-20">
        <div className="flex items-center gap-3 px-3 py-4 border-b border-slate-100 mb-6">
          <div className="w-10 h-10 rounded-xl bg-violet-600 flex items-center justify-center text-white font-extrabold text-lg shadow-sm shadow-violet-300">
            <HeartHandshake className="w-6 h-6" />
          </div>
          <div>
            <span className="font-extrabold tracking-tight text-lg text-slate-800">UtiCare</span>
            <span className="block text-[10px] font-bold text-violet-600 uppercase tracking-widest leading-none mt-0.5">
              Admin & Penelitian
            </span>
          </div>
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto">
          {nav.map((item) => (
            <NavLink key={item.name} item={item} />
          ))}
        </nav>

        <div className="pt-4 border-t border-slate-100 space-y-3">
          <div className="flex items-center gap-3 px-2">
            <div className="w-9 h-9 rounded-full bg-violet-100 flex items-center justify-center text-violet-700 font-bold text-sm">
              {auth?.user?.name ? auth.user.name.charAt(0).toUpperCase() : 'A'}
            </div>
            <div className="overflow-hidden">
              <span className="block text-sm font-bold text-slate-700 truncate leading-tight">
                {auth?.user?.name || 'Admin'}
              </span>
              <span className="block text-xs text-slate-400 truncate mt-0.5">{auth?.user?.email}</span>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold text-rose-600 hover:bg-rose-50 transition-all duration-200"
          >
            <LogOut className="w-[18px] h-[18px] text-rose-500" />
            Keluar
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 md:pl-64 flex flex-col min-h-screen">
        {/* Top Header */}
        <header className="sticky top-0 bg-white/80 backdrop-blur-md border-b border-slate-200/80 px-4 md:px-8 py-3.5 flex items-center justify-between z-10">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setMobileOpen(!mobileOpen)}
              className="md:hidden p-2 rounded-lg text-slate-600 hover:bg-slate-100"
            >
              {mobileOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
            <h1 className="text-lg font-bold text-slate-800">{title || 'UtiCare Admin Portal'}</h1>
          </div>

          <div className="flex items-center gap-2">
            <a
              href="/admin/respondents/export"
              className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-bold bg-violet-50 text-violet-700 hover:bg-violet-100 transition-colors"
            >
              <Download className="w-3.5 h-3.5" />
              Export Data CSV
            </a>
          </div>
        </header>

        {/* Mobile Navigation Drawer */}
        {mobileOpen && (
          <div className="md:hidden bg-white border-b border-slate-200 p-4 space-y-1 z-20">
            {nav.map((item) => (
              <NavLink key={item.name} item={item} mobile />
            ))}
            <button
              onClick={handleLogout}
              className="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold text-rose-600 hover:bg-rose-50"
            >
              <LogOut className="w-[18px] h-[18px]" />
              Keluar
            </button>
          </div>
        )}

        {/* Page Body */}
        <main className="flex-1 p-4 md:p-8 overflow-y-auto">{children}</main>

        <footer className="px-4 md:px-8 py-4 bg-white border-t border-slate-200 text-center text-xs text-slate-400">
          UtiCare &copy; {new Date().getFullYear()} &mdash; Aplikasi Mobile Berbasis Health Belief Model terhadap Pencegahan Infeksi Saluran Kemih pada Remaja Putri
        </footer>
      </div>
    </div>
  );
}
