const variants = {
  default: 'bg-slate-100 text-slate-700 border-slate-200',
  teal: 'bg-teal-50 text-teal-700 border-teal-200',
  terracotta: 'bg-terracotta-50 text-terracotta-700 border-terracotta-200',
  sage: 'bg-sage-50 text-sage-700 border-sage-200',
  amber: 'bg-amber-50 text-amber-700 border-amber-200',
  brick: 'bg-brick-50 text-brick-700 border-brick-200',
  indigo: 'bg-indigo-50 text-indigo-700 border-indigo-200',
};

export default function Badge({ children, variant = 'default', className = '' }) {
  return (
    <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-bold border ${variants[variant]} ${className}`}>
      {children}
    </span>
  );
}
