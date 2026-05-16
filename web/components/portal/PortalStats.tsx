'use client';

import { AnimatedNumber } from '@/components/ui/animated-number';

type PortalStatsProps = {
  completedJobs: number;
  rating: number | null;
  totalEarnings: number;
};

export function PortalStats({ completedJobs, rating, totalEarnings }: PortalStatsProps) {
  return (
    <div className="grid grid-cols-3 gap-4 py-4 border-t border-b border-slate-100 mb-6">
      <div className="text-center">
        <AnimatedNumber
          value={completedJobs}
          className="text-xl font-extrabold text-slate-900 tabular-nums"
        />
        <p className="text-xs text-slate-400 mt-0.5">Tamamlanan İş</p>
      </div>
      <div className="text-center">
        <div className="text-xl font-extrabold text-slate-900 tabular-nums">
          {rating != null ? (
            <>
              <AnimatedNumber value={rating} decimals={1} />
              <span>★</span>
            </>
          ) : (
            '—'
          )}
        </div>
        <p className="text-xs text-slate-400 mt-0.5">Puan</p>
      </div>
      <div className="text-center">
        <AnimatedNumber
          value={totalEarnings}
          prefix="₺"
          className="text-xl font-extrabold text-slate-900 tabular-nums"
        />
        <p className="text-xs text-slate-400 mt-0.5">Toplam Kazanç</p>
      </div>
    </div>
  );
}
