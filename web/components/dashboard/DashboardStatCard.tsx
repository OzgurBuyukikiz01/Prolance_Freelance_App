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
    <div className={cn(
      'glass-card p-6 h-36 flex flex-col justify-between',
      'hover:border-white/20 hover:bg-white/[0.06] transition-all duration-300',
      href && 'cursor-pointer',
    )}>
      <div className="text-sm text-white/50 font-medium">{title}</div>
      <div>
        <AnimatedNumber
          value={value}
          decimals={decimals}
          className={cn('text-4xl font-extrabold tabular-nums', accent)}
        />
        {sub && <div className="text-xs text-white/35 mt-1">{sub}</div>}
      </div>
    </div>
  );

  return href ? (
    <Link href={href} className="block group">
      {inner}
    </Link>
  ) : (
    inner
  );
}
