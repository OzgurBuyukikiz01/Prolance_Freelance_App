'use client';

import { motion } from 'framer-motion';

const features = [
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
      </svg>
    ),
    title: 'Escrow Protection',
    description:
      'Payment stays locked until delivery is confirmed. Neither party can access funds without mutual approval.',
    accent: 'from-brand/20 to-brand/5',
    iconColor: 'text-brand',
    borderHover: 'hover:border-brand/30',
    glow: 'hover:shadow-glow-violet',
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-4 4-4-4z" />
      </svg>
    ),
    title: 'Real-time Messaging',
    description:
      'Clients and freelancers communicate instantly. Messages, files, and offers in one unified workspace.',
    accent: 'from-indigo-500/20 to-indigo-500/5',
    iconColor: 'text-indigo-400',
    borderHover: 'hover:border-indigo-500/30',
    glow: 'hover:shadow-[0_0_40px_rgba(99,102,241,0.35)]',
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    title: 'Global Job Board',
    description:
      'Thousands of opportunities from around the world. Filter by category, budget, and skill level in seconds.',
    accent: 'from-accent/20 to-accent/5',
    iconColor: 'text-accent',
    borderHover: 'hover:border-accent/30',
    glow: 'hover:shadow-glow-coral',
  },
];

const cardVariants = {
  hidden: { opacity: 0, y: 40 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.14, duration: 0.55, ease: [0.22, 1, 0.36, 1] },
  }),
};

export default function FeaturesSection() {
  return (
    <section id="features" className="py-28 section-divider">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <span className="inline-block glass-card-subtle text-brand text-xs font-semibold px-3 py-1.5 rounded-full mb-4">
            Core Features
          </span>
          <h2 className="text-3xl md:text-4xl font-display font-bold text-white">
            Everything you need to work with confidence
          </h2>
          <p className="mt-4 text-slate-400 max-w-lg mx-auto">
            Built for both sides of every transaction — the client and the freelancer.
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-3 gap-6">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              custom={i}
              variants={cardVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
              whileHover={{ y: -6, transition: { duration: 0.2 } }}
              className={`group relative rounded-2xl p-7 bg-dark-surface border border-white/7 transition-all duration-300 ${f.borderHover} ${f.glow}`}
            >
              {/* Gradient top accent */}
              <div className={`absolute inset-x-0 top-0 h-px rounded-t-2xl bg-gradient-to-r ${f.accent}`} />

              {/* Icon */}
              <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${f.accent} flex items-center justify-center mb-5 ${f.iconColor}`}>
                {f.icon}
              </div>

              <h3 className="text-lg font-display font-semibold text-white mb-3">{f.title}</h3>
              <p className="text-slate-400 text-sm leading-relaxed">{f.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
