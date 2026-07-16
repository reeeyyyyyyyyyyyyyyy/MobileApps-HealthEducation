import React, { useEffect, useRef } from 'react';

export default function InputModal({ open, onClose, onConfirm, title, fields, placeholder }) {
  const inputRef = useRef(null);

  useEffect(() => {
    if (open && inputRef.current) setTimeout(() => inputRef.current?.focus(), 100);
  }, [open]);

  if (!open) return null;

  const handleConfirm = () => {
    const val = inputRef.current?.value;
    if (val) onConfirm(val);
  };

  return (
    <>
      <div className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40" onClick={onClose} />
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-2xl shadow-xl border border-sand-200 p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
          <h3 className="text-sm font-extrabold text-slate-800 mb-4">{title}</h3>
          {fields.map((field, i) => (
            <div key={i} className="mb-4">
              <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">{field.label}</label>
              {field.type === 'textarea' ? (
                <textarea ref={i === 0 ? inputRef : null} className="w-full px-4 py-3 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 outline-none" rows={3} placeholder={field.placeholder} defaultValue={field.default || ''} />
              ) : (
                <input ref={i === 0 ? inputRef : null} type={field.type || 'text'} className="w-full px-4 py-3 rounded-xl border border-sand-200 text-sm font-semibold focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10 outline-none" placeholder={field.placeholder} defaultValue={field.default || ''} />
              )}
            </div>
          ))}
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="px-4 py-2 text-sm font-bold text-slate-500 hover:bg-sand-50 rounded-xl transition-all">Batal</button>
            <button type="button" onClick={handleConfirm} className="px-4 py-2 text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 rounded-xl transition-all">Simpan</button>
          </div>
        </div>
      </div>
    </>
  );
}