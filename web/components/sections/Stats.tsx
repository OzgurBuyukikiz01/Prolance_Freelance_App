'use client';

import { motion } from 'framer-motion';
import {
  applyStatFloors,
  formatCount,
  formatEscrowBand,
  formatRating,
  type LandingStats,
} from '@/lib/landing-stats';

export type StatsData = LandingStats;

export default function Stats({ stats: rawStats }: { stats: LandingStats }) {
  const stats = applyStatFloors(rawStats);
  const items = [
    { value: formatCount(stats.userCount), label: 'Aktif Kullanıcı' },
    { value: formatCount(stats.jobCount), label: 'Açık İlan' },
    { value: formatEscrowBand(stats.escrowVolumeTry), label: 'Güvenli Escrow' },
    { value: formatRating(stats.avgRating, stats.reviewCount), label: 'Mağaza Puanı' },
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
        <motion.div className="grid grid-cols-2 md:grid-cols-4 gap-10">
          {items.map((s, i) => (
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
        </motion.div>
      </motion.div>
    </section>
  );
}
