import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, BellRing, Clock, Edit, Trash2 } from 'lucide-react';

export default function Index({ templates }) {
  const handleDelete = (id, title) => {
    if (confirm(`Yakin ingin menghapus template pengingat "${title}"?`)) {
      router.delete(`/admin/reminders/${id}`);
    }
  };

  return (
    <AdminLayout title="Template Pengingat Kebiasaan">
      <Head title="Template Pengingat - UtiCare" />

      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-800">Template Pengingat ({templates.length})</h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Kelola template pengingat hidrasi dan kebiasaan pencegahan ISK untuk notifikasi aplikasi mobile
            </p>
          </div>
          <Link
            href="/admin/reminders/create"
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-sm shadow-sm shadow-violet-200 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Tambah Pengingat
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {templates.map((t) => (
            <div key={t.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between gap-2 mb-3">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-violet-100 flex items-center justify-center text-violet-600">
                      <BellRing className="w-4 h-4" />
                    </div>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                        t.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500'
                      }`}
                    >
                      {t.is_active ? 'Aktif' : 'Non-Aktif'}
                    </span>
                  </div>
                  <span className="text-xs font-semibold text-slate-400 flex items-center gap-1">
                    <Clock className="w-3.5 h-3.5" /> {t.default_time} WIB
                  </span>
                </div>

                <h3 className="font-bold text-slate-800 text-base">{t.title}</h3>
                <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">{t.description}</p>
              </div>

              <div className="pt-4 mt-4 border-t border-slate-100 flex items-center justify-between text-xs">
                <span className="text-slate-400">Icon: {t.icon_name}</span>
                <div className="flex items-center gap-1">
                  <Link
                    href={`/admin/reminders/${t.id}/edit`}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-violet-600 hover:bg-violet-50"
                  >
                    <Edit className="w-4 h-4" />
                  </Link>
                  <button
                    onClick={() => handleDelete(t.id, t.title)}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
