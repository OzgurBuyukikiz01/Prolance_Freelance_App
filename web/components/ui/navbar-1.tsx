'use client';

import { useEffect, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';

const LINKS = [
  { label: 'Özellikler', href: '#features' },
  { label: 'Nasıl Çalışır', href: '#how' },
  { label: 'Fiyatlandırma', href: '#pricing' },
  { label: 'Hakkımızda', href: '/about' },
  { label: 'Blog', href: '/blog' },
  { label: 'İletişim', href: '/contact' },
];

function ProlanceLogo() {
  return (
    <a href="#" className="flex items-center gap-2.5 font-bold text-slate-900 shrink-0">
      <span className="w-8 h-8 rounded-xl bg-brand flex items-center justify-center text-white text-sm font-black shadow-brand">
        P
      </span>
      <span className="text-lg tracking-tight">Prolance</span>
    </a>
  );
}

export type Navbar1Props = {
  authSlot?: React.ReactNode;
};

export function Navbar1({ authSlot }: Navbar1Props) {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header className="fixed top-0 inset-x-0 z-50 px-4 pt-4 pointer-events-none">
      <div
        className={`pointer-events-auto max-w-4xl mx-auto rounded-full border transition-all duration-300 ${
          scrolled
            ? 'bg-white/90 backdrop-blur-xl border-slate-200/80 shadow-card'
            : 'bg-white/70 backdrop-blur-md border-white/60 shadow-sm'
        }`}
      >
        <motion.div
          initial={{ opacity: 0, y: -12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
          className="flex items-center justify-between gap-4 px-4 sm:px-6 h-14"
        >
          <ProlanceLogo />

          <nav className="hidden md:flex items-center gap-1">
            {LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="text-sm font-medium text-slate-600 hover:text-brand px-3 py-1.5 rounded-full hover:bg-brand-light/80 transition-colors"
              >
                {link.label}
              </a>
            ))}
          </nav>

          <motion.div
            className="hidden md:flex items-center gap-2 shrink-0"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            {authSlot ?? (
              <a
                href="/login"
                className="inline-flex items-center gap-2 bg-brand hover:bg-brand-dark text-white text-sm font-semibold px-4 py-2 rounded-full transition-colors shadow-brand"
              >
                Giriş Yap
              </a>
            )}
          </motion.div>

          <button
            type="button"
            className="md:hidden p-2 rounded-full text-slate-600 hover:bg-slate-100"
            onClick={() => setMenuOpen((o) => !o)}
            aria-label="Menüyü aç"
            aria-expanded={menuOpen}
          >
            <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth={2}>
              {menuOpen ? (
                <path d="M6 6l12 12M6 18L18 6" />
              ) : (
                <path d="M3 6h18M3 12h18M3 18h18" />
              )}
            </svg>
          </button>
        </motion.div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              transition={{ duration: 0.2 }}
              className="md:hidden overflow-hidden border-t border-slate-100"
            >
              <motion.div
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -6 }}
                className="px-4 pb-4 pt-2 flex flex-col gap-2"
              >
                {LINKS.map((link) => (
                  <a
                    key={link.href}
                    href={link.href}
                    className="text-sm font-medium text-slate-700 py-2 px-3 rounded-xl hover:bg-slate-50"
                    onClick={() => setMenuOpen(false)}
                  >
                    {link.label}
                  </a>
                ))}
                <motion.div
                  className="pt-2"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.05 }}
                >
                  {authSlot ?? (
                    <a
                      href="/login"
                      className="block text-center bg-brand text-white text-sm font-semibold px-4 py-2.5 rounded-full"
                      onClick={() => setMenuOpen(false)}
                    >
                      Giriş Yap
                    </a>
                  )}
                </motion.div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </header>
  );
}
