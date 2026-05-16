'use client';

import { motion } from 'framer-motion';

const steps = [
  {
    number: '01',
    title: "İşveren Escrow'a Yatırır",
    description:
      "İşveren milestone tutarını Prolance escrow hesabına yatırır. Para güvende bekler, freelancer'a geçmez.",
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
    ),
  },
  {
    number: '02',
    title: 'Freelancer Teslim Eder',
    description:
      "Freelancer işi tamamlar ve teslim eder. Fonlar HELD durumuna geçer \u2014 iki taraf da anlaşmadıkça hareket edemez.",
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
      </svg>
    ),
  },
  {
    number: '03',
    title: 'Onay veya Anlaşmazlık',
    description:
      "İşveren onaylarsa para freelancer'a aktarılır. Sorun varsa admin ekibi devreye girerek anlaşmazlığı çözer.",
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  },
];

export default function HowItWorks() {
  return (
    <section id="how" className="py-24 bg-slate-50">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <span className="inline-block bg-indigo-50 text-indigo-600 text-xs font-semibold px-3 py-1.5 rounded-full mb-4 border border-indigo-100">
            Escrow Akışı
          </span>
          <h2 className="text-3xl md:text-4xl font-extrabold text-slate-900">
            Nasıl Çalışır?
          </h2>
          <p className="mt-4 text-slate-500 max-w-lg mx-auto">
            Üç adımda her iki tarafı da koruyan, şeffaf bir ödeme deneyimi.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="relative grid md:grid-cols-3 gap-8">
          {/* Connector line */}
          <div className="hidden md:block absolute top-10 left-[calc(16.67%+1rem)] right-[calc(16.67%+1rem)] h-0.5 bg-gradient-to-r from-brand/30 via-brand to-indigo-400/30" />

          {steps.map((step, i) => (
            <motion.div
              key={step.number}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.16, duration: 0.55, ease: [0.22, 1, 0.36, 1] }}
              className="relative flex flex-col items-center text-center"
            >
              {/* Circle with number */}
              <div className="relative z-10 w-20 h-20 rounded-full bg-white border-2 border-brand/20 shadow-brand flex items-center justify-center mb-6">
                <div className="absolute -top-2 -right-2 w-6 h-6 bg-brand text-white text-[10px] font-black rounded-full flex items-center justify-center">
                  {step.number}
                </div>
                <div className="text-brand">{step.icon}</div>
              </div>
              <h3 className="text-lg font-bold text-slate-900 mb-2">{step.title}</h3>
              <p className="text-slate-500 text-sm leading-relaxed max-w-xs">{step.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
