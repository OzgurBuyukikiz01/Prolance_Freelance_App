'use client';

import { motion } from 'framer-motion';

export type StatsData = {
  userCount: number;
  jobCount: number;
};

function formatCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace(/\.0$/, '')}M+`;
  if (n >= 10_000) return `${Math.floor(n / 1000)}K+`;
  if (n >= 1_000) return `${(n / 1000).toFixed(1).replace(/\.0$/, '')}K+`;
  if (n > 0) return `${n}+`;
  return '—';
}

export default function Stats({ userCount, jobCount }: StatsData) {
  const stats = [
    { value: formatCount(userCount), label: 'Aktif Kullanıcı' },
    { value: formatCount(jobCount), label: 'Açık İlan' },
    { value: '₺50M+', label: 'Güvenli Escrow' },
    { value: '4.9★', label: 'Mağaza Puanı' },
  ];

  return (
    <section className="py-20 bg-slate-900">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5 }}
        className="max-w-6xl mx-auto px-6"
      >
        <div className="grid grid-cols-2 md:grid-cols-4 gap-10">
          {stats.map((s, i) => (
            <motion.div
              key={s.label}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1, duration: 0.5 }}
              className="text-center"
            >
              <motion.div
                initial={{ scale: 0.9 }}
                whileInView={{ scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 + 0.1, type: 'spring', stiffness: 200 }}
                className="text-4xl md:text-5xl font-extrabold bg-gradient-to-br from-white to-indigo-300 bg-clip-text text-transparent mb-2"
              >
                {s.value}
              </motion.div>
              <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 + 0.2 }}
                className="text-slate-400 text-sm font-medium"
              >
                {s.label}
              </motion.div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </section>
  );
}
