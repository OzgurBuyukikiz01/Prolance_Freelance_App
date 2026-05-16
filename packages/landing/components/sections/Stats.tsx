'use client';

import { motion } from 'framer-motion';

const stats = [
  { value: '10K+', label: 'Aktif Freelancer' },
  { value: '₺50M+', label: 'Güvenli Escrow' },
  { value: '98%', label: 'Memnuniyet' },
  { value: '4.9★', label: 'Mağaza Puanı' },
];

export default function Stats() {
  return (
    <section className="py-20 bg-slate-900">
      <div className="max-w-6xl mx-auto px-6">
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
              <div className="text-4xl md:text-5xl font-extrabold bg-gradient-to-br from-white to-indigo-300 bg-clip-text text-transparent mb-2">
                {s.value}
              </div>
              <div className="text-slate-400 text-sm font-medium">{s.label}</div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
