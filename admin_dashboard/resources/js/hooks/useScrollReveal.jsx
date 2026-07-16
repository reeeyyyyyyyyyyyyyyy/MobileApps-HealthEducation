import { useEffect, useRef, useState } from 'react';

export function useScrollReveal({ threshold = 0.15, rootMargin = '0px 0px -60px 0px' } = {}) {
  const ref = useRef(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          observer.unobserve(el);
        }
      },
      { threshold, rootMargin }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [threshold, rootMargin]);

  return [ref, isVisible];
}

const animations = {
  'fade-up': 'opacity-0 translate-y-6',
  'fade-down': 'opacity-0 -translate-y-6',
  'fade-left': 'opacity-0 -translate-x-6',
  'fade-right': 'opacity-0 translate-x-6',
  'scale-in': 'opacity-0 scale-95',
  'fade-in': 'opacity-0',
};

const visibleClasses = 'opacity-100 translate-y-0 translate-x-0 scale-100';

export function Animated({ children, animation = 'fade-up', delay = 0, className = '', as: Tag = 'div', once = true }) {
  const [ref, isVisible] = useScrollReveal({ threshold: once ? 0.1 : 0 });

  return (
    <Tag
      ref={ref}
      className={`transition-all duration-700 ease-out ${animations[animation] || animations['fade-up']} ${isVisible ? visibleClasses : ''} ${className}`}
      style={{ transitionDelay: `${delay}ms` }}
    >
      {children}
    </Tag>
  );
}
