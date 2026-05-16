'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

export type TestimonialItem = {
  name: string;
  role: string;
  text: string;
  image?: string;
  initials: string;
  avatarColor: string;
};

type TestimonialsColumnProps = {
  items: TestimonialItem[];
  duration?: number;
  className?: string;
};

export function TestimonialsColumn({ items, duration = 25, className }: TestimonialsColumnProps) {
  const doubled = [...items, ...items];

  return (
    <div className={cn('relative h-[520px] overflow-hidden', className)}>
      <motion.div
        className="flex flex-col gap-4"
        animate={{ y: ['0%', '-50%'] }}
        transition={{ duration, repeat: Infinity, ease: 'linear' }}
      >
        {doubled.map((item, i) => (
          <TestimonialCard key={`${item.name}-${i}`} item={item} />
        ))}
      </motion.div>
      <div className="pointer-events-none absolute inset-x-0 top-0 h-16 bg-gradient-to-b from-slate-50 to-transparent" />
      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-16 bg-gradient-to-t from-slate-50 to-transparent" />
    </div>
  );
}

function TestimonialCard({ item }: { item: TestimonialItem }) {
  return (
    <div className="rounded-2xl border border-slate-100 bg-white p-5 shadow-card">
      <p className="text-sm leading-relaxed text-slate-600">&ldquo;{item.text}&rdquo;</p>
      <div className="mt-4 flex items-center gap-3">
        {item.image ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={item.image} alt="" className="h-10 w-10 rounded-full object-cover" />
        ) : (
          <div
            className={cn(
              'flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br text-xs font-bold text-white',
              item.avatarColor,
            )}
          >
            {item.initials}
          </div>
        )}
        <div>
          <p className="text-sm font-semibold text-slate-900">{item.name}</p>
          <p className="text-xs text-slate-400">{item.role}</p>
        </div>
      </div>
    </div>
  );
}
