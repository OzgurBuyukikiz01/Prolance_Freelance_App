'use client';

import dynamic from 'next/dynamic';
import Image from 'next/image';
import { motion } from 'framer-motion';

const Hero3D = dynamic(() => import('../Hero3D'), { ssr: false });

const PHONE_SCREEN =
  'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=800&q=80';

const fadeUp = {
  hidden: { opacity: 0, y: 36 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.12, duration: 0.65, ease: [0.22, 1, 0.36, 1] },
  }),
};

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden pt-24 pb-20 px-6">
      {/* Content */}
      <div className="max-w-4xl mx-auto text-center flex flex-col items-center gap-8 w-full">
        {/* Badge */}
        <motion.div
          custom={0}
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="inline-flex items-center gap-2 bg-white/5 border border-white/12 text-slate-300 text-xs font-semibold px-4 py-2 rounded-full backdrop-blur-sm"
        >
          <span className="w-1.5 h-1.5 rounded-full bg-brand animate-pulse" />
          Escrow-Protected Payments
        </motion.div>

        {/* Headline */}
        <motion.h1
          custom={1}
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="text-6xl md:text-7xl lg:text-8xl font-display font-bold leading-[1.05] tracking-tight text-white"
        >
          Trust Your{' '}
          <br />
          <span className="bg-gradient-to-r from-brand via-violet-400 to-accent bg-clip-text text-transparent">
            Freelance Work.
          </span>
        </motion.h1>

        {/* Description */}
        <motion.p
          custom={2}
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="text-lg md:text-xl text-slate-400 max-w-2xl leading-relaxed"
        >
          Clients deposit into escrow. Freelancers deliver. Funds release only after
          mutual approval. Both sides are always protected.
        </motion.p>

        {/* CTAs */}
        <motion.div
          custom={3}
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="flex flex-wrap items-center justify-center gap-4"
        >
          <a
            href="#download"
            className="flex items-center gap-3 bg-white hover:bg-slate-100 text-slate-900 px-5 py-3 rounded-2xl transition-colors shadow-lg font-semibold"
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
              <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.7 9.05 7.4c1.29.08 2.21.75 3.01.75.79 0 2.27-.93 3.83-.79 1.5.12 2.91.73 3.72 1.96-3.44 2.05-2.87 6.56.44 7.96zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
            </svg>
            <motion.div className="flex flex-col leading-none" whileHover={{ x: 2 }}>
              <span className="text-[9px] text-slate-500">Download on the</span>
              <span className="text-[14px] font-semibold">App Store</span>
            </motion.div>
          </a>

          <a
            href="#download"
            className="flex items-center gap-3 bg-white/8 border border-white/12 hover:bg-white/14 hover:border-brand/50 text-white px-5 py-3 rounded-2xl transition-all backdrop-blur-sm"
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
              <path d="M3.18 23.76c.34.2.73.22 1.1.04l12.04-6.96-2.64-2.64-10.5 9.56zM20.62 9.38a2.1 2.1 0 0 0-.92-1.76L17.22 6.3l-2.94 2.94 2.94 2.94 2.42-1.4c.6-.34.98-.97.98-1.4zM1.24.34C1.04.58.92.93.92 1.35v21.3c0 .42.12.77.32 1.01l.06.06 11.94-11.94v-.28L1.3.28zM14.28 8.28L3.18.34l10.5 9.58 2.64-2.64z" />
            </svg>
            <motion.div className="flex flex-col leading-none" whileHover={{ x: 2 }}>
              <span className="text-[9px] text-slate-400">Get it on</span>
              <span className="text-[14px] font-semibold">Google Play</span>
            </motion.div>
          </a>
        </motion.div>

        {/* Stats row */}
        <motion.div
          custom={4}
          variants={fadeUp}
          initial="hidden"
          animate="visible"
          className="flex items-center gap-8 mt-2"
        >
          {[
            { value: '10K+',  label: 'Active Users' },
            { value: '$50M+', label: 'Secured' },
            { value: '4.9★',  label: 'App Rating' },
          ].map((stat, i) => (
            <motion.div
              key={stat.label}
              className="flex flex-col items-center gap-0.5"
              whileHover={{ y: -2 }}
              transition={{ delay: i * 0.05 }}
            >
              <span className="text-xl font-display font-bold text-white">{stat.value}</span>
              <span className="text-xs text-slate-500">{stat.label}</span>
            </motion.div>
          ))}
        </motion.div>

        {/* Phone mockup */}
        <motion.div
          initial={{ opacity: 0, scale: 0.88, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          transition={{ duration: 0.9, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
          className="relative mt-8 w-full max-w-xs mx-auto"
        >
          {/* Glow behind phone */}
          <div className="absolute inset-0 -z-10 rounded-[3rem] bg-brand/20 blur-3xl scale-110" />

          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
            className="relative mx-auto w-[min(100%,260px)]"
          >
            <div className="relative rounded-[2.5rem] border-[10px] border-white/10 bg-dark-surface shadow-glass ring-1 ring-white/5 overflow-hidden">
              <div className="absolute top-0 inset-x-0 h-7 bg-dark-surface z-10 flex items-center justify-center">
                <div className="w-20 h-4 rounded-full bg-white/10" />
              </div>
              <div className="relative aspect-[9/19] w-[240px] max-w-full overflow-hidden rounded-[1.75rem] bg-dark-base">
                <Image
                  src={PHONE_SCREEN}
                  alt="Prolance app — job listings"
                  fill
                  className="object-cover opacity-80"
                  sizes="240px"
                  priority
                />
                <div className="absolute inset-0 bg-gradient-to-t from-dark-base/80 via-transparent to-transparent pointer-events-none" />
                <motion.div
                  className="absolute bottom-4 left-3 right-3 rounded-2xl bg-white/10 backdrop-blur-md p-3 border border-white/15"
                  initial={{ opacity: 0, y: 12 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.8, duration: 0.5 }}
                >
                  <p className="text-[9px] font-semibold text-brand uppercase tracking-wide">
                    Escrow Active
                  </p>
                  <p className="text-sm font-bold text-white mt-0.5">$3,200 secured</p>
                  <p className="text-xs text-slate-400">Mobile app · Web portal</p>
                </motion.div>
              </div>
            </div>
          </motion.div>

          {/* 3D element */}
          <motion.div
            className="relative w-full h-32 opacity-60 mt-4 hidden sm:block"
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.6 }}
            transition={{ delay: 0.8, duration: 0.8 }}
          >
            <Hero3D />
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
