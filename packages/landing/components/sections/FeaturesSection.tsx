'use client';

import { motion } from 'framer-motion';

const features = [
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
      </svg>
    ),
    title: 'Escrow Koruması',
    description:
      'Ödeme teslimata kadar güvende tutulur. İşveren ve freelancer her ikisi de onaylamadan para transfer olmaz.',
    color: 'bg-brand-light text-brand',
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-4 4-4-4z" />
      </svg>
    ),
    title: 'Anlık Mesajlaşma',
    description:
      'İşveren ve freelancer gerçek zamanlı iletişim kurabilir. Realtime mesaj, dosya ve teklifler tek ekranda.',
    color: 'bg-indigo-50 text-indigo-600',
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.7}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    title: 'Global İş İlanları',
    description:
      'Türkiye ve dünyadan binlerce iş ilanı. Kategori ve bütçe filtreleriyle anında eşleşme.',
    color: 'bg-violet-50 text-violet-600',
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
    <section id="features" className="py-24 bg-white">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-14"
        >
          <span className="inline-block bg-brand-light text-brand text-xs font-semibold px-3 py-1.5 rounded-full mb-4 border border-brand/20">
            Neden Prolance?
          </span>
          <h2 className="text-3xl md:text-4xl font-extrabold text-slate-900 leading-tight">
            Her işin arkasında bir güvence
          </h2>
          <p className="mt-4 text-slate-500 max-w-xl mx-auto text-base">
            Freelance dünyasının güven sorununu ortadan kaldıracak araçlarla donanmış bir platform.
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-3 gap-8">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              custom={i}
              variants={cardVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
              whileHover={{ y: -6, transition: { duration: 0.2 } }}
              className="bg-white rounded-2xl p-8 border border-slate-100 shadow-card hover:shadow-card-hover transition-shadow cursor-default"
            >
              <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mb-5 ${f.color}`}>
                {f.icon}
              </div>
              <h3 className="text-lg font-bold text-slate-900 mb-2">{f.title}</h3>
              <p className="text-slate-500 text-sm leading-relaxed">{f.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
