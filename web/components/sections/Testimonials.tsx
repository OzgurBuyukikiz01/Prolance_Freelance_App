'use client';

import { motion } from 'framer-motion';

const testimonials = [
  {
    name: 'Merve K.',
    role: 'Freelance Tasarımcı',
    avatar: 'MK',
    rating: 5,
    text: 'Escrow sistemi sayesinde işveren ödemeyi bekletmeden proje teslim ettim. Artık her işi güvenle kabul ediyorum.',
    avatarColor: 'from-violet-500 to-indigo-500',
  },
  {
    name: 'Ahmet Y.',
    role: 'İşveren, SaaS Girişimi',
    avatar: 'AY',
    rating: 5,
    text: "Freelancer mükemmel iş çıkardı. Ödeme escrow'dan otomatik geçti, hiç sorun yaşamadık. Tavsiye ederim.",
    avatarColor: 'from-brand to-indigo-400',
  },
  {
    name: 'Selin T.',
    role: 'Full-Stack Geliştirici',
    avatar: 'ST',
    rating: 5,
    text: "Diğer platformlarda ödeme konusunda çok sorun yaşadım. Prolance'ın güvencesiyle çok daha huzurlu çalışıyorum.",
    avatarColor: 'from-emerald-500 to-teal-400',
  },
];

function Stars({ count }: { count: number }) {
  return (
    <div className="flex gap-0.5">
      {Array.from({ length: count }).map((_, i) => (
        <svg key={i} width="14" height="14" viewBox="0 0 24 24" fill="#FBBF24">
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
        </svg>
      ))}
    </div>
  );
}

export default function Testimonials() {
  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-14"
        >
          <span className="inline-block bg-amber-50 text-amber-600 text-xs font-semibold px-3 py-1.5 rounded-full mb-4 border border-amber-100">
            Kullanıcı Yorumları
          </span>
          <h2 className="text-3xl md:text-4xl font-extrabold text-slate-900">
            Gerçek insanlar, gerçek güven
          </h2>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((t, i) => (
            <motion.div
              key={t.name}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.14, duration: 0.5 }}
              className="bg-white rounded-2xl p-6 border border-slate-100 shadow-card flex flex-col gap-4"
            >
              <Stars count={t.rating} />
              <p className="text-slate-600 text-sm leading-relaxed flex-1">&ldquo;{t.text}&rdquo;</p>
              <div className="flex items-center gap-3">
                <div
                  className={`w-10 h-10 rounded-full bg-gradient-to-br ${t.avatarColor} text-white text-xs font-bold flex items-center justify-center`}
                >
                  {t.avatar}
                </div>
                <div>
                  <div className="text-sm font-semibold text-slate-900">{t.name}</div>
                  <div className="text-xs text-slate-400">{t.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
