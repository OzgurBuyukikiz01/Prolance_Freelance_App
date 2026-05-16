import Link from 'next/link';

type LegalFooterNavProps = {
  current: 'privacy' | 'terms' | 'cookies';
};

const links = [
  { key: 'privacy' as const, href: '/privacy', label: 'Gizlilik' },
  { key: 'terms' as const, href: '/terms', label: 'Koşullar' },
  { key: 'cookies' as const, href: '/cookies', label: 'Çerezler' },
];

export default function LegalFooterNav({ current }: LegalFooterNavProps) {
  return (
    <div className="mt-12 border-t border-slate-100 pt-8 space-y-4">
      <div className="flex flex-wrap items-center justify-center gap-x-4 gap-y-2 text-sm">
        {links.map((link) => (
          <Link
            key={link.key}
            href={link.href}
            className={
              link.key === current
                ? 'font-semibold text-indigo-600'
                : 'text-slate-500 hover:text-indigo-600 transition-colors'
            }
            aria-current={link.key === current ? 'page' : undefined}
          >
            {link.label}
          </Link>
        ))}
      </div>
      <div className="text-center">
        <Link
          href="/"
          className="text-sm text-slate-400 hover:text-indigo-600 transition-colors"
        >
          ← Ana Sayfaya Dön
        </Link>
      </div>
    </div>
  );
}
