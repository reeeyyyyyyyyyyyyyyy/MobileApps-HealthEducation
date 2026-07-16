export function FlowerIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 2a5 5 0 0 1 5 5c0 2-2 3-5 3s-5-1-5-3a5 5 0 0 1 5-5Z" />
      <path d="M12 10c3 0 5 1 5 3a5 5 0 0 1-5 5 5 5 0 0 1-5-5c0-2 2-3 5-3Z" />
      <path d="M12 18c0-3 1-5 3-5a5 5 0 0 1 5 5 5 5 0 0 1-5 5c-2 0-3-2-3-5Z" />
      <path d="M12 18c0 3-1 5-3 5a5 5 0 0 1-5-5 5 5 0 0 1 5-5c2 0 3 2 3 5Z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

export function BookOpenIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2Z" />
      <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7Z" />
    </svg>
  );
}

export function HeartPulseIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 14c1.5-2 3-4 3-6a5 5 0 0 0-9-3 5 5 0 0 0-9 3c0 2 1.5 4 3 6" />
      <path d="M10 14h3l1-3 2 5 1-2h3" />
      <path d="M3 20h18" />
    </svg>
  );
}

export function ShieldCheckIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z" />
      <path d="m9 12 2 2 4-4" />
    </svg>
  );
}

export function GraduationIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 10v6M2 10l10-5 10 5-10 5Z" />
      <path d="M6 12v5c3 2 9 2 12 0v-5" />
    </svg>
  );
}

export function CommunityIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M22 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}

export function CycleIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="8" />
      <path d="M12 6v6l3 3" />
      <path d="M12 2a10 10 0 0 1 8.66 5" />
      <path d="M2 12h2" />
    </svg>
  );
}

export function LeafIcon({ className = 'w-5 h-5' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M11 20A7 7 0 0 1 9.8 6.9C15.5 4.9 17 3.5 19 2c1 2 2 4.5 2 8 0 5-3 10-7 10Z" />
      <path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12" />
    </svg>
  );
}

export const bloomFemIcons = {
  flower: FlowerIcon,
  book: BookOpenIcon,
  health: HeartPulseIcon,
  shield: ShieldCheckIcon,
  graduation: GraduationIcon,
  community: CommunityIcon,
  cycle: CycleIcon,
  leaf: LeafIcon,
};
