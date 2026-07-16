import React from 'react';
import { Head, Link, usePage } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Users, MessageSquare, AlertTriangle, BookOpen, HelpCircle, ArrowRight, TrendingUp } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import { Animated } from '@/hooks/useScrollReveal';

export default function Dashboard({ stats, popularModules, quizRatio }) {
  const { auth } = usePage().props;

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return 'Selamat Pagi';
    if (hour >= 12 && hour < 17) return 'Selamat Siang';
    if (hour >= 17 && hour < 21) return 'Selamat Sore';
    return 'Selamat Malam';
  };

  const statsConfig = [
    { name: 'Total Pengguna', value: stats.totalUsers, desc: 'Pengguna terdaftar di aplikasi', icon: Users, bgColor: 'bg-teal-50 text-teal-700 border-teal-200/50' },
    { name: 'Total Postingan', value: stats.totalPosts, desc: 'Postingan di forum komunitas', icon: MessageSquare, bgColor: 'bg-sage-50 text-sage-700 border-sage-200/50' },
    { name: 'Total Laporan', value: stats.totalReports, desc: 'Laporan konten perlu tinjauan', icon: AlertTriangle, bgColor: stats.totalReports > 0 ? 'bg-brick-50 text-brick-700 border-brick-200/50 animate-pulse' : 'bg-slate-50 text-slate-500 border-slate-200/50' },
  ];

  const COLORS = ['#6B8E5A', '#B53D3D'];

  const quickActions = [
    { href: '/admin/modules', title: 'Kelola Modul', desc: 'Modul edukasi & video', icon: BookOpen, color: 'bg-teal-50 text-teal-600 border-teal-200/50', iconColor: 'text-teal-600' },
    { href: '/admin/quizzes', title: 'Kelola Kuis', desc: 'Evaluasi & soal', icon: HelpCircle, color: 'bg-sage-50 text-sage-600 border-sage-200/50', iconColor: 'text-sage-600' },
    { href: '/admin/reports', title: 'Tinjau Laporan', desc: 'Moderasi forum', icon: AlertTriangle, color: 'bg-brick-50 text-brick-600 border-brick-200/50', iconColor: 'text-brick-600' },
    { href: '/admin/users', title: 'Progres Pengguna', desc: 'XP, level & aktivitas', icon: Users, color: 'bg-terracotta-50 text-terracotta-600 border-terracotta-200/50', iconColor: 'text-terracotta-600' },
  ];

  return (
    <AdminLayout title="Dasbor" titleParent="Admin">
      <Head title="Dasbor — BloomFem" />

      <Animated animation="fade-up" delay={0}>
        <div className="bg-white border border-sand-200/80 rounded-2xl p-6 md:p-8 mb-8 shadow-sm flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <h2 className="text-2xl font-extrabold text-slate-800 tracking-tight">
              {getGreeting()}, {auth?.user?.name || 'Admin'}
            </h2>
            <p className="text-sm font-medium text-slate-400 mt-1">
              Ikhtisar metrik platform BloomFem secara terpusat.
            </p>
          </div>
          <div className="flex gap-2">
            <Link href="/admin/modules/create" className="px-4 py-2 text-xs font-bold text-white bg-teal-600 hover:bg-teal-700 rounded-xl transition-all shadow-md shadow-teal-200">
              Buat Modul Baru
            </Link>
          </div>
        </div>
      </Animated>

      <Animated animation="fade-up" delay={100}>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          {statsConfig.map((stat, idx) => {
            const Icon = stat.icon;
            return (
              <div key={idx} className="bg-white border border-sand-200/80 rounded-2xl p-6 shadow-sm hover:shadow-md transition-all duration-200">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">{stat.name}</p>
                    <h4 className="text-3xl font-extrabold text-slate-800 tracking-tight mt-2">{stat.value}</h4>
                  </div>
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center border ${stat.bgColor}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                </div>
                <p className="text-xs text-slate-400 mt-4 font-semibold">{stat.desc}</p>
              </div>
            );
          })}
        </div>
      </Animated>

      <Animated animation="fade-up" delay={200}>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          <div className="bg-white border border-sand-200/80 rounded-2xl p-6 shadow-sm lg:col-span-2">
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-6">
              Modul Paling Sering Dibaca
            </h3>
            <div className="h-80 w-full text-xs font-semibold">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={popularModules} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
                  <XAxis dataKey="title" stroke="#94a3b8" tickLine={false} />
                  <YAxis stroke="#94a3b8" tickLine={false} />
                  <Tooltip contentStyle={{ background: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.05)', fontSize: '11px', fontWeight: 'bold' }} />
                  <Bar dataKey="view_count" fill="#0F766E" radius={[6, 6, 0, 0]} maxBarSize={45} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white border border-sand-200/80 rounded-2xl p-6 shadow-sm flex flex-col justify-between">
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4">
              Rasio Kelulusan Kuis
            </h3>
            <div className="h-60 w-full flex items-center justify-center text-xs font-semibold">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={quizRatio} cx="50%" cy="50%" innerRadius={55} outerRadius={75} paddingAngle={3} dataKey="value">
                    {quizRatio.map((entry, index) => (<Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />))}
                  </Pie>
                  <Tooltip contentStyle={{ background: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.05)', fontSize: '11px', fontWeight: 'bold' }} />
                  <Legend verticalAlign="bottom" height={36} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="text-center text-xs font-bold text-slate-400 border-t border-sand-200 pt-4 mt-2">
              Total kuis yang dikerjakan: {quizRatio.reduce((acc, curr) => acc + curr.value, 0)}
            </div>
          </div>
        </div>
      </Animated>

      <Animated animation="fade-up" delay={300}>
        <div>
          <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">
            Aksi Cepat Menu
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {quickActions.map((action, idx) => {
              const Icon = action.icon;
              return (
                <Link key={idx} href={action.href} className="flex items-center justify-between p-5 bg-white border border-sand-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-teal-200 hover:-translate-y-0.5 transition-all duration-200 group">
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${action.color}`}>
                      <Icon className={`w-5 h-5 ${action.iconColor}`} />
                    </div>
                    <span className="font-bold text-slate-700 text-sm group-hover:text-teal-700 transition-colors">{action.title}</span>
                  </div>
                  <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-teal-600 group-hover:translate-x-0.5 transition-all" />
                </Link>
              );
            })}
          </div>
        </div>
      </Animated>
    </AdminLayout>
  );
}