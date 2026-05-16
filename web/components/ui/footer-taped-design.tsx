import Link from 'next/link';
import { FOOTER_LINK_GROUPS } from '@/lib/site-footer-links';

export function FooterTapedDesign() {
  const year = new Date().getFullYear();

  return (
    <footer className="relative mt-8 border-t border-slate-800 bg-slate-900 text-slate-400">
      <div
        className="pointer-events-none absolute -top-3 left-1/2 h-8 w-28 -translate-x-1/2 rotate-[-2deg] bg-amber-100/90 shadow-md"
        aria-hidden
        style={{
          backgroundImage:
            'repeating-linear-gradient(90deg, transparent, transparent 4px, rgba(0,0,0,0.03) 4px, rgba(0,0,0,0.03) 8px)',
        }}
      />
      <div className="mx-auto max-w-6xl px-6 py-16">
        <div className="grid gap-12 md:grid-cols-4">
          <div className="flex flex-col gap-4">
            <Link href="/" className="flex items-center gap-2 text-xl font-bold text-white">
              <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-brand text-sm font-black text-white">
                P
              </span>
              Prolance
            </Link>
            <p className="max-w-xs text-sm leading-relaxed">
              İşveren ve freelancer arasında escrow koruması. Her iş, güvence altında.
            </p>
            <div className="mt-2 flex gap-3">
              {['Twitter', 'GitHub', 'LinkedIn'].map((label) => (
                <a
                  key={label}
                  href="#"
                  aria-label={label}
                  className="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-800 text-slate-400 transition-colors hover:bg-brand hover:text-white"
                >
                  <span className="text-xs font-semibold">{label[0]}</span>
                </a>
              ))}
            </div>
          </div>

          {Object.entries(FOOTER_LINK_GROUPS).map(([group, items]) => (
            <div key={group}>
              <h4 className="mb-4 text-sm font-semibold text-white">{group}</h4>
              <ul className="flex flex-col gap-3">
                {items.map((item) => (
                  <li key={item.label}>
                    <Link href={item.href} className="text-sm transition-colors hover:text-white">
                      {item.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-12 flex flex-col items-center justify-between gap-4 border-t border-slate-800 pt-6 text-xs sm:flex-row">
          <span>© {year} Prolance. Tüm hakları saklıdır.</span>
          <span className="flex items-center gap-1 text-slate-500">
            Made with
            <span className="text-red-400">♥</span>
            in Istanbul
          </span>
        </div>
      </div>
    </footer>
  );
}
