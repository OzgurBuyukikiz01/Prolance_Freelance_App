'use client';

import { motion } from 'framer-motion';
import { TestimonialsColumn, type TestimonialItem } from '@/components/ui/testimonials-columns-1';

const testimonials: TestimonialItem[] = [
  {
    name: 'Merve K.',
    role: 'Freelance Tasarımcı',
    initials: 'MK',
    text: 'Escrow sistemi sayesinde işveren ödemeyi bekletmeden proje teslim ettim. Artık her işi güvenle kabul ediyorum.',
    avatarColor: 'from-violet-500 to-indigo-500',
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
  },
  {
    name: 'Ahmet Y.',
    role: 'İşveren, SaaS Girişimi',
    initials: 'AY',
    text: "Freelancer mükemmel iş çıkardı. Ödeme escrow'dan otomatik geçti, hiç sorun yaşamadık.",
    avatarColor: 'from-brand to-indigo-400',
    image: 'https://images.unsplash.com/photo-1507003211169-0bc1b2a0a0a0?w=80&h=80&fit=crop',
  },
  {
    name: 'Selin T.',
    role: 'Full-Stack Geliştirici',
    initials: 'ST',
    text: "Diğer platformlarda ödeme konusunda çok sorun yaşadım. Prolance'ın güvencesiyle çok daha huzurlu çalışıyorum.",
    avatarColor: 'from-emerald-500 to-teal-400',
    image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop',
  },
  {
    name: 'Can D.',
    role: 'Ürün Yöneticisi',
    initials: 'CD',
    text: 'Milestone takvimi ve escrow bir arada — ekip olarak süreç çok şeffaf ilerliyor.',
    avatarColor: 'from-amber-500 to-orange-400',
  },
  {
    name: 'Elif R.',
    role: 'İçerik Üreticisi',
    initials: 'ER',
    text: 'Teklif süreci hızlı, bildirimler anlık. Mobil uygulama da portal ile uyumlu.',
    avatarColor: 'from-pink-500 to-rose-400',
  },
  {
    name: 'Burak M.',
    role: 'Startup Kurucusu',
    initials: 'BM',
    text: 'İlk işbirliğimizde bile ödeme güvencesi sayesinde güven oluştu. Kesinlikle tavsiye ederim.',
    avatarColor: 'from-cyan-500 to-blue-400',
  },
];

const col1 = testimonials.filter((_, i) => i % 3 === 0);
const col2 = testimonials.filter((_, i) => i % 3 === 1);
const col3 = testimonials.filter((_, i) => i % 3 === 2);

export default function Testimonials() {
  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-6xl mx-auto px-6">
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

        <div className="hidden md:grid md:grid-cols-3 gap-6">
          <TestimonialsColumn items={col1} duration={28} />
          <TestimonialsColumn items={col2} duration={32} />
          <TestimonialsColumn items={col3} duration={26} />
        </div>

        <div className="md:hidden">
          <TestimonialsColumn items={testimonials} duration={30} className="h-[400px]" />
        </div>
      </div>
    </section>
  );
}
