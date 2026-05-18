'use client';

import { motion } from 'framer-motion';

const steps = [
  {
    number: '01',
    title: 'Client Funds Escrow',
    description:
      'The client deposits the milestone amount into Prolance escrow. Funds are secured and held — not yet released to the freelancer.',
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
    ),
  },
  {
    number: '02',
    title: 'Freelancer Delivers',
    description:
      'The freelancer completes the work and submits for review. Funds move to HELD status — neither party can access without agreement.',
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
      </svg>
    ),
  },
  {
    number: '03',
    title: 'Approve or Dispute',
    description:
      'If the client approves, funds are released to the freelancer. If there is an issue, the admin team steps in to resolve the dispute fairly.',
    icon: (
      <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  },
];

export default function HowItWorks() {
  return (
    <section id="how" className="py-28 section-divider">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-20"
        >
          <span className="inline-block glass-card-subtle text-slate-400 text-xs font-semibold px-3 py-1.5 rounded-full mb-4">
            Escrow Flow
          </span>
          <h2 className="text-3xl md:text-4xl font-display font-bold text-white">
            How It Works
          </h2>
          <p className="mt-4 text-slate-400 max-w-lg mx-auto">
            Three clear steps. Full protection for both parties on every transaction.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="relative grid md:grid-cols-3 gap-8">
          {/* Connector line */}
          <div className="hidden md:block absolute top-10 left-[calc(16.67%+1rem)] right-[calc(16.67%+1rem)] h-px bg-gradient-to-r from-brand/20 via-brand/60 to-brand/20" />

          {steps.map((step, i) => (
            <motion.div
              key={step.number}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.16, duration: 0.55, ease: [0.22, 1, 0.36, 1] }}
              className="relative flex flex-col items-center text-center"
            >
              {/* Large background number — editorial */}
              <div className="absolute -top-6 left-1/2 -translate-x-1/2 text-[5rem] font-display font-black text-white/4 leading-none select-none pointer-events-none">
                {step.number}
              </div>

              {/* Icon circle */}
              <div className="relative z-10 w-20 h-20 rounded-2xl bg-dark-surface border border-white/10 shadow-glass flex items-center justify-center mb-6">
                <div className="absolute -top-2 -right-2 w-6 h-6 bg-brand text-white text-[10px] font-black rounded-full flex items-center justify-center shadow-brand">
                  {i + 1}
                </div>
                <div className="text-brand">{step.icon}</div>
              </div>

              <h3 className="text-lg font-display font-semibold text-white mb-3">{step.title}</h3>
              <p className="text-slate-400 text-sm leading-relaxed max-w-xs">{step.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
