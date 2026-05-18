'use client';

import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type MagicCardProps = {
  children: ReactNode;
  className?: string;
  innerClassName?: string;
};

export function MagicCard({ children, className, innerClassName }: MagicCardProps) {
  return (
    <div
      className={cn(
        'relative rounded-3xl p-[1px] bg-gradient-to-br from-brand/40 via-indigo-400/30 to-violet-400/20 shadow-card',
        className,
      )}
    >
      <div
        className={cn(
          'relative rounded-[calc(1.5rem-1px)] bg-dark-surface border border-white/7',
          innerClassName,
        )}
      >
        {children}
      </div>
    </div>
  );
}
