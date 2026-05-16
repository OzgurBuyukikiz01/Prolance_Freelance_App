'use client';

import Link from 'next/link';
import { AnimatedNumber } from '@/components/ui/animated-number';
import { cn } from '@/lib/utils';

type DashboardStatCardProps = {
  title: string;
  value: number;
  sub?: string;
  href?: string;
  accent?: string;
  decimals?: number;
};

export function DashboardStatCard({
  title,
  value,
  sub,
  href,
  accent = 'text-white',
  decimals = 0,
}: DashboardStatCardProps) {
  const inner = (
    <div className="rounded-2xl border border-slate-800 bg-slate-900/80 p-6 hover:border-[#6C63FF]/40 transition-colors h-full">
      <div className="text-sm text-slate-400 mb-2">{title}</div>
      <AnimatedNumber
        value={value}
        decimals={decimals}
        className={cn('text-4xl font-extrabold tabular-nums', accent)}
      />
      {sub && <div className="text-xs text-slate-500 mt-1.5">{sub}</div>}
    </div>
  );

  return href ? (
    <Link href={href} className="block">
      {inner}
    </Link>
  ) : (
    inner
  );
}
