'use client';

import dynamic from 'next/dynamic';
import Image from 'next/image';
import { motion } from 'framer-motion';
import {
  formatCount,
  formatEscrowBand,
  formatRating,
  type LandingStats,
} from '@/lib/landing-stats';

const Hero3D = dynamic(() => import('../Hero3D'), { ssr: false });

const PHONE_SCREEN =
  'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=800&q=80';

const fadeUp = {
  hidden: { opacity: 0, y: 32 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.12, duration: 0.55, ease: [0.22, 1, 0.36, 1] },
  }),
};

export default function HeroSection({ stats }: { stats: LandingStats }) {
  const heroStats = [
    { value: formatCount(stats.userCount), label: 'Kullanıcı' },
    { value: formatEscrowBand(stats.escrowVolumeTry), label: 'Güvenli Ödeme' },
    { value: formatRating(stats.avgRating, stats.reviewCount), label: 'Mağaza Puanı' },
  ];
  return (
    <section className="relative min-h-screen flex items-center overflow-hidden bg-hero-gradient pt-24">
      <motion.div
        className="pointer-events-none absolute inset-0 -z-10"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1 }}
      >
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full bg-brand/10 blur-3xl" />
        <motion.div
          className="absolute top-1/2 right-0 w-[360px] h-[360px] rounded-full bg-indigo-100/60 blur-3xl"
          animate={{ scale: [1, 1.08, 1], opacity: [0.5, 0.7, 0.5] }}
          transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
        />
      </motion.div>

      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="max-w-6xl mx-auto px-6 py-20 grid lg:grid-cols-2 gap-12 items-center w-full"
      >
        <div className="flex flex-col gap-6">
          <motion.div
            custom={0}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="inline-flex items-center gap-2 bg-brand-light text-brand text-xs font-semibold px-3 py-1.5 rounded-full w-fit border border-brand/20"
          >
            <span className="w-2 h-2 rounded-full bg-brand animate-pulse" />
            Escrow Korumalı Ödeme Sistemi
          </motion.div>

          <motion.h1
            custom={1}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="text-4xl md:text-5xl lg:text-6xl font-extrabold leading-tight tracking-tight text-slate-900"
          >
            Freelance&apos;ı{' '}
            <span className="bg-gradient-to-r from-brand to-indigo-500 bg-clip-text text-transparent">
              Güvene Al
            </span>
          </motion.h1>

          <motion.p
            custom={2}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="text-lg text-slate-600 max-w-md leading-relaxed"
          >
            İşveren ödemeyi escrow&apos;a yatırır. Freelancer işi teslim eder. Para ancak onaydan
            sonra serbest bırakılır. Her iki taraf da korunur.
          </motion.p>

          <motion.div
            custom={3}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="flex flex-wrap gap-4"
          >
            <a
              href="#download"
              className="flex items-center gap-3 bg-slate-900 hover:bg-slate-700 text-white px-5 py-3 rounded-2xl transition-colors shadow-lg"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
                <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.7 9.05 7.4c1.29.08 2.21.75 3.01.75.79 0 2.27-.93 3.83-.79 1.5.12 2.91.73 3.72 1.96-3.44 2.05-2.87 6.56.44 7.96zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
              </svg>
              <motion.div className="flex flex-col leading-none" whileHover={{ x: 2 }}>
                <span className="text-[10px] text-slate-300">Download on the</span>
                <span className="text-[15px] font-semibold">App Store</span>
              </motion.div>
            </a>

            <a
              href="#download"
              className="flex items-center gap-3 border-2 border-slate-200 hover:border-brand hover:bg-brand-light text-slate-800 hover:text-brand px-5 py-3 rounded-2xl transition-all"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
                <path d="M3.18 23.76c.34.2.73.22 1.1.04l12.04-6.96-2.64-2.64-10.5 9.56zM20.62 9.38a2.1 2.1 0 0 0-.92-1.76L17.22 6.3l-2.94 2.94 2.94 2.94 2.42-1.4c.6-.34.98-.97.98-1.4zM1.24.34C1.04.58.92.93.92 1.35v21.3c0 .42.12.77.32 1.01l.06.06 11.94-11.94v-.28L1.3.28zM14.28 8.28L3.18.34l10.5 9.58 2.64-2.64z" />
              </svg>
              <motion.div className="flex flex-col leading-none" whileHover={{ x: 2 }}>
                <span className="text-[10px] text-slate-400">Get it on</span>
                <span className="text-[15px] font-semibold">Google Play</span>
              </motion.div>
            </a>
          </motion.div>

          <motion.div
            custom={4}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="flex items-center gap-6 mt-2"
          >
            {heroStats.map((stat) => (
              <motion.div key={stat.label} className="flex flex-col">
                <span className="text-xl font-extrabold text-slate-900">{stat.value}</span>
                <span className="text-xs text-slate-500">{stat.label}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.88 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          className="relative flex flex-col items-center justify-center gap-6 min-h-[380px] lg:min-h-[480px]"
        >
          <motion.div
            className="relative mx-auto w-[min(100%,280px)]"
            animate={{ y: [0, -8, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
          >
            <motion.div
              className="absolute -inset-4 rounded-[3rem] bg-gradient-to-br from-brand/30 via-indigo-400/20 to-violet-300/10 blur-2xl"
              animate={{ opacity: [0.5, 0.8, 0.5] }}
              transition={{ duration: 4, repeat: Infinity }}
            />
            <div className="relative rounded-[2.5rem] border-[10px] border-slate-900 bg-slate-900 shadow-2xl ring-1 ring-slate-800/80 overflow-hidden">
              <motion.div
                className="absolute top-0 inset-x-0 h-7 bg-slate-900 z-10 flex items-center justify-center"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
              >
                <div className="w-20 h-4 rounded-full bg-slate-800" />
              </motion.div>
              <div className="relative aspect-[9/19] w-[260px] max-w-full overflow-hidden rounded-[1.75rem] bg-slate-950">
                <Image
                  src={PHONE_SCREEN}
                  alt="Prolance uygulamasında iş ilanları"
                  fill
                  className="object-cover"
                  sizes="260px"
                  priority
                />
                <div className="absolute inset-0 bg-gradient-to-t from-slate-900/60 via-transparent to-transparent pointer-events-none" />
                <motion.div
                  className="absolute bottom-4 left-4 right-4 rounded-2xl bg-white/95 backdrop-blur-sm p-3 shadow-lg border border-white/50"
                  initial={{ opacity: 0, y: 12 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5, duration: 0.5 }}
                >
                  <p className="text-[10px] font-semibold text-brand uppercase tracking-wide">
                    Escrow aktif
                  </p>
                  <p className="text-sm font-bold text-slate-900 mt-0.5">₺12.500 güvende</p>
                  <p className="text-xs text-slate-500">Mobil uygulama · Web portal</p>
                </motion.div>
              </div>
            </div>
          </motion.div>

          <motion.div
            className="relative hidden lg:block w-full h-40 opacity-70"
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.7 }}
            transition={{ delay: 0.6, duration: 0.8 }}
          >
            <Hero3D />
          </motion.div>
        </motion.div>
      </motion.div>
    </section>
  );
}
