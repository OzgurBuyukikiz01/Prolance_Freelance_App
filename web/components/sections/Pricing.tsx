'use client';

import { motion } from 'framer-motion';

const plans = [
  {
    name: 'Free',
    price: '$0',
    period: '/month',
    description: 'Everything you need to get started.',
    features: [
      'Browse unlimited job listings',
      'Submit up to 5 proposals',
      'Basic messaging',
      'Post up to 5 job listings',
      '5% platform fee',
    ],
    cta: 'Get Started',
    href: '#download',
    highlighted: false,
  },
  {
    name: 'Pro',
    price: '$29',
    period: '/month',
    description: 'For serious freelancers and clients.',
    badge: 'Coming Soon',
    features: [
      'Unlimited proposals',
      'Unlimited escrow transactions',
      'Priority support',
      'Unlimited job postings',
      '1.5% platform fee',
      'Featured profile placement',
    ],
    cta: 'Get Notified',
    href: '#download',
    highlighted: true,
  },
];

export default function Pricing() {
  return (
    <section id="pricing" className="py-28 section-divider">
      <div className="max-w-5xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-14"
        >
          <span className="inline-block glass-card-subtle text-slate-400 text-xs font-semibold px-3 py-1.5 rounded-full mb-4">
            Pricing
          </span>
          <h2 className="text-3xl md:text-4xl font-display font-bold text-white">
            Simple, transparent pricing
          </h2>
          <p className="mt-4 text-slate-400 max-w-lg mx-auto">
            No hidden fees. No credit card required to start.
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-2 gap-8 max-w-3xl mx-auto">
          {plans.map((plan, i) => (
            <motion.div
              key={plan.name}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.15, duration: 0.55 }}
              whileHover={{ y: -4, transition: { duration: 0.2 } }}
              className={`relative rounded-2xl p-8 flex flex-col gap-6 ${
                plan.highlighted
                  ? 'bg-gradient-to-br from-brand/30 via-brand/10 to-indigo-900/20 border border-brand/40 shadow-brand-lg'
                  : 'bg-dark-surface border border-white/8 shadow-glass'
              }`}
            >
              {plan.badge && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-amber-400 text-amber-900 text-xs font-bold px-3 py-1 rounded-full shadow">
                  {plan.badge}
                </span>
              )}

              <div>
                <div className={`text-sm font-semibold mb-1 ${plan.highlighted ? 'text-brand' : 'text-slate-400'}`}>
                  {plan.name}
                </div>
                <div className="flex items-baseline gap-1">
                  <span className="text-4xl font-display font-bold text-white">{plan.price}</span>
                  <span className="text-sm text-slate-500">{plan.period}</span>
                </div>
                <p className="text-sm mt-2 text-slate-400">{plan.description}</p>
              </div>

              <ul className="flex flex-col gap-3">
                {plan.features.map((f) => (
                  <li key={f} className="flex items-center gap-2 text-sm">
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth={2.5}
                      className={plan.highlighted ? 'text-brand' : 'text-slate-500'}
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                    <span className="text-slate-300">{f}</span>
                  </li>
                ))}
              </ul>

              <a
                href={plan.href}
                className={`mt-auto text-center font-semibold text-sm px-6 py-3 rounded-xl transition-all ${
                  plan.highlighted
                    ? 'bg-brand text-white hover:bg-brand-dark shadow-brand'
                    : 'bg-white/8 text-white border border-white/12 hover:bg-white/14'
                }`}
              >
                {plan.cta}
              </a>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
