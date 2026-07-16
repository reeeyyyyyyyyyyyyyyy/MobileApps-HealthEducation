import { forwardRef } from 'react';

const Input = forwardRef(({ label, error, icon: Icon, className = '', ...props }, ref) => (
  <div>
    {label && <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">{label}</label>}
    <div className="relative">
      {Icon && <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400"><Icon className="w-4 h-4" /></div>}
      <input
        ref={ref}
        className={`block w-full px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all outline-none ${Icon ? 'pl-10' : ''} ${
          error ? 'border-brick-300 focus:border-brick-500 focus:ring-3 focus:ring-brick-500/10' : 'border-sand-200 focus:border-teal-500 focus:ring-3 focus:ring-teal-500/10'
        } ${className}`}
        {...props}
      />
    </div>
    {error && <p className="text-xs font-bold text-brick-500 mt-1.5">{error}</p>}
  </div>
));

Input.displayName = 'Input';
export default Input;
