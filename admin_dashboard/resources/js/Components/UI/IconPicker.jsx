import React, { useState } from 'react';
import { Check, ChevronDown, Brain, Heart, HandHeart, FlaskConical, Calendar, Hand, Utensils, Dumbbell, Hospital, Book, Droplets, HeartPulse } from 'lucide-react';

const iconOptions = [
  { value: 'psychology_rounded', label: 'Psikologi (Mitos/Fakta)', icon: Brain, color: '#0F766E' },
  { value: 'volunteer_activism_rounded', label: 'Relawan (Kelola Nyeri)', icon: HandHeart, color: '#C45D2A' },
  { value: 'favorite_rounded', label: 'Favorite (Bangga Tubuh)', icon: Heart, color: '#B53D3D' },
  { value: 'biotech_rounded', label: 'Biologi (Kesehatan)', icon: FlaskConical, color: '#6B8E5A' },
  { value: 'calendar_month_rounded', label: 'Kalender (Siklus)', icon: Calendar, color: '#0F766E' },
  { value: 'clean_hands_rounded', label: 'Kebersihan', icon: Hand, color: '#527044' },
  { value: 'restaurant_rounded', label: 'Nutrisi (Makanan)', icon: Utensils, color: '#C45D2A' },
  { value: 'fitness_center_rounded', label: 'Olahraga', icon: Dumbbell, color: '#0F766E' },
  { value: 'local_hospital_rounded', label: 'Klinik (Kesehatan)', icon: Hospital, color: '#B53D3D' },
  { value: 'water_drop_rounded', label: 'Air (Menstruasi)', icon: Droplets, color: '#0F766E' },
  { value: 'healing', label: 'Penyembuhan', icon: HeartPulse, color: '#6B8E5A' },
];

export default function IconPicker({ value, onChange, label = 'Ikon Modul', className = '' }) {
  const [open, setOpen] = useState(false);
  const selected = iconOptions.find(o => o.value === value) || iconOptions.find(o => o.value === 'psychology_rounded');

  const handleSelect = (val) => {
    onChange(val);
    setOpen(false);
  };

  return (
    <div className={`relative ${className}`}>
      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">{label}</label>
      <button type="button" onClick={() => setOpen(!open)} className="flex items-center gap-3 w-full px-4 py-3 rounded-xl border border-sand-200 bg-white text-sm font-semibold transition-all hover:border-teal-400 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 cursor-pointer">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ backgroundColor: `${selected.color}15` }}>
          <selected.icon className="w-5 h-5" style={{ color: selected.color }} />
        </div>
        <div className="flex-1 text-left">
          <span className="block text-sm font-bold text-slate-700">{selected.label}</span>
          <span className="block text-[10px] text-slate-400 font-mono">{selected.value}</span>
        </div>
        <ChevronDown className={`w-4 h-4 text-slate-400 transition-transform ${open ? 'rotate-180' : ''}`} />
      </button>
      {open && (
        <>
          <div className="fixed inset-0 z-10" onClick={() => setOpen(false)} />
          <div className="absolute z-20 mt-2 w-full bg-white border border-sand-200 rounded-2xl shadow-xl overflow-hidden">
            <div className="max-h-80 overflow-y-auto divide-y divide-sand-50">
              {iconOptions.map((opt) => (
                <button key={opt.value} type="button" onClick={() => handleSelect(opt.value)} className={`flex items-center gap-3 w-full px-4 py-3 text-left transition-all hover:bg-sand-50 ${opt.value === value ? 'bg-teal-50' : ''}`}>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ backgroundColor: `${opt.color}15` }}>
                    <opt.icon className="w-5 h-5" style={{ color: opt.color }} />
                  </div>
                  <div className="flex-1">
                    <span className={`block text-sm font-bold ${opt.value === value ? 'text-teal-700' : 'text-slate-700'}`}>{opt.label}</span>
                    <span className="block text-[10px] text-slate-400 font-mono">{opt.value}</span>
                  </div>
                  {opt.value === value && <Check className="w-4 h-4 text-teal-600" />}
                </button>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}