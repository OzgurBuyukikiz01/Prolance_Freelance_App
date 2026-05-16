'use client';

import { motion } from 'framer-motion';

const plans = [
  {
    name: 'Ücretsiz',
    price: '₺0',
    period: '/ay',
    description: 'Başlamak için gereken her şey.',
    features: [
      'Sınırsız iş ilanı görüntüle',
      '5 teklife kadar gönder',
      'Temel mesajlaşma',
      '5 iş ilanı yayınla',
      '%5 komisyon',
    ],
    cta: 'Hemen Başla',
    href: '#download',
    highlighted: false,
  },
  {
    name: 'Pro',
    price: '₺299',
    period: '/ay',
    description: "Ciddi freelancer'lar ve işverenler için.",
    badge: 'Çok Yakında',
    features: [
      'Sınırsız teklif gönder',
      'Sınırsız escrow işlemi',
      'Öncelikli destek',
      'Sınırsız iş ilanı yayınla',
      '%1.5 komisyon',
      'Öne çıkarılan profil',
    ],
    cta: 'Bildirim Al',
    href: '#download',
    highlighted: true,
  },
];

export default function Pricing() {
  return (
    <section id="pricing" className="py-24 bg-white">
      <div className="max-w-5xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-14"
        >
          <span className="inline-block bg-violet-50 text-violet-600 text-xs font-semibold px-3 py-1.5 rounded-full mb-4 border border-violet-100">
            Fiyatlandırma
          </span>
          <h2 className="text-3xl md:text-4xl font-extrabold text-slate-900">
            Basit ve şeffaf fiyatlar
          </h2>
          <p className="mt-4 text-slate-500 max-w-lg mx-auto">
            Gizli ücret yok. Başlamak için kredi kartı gerekmez.
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
              className={`relative rounded-2xl p-8 flex flex-col gap-6 ${
                plan.highlighted
                  ? 'bg-gradient-to-br from-brand via-indigo-600 to-violet-600 text-white shadow-brand'
                  : 'bg-white border border-slate-200 shadow-card text-slate-900'
              }`}
            >
              {plan.badge && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-amber-400 text-amber-900 text-xs font-bold px-3 py-1 rounded-full shadow">
                  {plan.badge}
                </span>
              )}

              <div>
                <div className={`text-sm font-semibold mb-1 ${plan.highlighted ? 'text-indigo-100' : 'text-slate-500'}`}>
                  {plan.name}
                </div>
                <div className="flex items-baseline gap-1">
                  <span className="text-4xl font-extrabold">{plan.price}</span>
                  <span className={`text-sm ${plan.highlighted ? 'text-indigo-200' : 'text-slate-400'}`}>{plan.period}</span>
                </div>
                <p className={`text-sm mt-2 ${plan.highlighted ? 'text-indigo-100' : 'text-slate-500'}`}>
                  {plan.description}
                </p>
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
                      className={plan.highlighted ? 'text-indigo-200' : 'text-brand'}
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                    <span className={plan.highlighted ? 'text-indigo-50' : 'text-slate-700'}>{f}</span>
                  </li>
                ))}
              </ul>

              <a
                href={plan.href}
                className={`mt-auto text-center font-semibold text-sm px-6 py-3 rounded-xl transition-all ${
                  plan.highlighted
                    ? 'bg-white text-brand hover:bg-indigo-50'
                    : 'bg-brand text-white hover:bg-brand-dark shadow-brand'
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
