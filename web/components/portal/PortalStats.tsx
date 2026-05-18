'use client';

import { AnimatedNumber } from '@/components/ui/animated-number';

type PortalStatsProps = {
  completedJobs: number;
  rating: number | null;
  totalEarnings: number;
};

export function PortalStats({ completedJobs, rating, totalEarnings }: PortalStatsProps) {
  return (
    <div className="grid grid-cols-3 gap-4 py-4 border-t border-b border-white/8 mb-6">
      <div className="text-center">
        <AnimatedNumber
          value={completedJobs}
          className="text-xl font-extrabold text-white tabular-nums"
        />
        <p className="text-xs text-slate-400 mt-0.5">Completed Jobs</p>
      </div>
      <div className="text-center">
        <div className="text-xl font-extrabold text-white tabular-nums">
          {rating != null ? (
            <>
              <AnimatedNumber value={rating} decimals={1} />
              <span>★</span>
            </>
          ) : (
            '—'
          )}
        </div>
        <p className="text-xs text-slate-400 mt-0.5">Rating</p>
      </div>
      <div className="text-center">
        <AnimatedNumber
          value={totalEarnings}
          prefix="$"
          className="text-xl font-extrabold text-white tabular-nums"
        />
        <p className="text-xs text-slate-400 mt-0.5">Total Earnings</p>
      </div>
    </div>
  );
}
