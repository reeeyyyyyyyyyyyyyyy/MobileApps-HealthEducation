export default function Select({ label, error, children, className = '', ...props }) {
  return (
    <div>
      {label && <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">{label}</label>}
      <select
        className={`block w-full px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all outline-none cursor-pointer bg-white ${
          error ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
        } ${className}`}
        {...props}
      >
        {children}
      </select>
      {error && <p className="text-xs font-bold text-brick-500 mt-1.5">{error}</p>}
    </div>
  );
}
