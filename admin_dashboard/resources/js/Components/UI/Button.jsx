export default function Button({ children, variant = 'primary', size = 'md', disabled, loading, className = '', ...props }) {
  const base = 'inline-flex items-center justify-center gap-2 font-bold rounded-xl transition-all duration-200 active:scale-[0.97] disabled:opacity-50 disabled:pointer-events-none';
  const variants = {
    primary: 'text-white bg-teal-600 hover:bg-teal-700 shadow-sm shadow-teal-200',
    secondary: 'text-teal-700 bg-teal-50 hover:bg-teal-100 border border-teal-200',
    ghost: 'text-slate-600 hover:bg-slate-100',
    danger: 'text-white bg-brick-600 hover:bg-brick-700 shadow-sm shadow-brick-200',
    outline: 'text-slate-700 bg-white hover:bg-sand-50 border border-sand-200',
  };
  const sizes = {
    sm: 'px-3 py-1.5 text-xs',
    md: 'px-4 py-2.5 text-sm',
    lg: 'px-6 py-3 text-base',
  };
  return (
    <button className={`${base} ${variants[variant]} ${sizes[size]} ${className}`} disabled={disabled || loading} {...props}>
      {loading && <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
      {children}
    </button>
  );
}
