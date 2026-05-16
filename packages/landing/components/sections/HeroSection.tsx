'use client';

import dynamic from 'next/dynamic';
import { motion } from 'framer-motion';

const Hero3D = dynamic(() => import('../Hero3D'), { ssr: false });

const fadeUp = {
  hidden: { opacity: 0, y: 32 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.12, duration: 0.55, ease: [0.22, 1, 0.36, 1] },
  }),
};

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex items-center overflow-hidden bg-hero-gradient pt-16">
      {/* Background blobs */}
      <div className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full bg-brand/10 blur-3xl" />
        <div className="absolute top-1/2 right-0 w-[360px] h-[360px] rounded-full bg-indigo-100/60 blur-3xl" />
      </div>

      <div className="max-w-6xl mx-auto px-6 py-20 grid lg:grid-cols-2 gap-12 items-center w-full">
        {/* Left copy */}
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
            {/* App Store Button */}
            <a
              href="#download"
              className="flex items-center gap-3 bg-slate-900 hover:bg-slate-700 text-white px-5 py-3 rounded-2xl transition-colors shadow-lg"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.7 9.05 7.4c1.29.08 2.21.75 3.01.75.79 0 2.27-.93 3.83-.79 1.5.12 2.91.73 3.72 1.96-3.44 2.05-2.87 6.56.44 7.96zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
              </svg>
              <div className="flex flex-col leading-none">
                <span className="text-[10px] text-slate-300">Download on the</span>
                <span className="text-[15px] font-semibold">App Store</span>
              </div>
            </a>

            {/* Google Play Button */}
            <a
              href="#download"
              className="flex items-center gap-3 border-2 border-slate-200 hover:border-brand hover:bg-brand-light text-slate-800 hover:text-brand px-5 py-3 rounded-2xl transition-all"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3.18 23.76c.34.2.73.22 1.1.04l12.04-6.96-2.64-2.64-10.5 9.56zM20.62 9.38a2.1 2.1 0 0 0-.92-1.76L17.22 6.3l-2.94 2.94 2.94 2.94 2.42-1.4c.6-.34.98-.97.98-1.4zM1.24.34C1.04.58.92.93.92 1.35v21.3c0 .42.12.77.32 1.01l.06.06 11.94-11.94v-.28L1.3.28zM14.28 8.28L3.18.34l10.5 9.58 2.64-2.64z" />
              </svg>
              <div className="flex flex-col leading-none">
                <span className="text-[10px] text-slate-400 group-hover:text-brand/70">Get it on</span>
                <span className="text-[15px] font-semibold">Google Play</span>
              </div>
            </a>
          </motion.div>

          {/* Trust badges */}
          <motion.div
            custom={4}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="flex items-center gap-6 mt-2"
          >
            {[
              { value: '10K+', label: 'Kullanıcı' },
              { value: '₺50M+', label: 'Güvenli Ödeme' },
              { value: '4.9★', label: 'Mağaza Puanı' },
            ].map((stat) => (
              <div key={stat.label} className="flex flex-col">
                <span className="text-xl font-extrabold text-slate-900">{stat.value}</span>
                <span className="text-xs text-slate-500">{stat.label}</span>
              </div>
            ))}
          </motion.div>
        </div>

        {/* Right 3D */}
        <motion.div
          initial={{ opacity: 0, scale: 0.88 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          className="relative h-[420px] lg:h-[540px]"
        >
          <Hero3D />
        </motion.div>
      </div>
    </section>
  );
}
