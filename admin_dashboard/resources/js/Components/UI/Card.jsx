export default function Card({ children, className = '', padding = true, hover, onClick }) {
  return (
    <div
      onClick={onClick}
      className={`bg-white border border-sand-200/80 rounded-2xl shadow-sm ${padding ? 'p-5' : ''} ${hover ? 'hover:shadow-md hover:border-teal-200 hover:-translate-y-0.5 transition-all duration-200' : ''} ${onClick ? 'cursor-pointer' : ''} ${className}`}
    >
      {children}
    </div>
  );
}
