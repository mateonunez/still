export function Mark({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 40 40" fill="none" aria-hidden="true">
      <path d="M13 7a15 15 0 1 0 14 0" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
      <circle cx="20" cy="5" r="2.6" fill="currentColor" />
    </svg>
  );
}
