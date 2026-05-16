'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function Navbar({ authSlot }: { authSlot?: React.ReactNode }) {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const links = [
    { label: 'Özellikler', href: '#features' },
    { label: 'Nasıl Çalışır', href: '#how' },
    { label: 'Fiyatlandırma', href: '#pricing' },
  ];

  return (
    <header
      className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-white/90 backdrop-blur-md shadow-sm border-b border-slate-100'
          : 'bg-transparent'
      }`}
    >
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        {/* Logo */}
        <a href="#" className="flex items-center gap-2 font-bold text-xl text-slate-900">
          <span className="w-7 h-7 rounded-lg bg-brand flex items-center justify-center text-white text-sm font-black">
            P
          </span>
          Prolance
        </a>

        {/* Desktop nav */}
        <nav className="hidden md:flex items-center gap-8">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="text-sm font-medium text-slate-600 hover:text-brand transition-colors"
            >
              {l.label}
            </a>
          ))}
        </nav>

        {/* CTA / Auth */}
        <div className="hidden md:flex items-center gap-3">
          {authSlot ?? (
            <a
              href="/login"
              className="inline-flex items-center gap-2 bg-brand hover:bg-brand-dark text-white text-sm font-semibold px-4 py-2 rounded-xl transition-colors shadow-brand"
            >
              Giriş Yap
            </a>
          )}
        </div>

        {/* Mobile hamburger */}
        <button
          className="md:hidden p-2 rounded-lg text-slate-600 hover:bg-slate-100"
          onClick={() => setMenuOpen(!menuOpen)}
          aria-label="Menüyü aç"
        >
          <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth={2}>
            {menuOpen ? (
              <path d="M6 6l12 12M6 18L18 6" />
            ) : (
              <path d="M3 6h18M3 12h18M3 18h18" />
            )}
          </svg>
        </button>
      </div>

      {/* Mobile menu */}
      <AnimatePresence>
        {menuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="md:hidden bg-white border-t border-slate-100 px-6 py-4 flex flex-col gap-4"
          >
            {links.map((l) => (
              <a
                key={l.href}
                href={l.href}
                className="text-sm font-medium text-slate-700"
                onClick={() => setMenuOpen(false)}
              >
                {l.label}
              </a>
            ))}
            <a
              href="#download"
              className="bg-brand text-white text-sm font-semibold px-4 py-2 rounded-xl text-center"
              onClick={() => setMenuOpen(false)}
            >
              Uygulamayı İndir
            </a>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}
