'use client';

import { motion } from 'framer-motion';

const testimonials = [
  {
    name: 'Sarah M.',
    role: 'Freelance Designer',
    avatar: 'SM',
    rating: 5,
    text: "Thanks to escrow, I delivered the project without worrying about payment delays. I now confidently accept every job on Prolance.",
    avatarColor: 'from-violet-500 to-indigo-500',
  },
  {
    name: 'James T.',
    role: 'Client, SaaS Startup',
    avatar: 'JT',
    rating: 5,
    text: "The freelancer did outstanding work and payment was released from escrow automatically. Completely seamless — highly recommended.",
    avatarColor: 'from-brand to-indigo-400',
  },
  {
    name: 'Lena K.',
    role: 'Full-Stack Developer',
    avatar: 'LK',
    rating: 5,
    text: "I've had payment issues on other platforms. With Prolance's escrow protection I work with total peace of mind.",
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
    <section className="py-28 section-divider">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-14"
        >
          <span className="inline-block glass-card-subtle text-slate-400 text-xs font-semibold px-3 py-1.5 rounded-full mb-4">
            What People Say
          </span>
          <h2 className="text-3xl md:text-4xl font-display font-bold text-white">
            Real people, real trust
          </h2>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-3 gap-6">
          {testimonials.map((t, i) => (
            <motion.div
              key={t.name}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.14, duration: 0.5 }}
              whileHover={{ y: -4, transition: { duration: 0.2 } }}
              className="bg-dark-surface rounded-2xl p-6 border border-white/7 shadow-glass flex flex-col gap-4"
            >
              <Stars count={t.rating} />
              <p className="text-slate-400 text-sm leading-relaxed flex-1">&ldquo;{t.text}&rdquo;</p>
              <div className="flex items-center gap-3">
                <div
                  className={`w-10 h-10 rounded-full bg-gradient-to-br ${t.avatarColor} text-white text-xs font-bold flex items-center justify-center shrink-0`}
                >
                  {t.avatar}
                </div>
                <div>
                  <div className="text-sm font-semibold text-white">{t.name}</div>
                  <div className="text-xs text-slate-500">{t.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
