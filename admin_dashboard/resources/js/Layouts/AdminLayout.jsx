import React, { useEffect } from 'react';
import { Link, usePage, router } from '@inertiajs/react';
import { gooeyToast, GooeyToaster } from 'goey-toast';
import {
  LayoutDashboard, BookOpen, HelpCircle, AlertTriangle, Users,
  LogOut, Menu, X
} from 'lucide-react';
import 'goey-toast/styles.css';

export default function AdminLayout({ children, title }) {
  const { props, url } = usePage();
  const { auth, flash } = props;
  const [mobileOpen, setMobileOpen] = React.useState(false);

  useEffect(() => {
    if (flash?.success) gooeyToast.success(flash.success, { preset: 'bouncy', duration: 4000 });
    if (flash?.error) gooeyToast.error(flash.error, { preset: 'bouncy', duration: 4000 });
  }, [flash]);

  const nav = [
    { name: 'Dashboard', href: '/admin', icon: LayoutDashboard, current: url === '/admin' },
    { name: 'Modul Edukasi', href: '/admin/modules', icon: BookOpen, current: url.startsWith('/admin/modules') },
    { name: 'Kuis Evaluasi', href: '/admin/quizzes', icon: HelpCircle, current: url.startsWith('/admin/quizzes') },
    { name: 'Laporan Moderasi', href: '/admin/reports', icon: AlertTriangle, current: url.startsWith('/admin/reports') },
    { name: 'Progres Pengguna', href: '/admin/users', icon: Users, current: url.startsWith('/admin/users') },
  ];

  const handleLogout = (e) => { e.preventDefault(); router.post('/admin/logout'); };

  const NavLink = ({ item, mobile }) => {
    const Icon = item.icon;
    return (
      <Link
        href={item.href}
        onClick={() => mobile && setMobileOpen(false)}
        className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 ${
          item.current
            ? 'bg-teal-50 text-teal-700'
            : 'text-slate-400 hover:bg-sand-50 hover:text-slate-700'
        }`}
      >
        <Icon className={`w-[18px] h-[18px] ${item.current ? 'text-teal-600' : 'text-slate-400'}`} />
        {item.name}
      </Link>
    );
  };

  return (
    <div className="min-h-screen bg-sand-100 flex">
      <GooeyToaster position="top-right" theme="light" />

      {/* Sidebar Desktop */}
      <aside className="hidden md:flex md:w-64 md:flex-col md:fixed md:inset-y-0 bg-white border-r border-sand-200/80 p-4 z-20">
        <div className="flex items-center gap-3 px-3 py-4 border-b border-sand-100 mb-6">
          <div className="w-9 h-9 rounded-xl bg-teal-600 flex items-center justify-center text-white font-extrabold text-lg shadow-sm shadow-teal-200">
            B
          </div>
          <div>
            <span className="font-extrabold tracking-tight text-[16px] text-slate-800">BloomFem</span>
            <span className="block text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none mt-0.5">Admin Portal</span>
          </div>
        </div>
        <nav className="flex-1 space-y-1">
          {nav.map((item) => <NavLink key={item.name} item={item} />)}
        </nav>
        <div className="pt-4 border-t border-sand-100 space-y-3">
          <div className="flex items-center gap-3 px-2">
            <div className="w-9 h-9 rounded-full bg-teal-50 flex items-center justify-center text-teal-700 font-bold text-sm">
              {auth?.user?.name ? auth.user.name.charAt(0) : 'A'}
            </div>
            <div className="overflow-hidden">
              <span className="block text-sm font-bold text-slate-700 truncate leading-tight">{auth?.user?.name || 'Admin'}</span>
              <span className="block text-xs text-slate-400 truncate mt-0.5">{auth?.user?.email}</span>
            </div>
          </div>
          <button onClick={handleLogout} className="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold text-brick-600 hover:bg-brick-50 transition-all duration-200">
            <LogOut className="w-[18px] h-[18px] text-brick-500" />
            Keluar
          </button>
        </div>
      </aside>

      {/* Main */}
      <div className="flex-1 md:pl-64 flex flex-col">
        <header className="sticky top-0 bg-white/80 backdrop-blur-md border-b border-sand-200/60 px-4 md:px-8 py-4 flex items-center justify-between z-10">
          <div className="flex items-center gap-4">
            <button onClick={() => setMobileOpen(!mobileOpen)} className="md:hidden p-1.5 text-slate-500 hover:bg-sand-50 rounded-lg transition-colors">
              {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
            <h1 className="text-base font-bold text-slate-800">{title}</h1>
          </div>
          <div className="text-xs font-semibold text-slate-400 bg-sand-50 px-3 py-1.5 rounded-lg">
            {new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </div>
        </header>

        {mobileOpen && (
          <div className="md:hidden fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-30" onClick={() => setMobileOpen(false)}>
            <aside className="w-64 bg-white h-full p-4 flex flex-col" onClick={(e) => e.stopPropagation()}>
              <div className="flex items-center gap-2 pb-4 border-b border-sand-100 mb-6">
                <div className="w-8 h-8 rounded-lg bg-teal-600 flex items-center justify-center text-white font-extrabold text-sm">B</div>
                <span className="font-extrabold text-slate-800 text-sm">BloomFem</span>
              </div>
              <nav className="flex-1 space-y-1">
                {nav.map((item) => <NavLink key={item.name} item={item} mobile />)}
              </nav>
              <div className="pt-4 border-t border-sand-100 flex flex-col gap-3">
                <div className="flex items-center gap-3 px-2">
                  <div className="w-8 h-8 rounded-full bg-teal-50 flex items-center justify-center text-teal-700 font-bold text-xs">
                    {auth?.user?.name ? auth.user.name.charAt(0) : 'A'}
                  </div>
                  <div className="overflow-hidden">
                    <span className="block text-xs font-bold text-slate-700 truncate">{auth?.user?.name}</span>
                    <span className="block text-[10px] text-slate-400 truncate">{auth?.user?.email}</span>
                  </div>
                </div>
                <button onClick={handleLogout} className="w-full flex items-center gap-3 px-3 py-2 rounded-xl text-xs font-bold text-brick-600 hover:bg-brick-50">
                  <LogOut className="w-4 h-4 text-brick-500" /> Keluar
                </button>
              </div>
            </aside>
          </div>
        )}

        <main className="flex-1 p-4 md:p-8 max-w-7xl w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
