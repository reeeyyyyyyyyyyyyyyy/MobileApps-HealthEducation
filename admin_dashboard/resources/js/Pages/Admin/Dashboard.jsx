import React, { useEffect } from 'react';
import { Head, Link, usePage } from '@inertiajs/react';
import { useToast } from '@/hooks/useToast';
import AdminLayout from '@/Layouts/AdminLayout';
import { 
    Users, 
    MessageSquare, 
    AlertTriangle,
    BookOpen,
    HelpCircle,
    ArrowRight
} from 'lucide-react';
import { 
    BarChart, 
    Bar, 
    XAxis, 
    YAxis, 
    CartesianGrid, 
    Tooltip, 
    ResponsiveContainer,
    PieChart,
    Pie,
    Cell,
    Legend
} from 'recharts';

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
        { 
            name: 'Total Pengguna', 
            value: stats.totalUsers, 
            desc: 'Pengguna terdaftar di aplikasi',
            icon: Users, 
            bgColor: 'bg-violet-50 text-violet-600 border-violet-100/50' 
        },
        { 
            name: 'Total Postingan', 
            value: stats.totalPosts, 
            desc: 'Postingan di forum komunitas',
            icon: MessageSquare, 
            bgColor: 'bg-emerald-50 text-emerald-600 border-emerald-100/50' 
        },
        { 
            name: 'Total Laporan', 
            value: stats.totalReports, 
            desc: 'Laporan konten perlu tinjauan',
            icon: AlertTriangle, 
            bgColor: stats.totalReports > 0 ? 'bg-rose-50 text-rose-600 border-rose-100/50 animate-pulse' : 'bg-slate-50 text-slate-500 border-slate-100/50' 
        },
    ];

    const COLORS = ['#10b981', '#f43f5e']; // Passed, Failed colors

    return (
        <AdminLayout title="Dasbor" titleParent="Admin">
            <Head title="Dasbor — BloomFem" />

            {/* Greeting Banner */}
            <div className="bg-white border border-slate-200/80 rounded-2xl p-6 md:p-8 mb-8 shadow-sm flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h2 className="text-2xl font-extrabold text-slate-800 tracking-tight">
                        {getGreeting()}, {auth?.user?.name || 'Admin'}
                    </h2>
                    <p className="text-sm font-medium text-slate-400 mt-1">
                        Ikhtisar metrik platform BloomFem secara terpusat.
                    </p>
                </div>
                <div className="flex gap-2">
                    <Link 
                        href="/admin/modules/create" 
                        className="px-4 py-2 text-xs font-bold text-white bg-violet-600 hover:bg-violet-700 rounded-xl transition-all shadow-md shadow-violet-100"
                    >
                        Buat Modul Baru
                    </Link>
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                {statsConfig.map((stat, idx) => {
                    const Icon = stat.icon;
                    return (
                        <div key={idx} className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm hover:shadow-md transition-all duration-200">
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

            {/* Charts Section */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
                {/* Popular Modules Bar Chart */}
                <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm lg:col-span-2">
                    <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-6">
                        Modul Paling Sering Dibaca
                    </h3>
                    <div className="h-80 w-full text-xs font-semibold">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={popularModules} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
                                <XAxis dataKey="title" stroke="#94a3b8" tickLine={false} />
                                <YAxis stroke="#94a3b8" tickLine={false} />
                                <Tooltip 
                                    contentStyle={{ 
                                        background: '#ffffff', 
                                        borderRadius: '12px', 
                                        border: '1px solid #e2e8f0', 
                                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                                        fontSize: '11px',
                                        fontWeight: 'bold'
                                    }} 
                                />
                                <Bar dataKey="view_count" fill="#8b5cf6" radius={[6, 6, 0, 0]} maxBarSize={45} />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Quiz Pass Ratio Pie Chart */}
                <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-sm flex flex-col justify-between">
                    <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4">
                        Rasio Kelulusan Kuis
                    </h3>
                    <div className="h-60 w-full flex items-center justify-center text-xs font-semibold">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={quizRatio}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={55}
                                    outerRadius={75}
                                    paddingAngle={3}
                                    dataKey="value"
                                >
                                    {quizRatio.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip 
                                    contentStyle={{ 
                                        background: '#ffffff', 
                                        borderRadius: '12px', 
                                        border: '1px solid #e2e8f0', 
                                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                                        fontSize: '11px',
                                        fontWeight: 'bold'
                                    }}
                                />
                                <Legend verticalAlign="bottom" height={36} />
                            </PieChart>
                        </ResponsiveContainer>
                    </div>
                    <div className="text-center text-xs font-bold text-slate-400 border-t border-slate-100 pt-4 mt-2">
                        Total kuis yang dikerjakan: {quizRatio.reduce((acc, curr) => acc + curr.value, 0)}
                    </div>
                </div>
            </div>

            {/* Quick Actions Grid */}
            <div>
                <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">
                    Aksi Cepat Menu
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <Link 
                        href="/admin/modules" 
                        className="flex items-center justify-between p-5 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-violet-200 hover:-translate-y-0.5 transition-all duration-200 group"
                    >
                        <div className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center">
                                <BookOpen className="w-5 h-5" />
                            </div>
                            <span className="font-bold text-slate-700 text-sm group-hover:text-violet-700 transition-colors">Kelola Modul</span>
                        </div>
                        <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-violet-600 group-hover:translate-x-0.5 transition-all" />
                    </Link>

                    <Link 
                        href="/admin/quizzes" 
                        className="flex items-center justify-between p-5 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-emerald-200 hover:-translate-y-0.5 transition-all duration-200 group"
                    >
                        <div className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                                <HelpCircle className="w-5 h-5" />
                            </div>
                            <span className="font-bold text-slate-700 text-sm group-hover:text-emerald-700 transition-colors">Kelola Kuis</span>
                        </div>
                        <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-emerald-600 group-hover:translate-x-0.5 transition-all" />
                    </Link>

                    <Link 
                        href="/admin/reports" 
                        className="flex items-center justify-between p-5 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-rose-200 hover:-translate-y-0.5 transition-all duration-200 group"
                    >
                        <div className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                                <AlertTriangle className="w-5 h-5" />
                            </div>
                            <span className="font-bold text-slate-700 text-sm group-hover:text-rose-700 transition-colors">Tinjau Laporan</span>
                        </div>
                        <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-rose-600 group-hover:translate-x-0.5 transition-all" />
                    </Link>

                    <Link 
                        href="/admin/users" 
                        className="flex items-center justify-between p-5 bg-white border border-slate-200/80 rounded-2xl shadow-sm hover:shadow-md hover:border-indigo-200 hover:-translate-y-0.5 transition-all duration-200 group"
                    >
                        <div className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                                <Users className="w-5 h-5" />
                            </div>
                            <span className="font-bold text-slate-700 text-sm group-hover:text-indigo-700 transition-colors">Progres Pengguna</span>
                        </div>
                        <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-indigo-600 group-hover:translate-x-0.5 transition-all" />
                    </Link>
                </div>
            </div>
        </AdminLayout>
    );
}
