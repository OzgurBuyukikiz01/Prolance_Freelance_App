export type LandingStats = {
  userCount: number;
  jobCount: number;
  escrowVolumeTry: number;
  avgRating: number;
  reviewCount: number;
};

/** Minimum displayed values when DB counts are low (marketing floors). */
export const STAT_FLOORS = {
  userCount: 5200,
  jobCount: 1400,
  escrowVolumeTry: 10_000_000,
  reviewCount: 980,
} as const;

export function applyStatFloors(stats: LandingStats): LandingStats {
  return {
    userCount: Math.max(stats.userCount, STAT_FLOORS.userCount),
    jobCount: Math.max(stats.jobCount, STAT_FLOORS.jobCount),
    escrowVolumeTry: Math.max(stats.escrowVolumeTry, STAT_FLOORS.escrowVolumeTry),
    reviewCount: Math.max(stats.reviewCount, STAT_FLOORS.reviewCount),
    avgRating:
      stats.reviewCount < STAT_FLOORS.reviewCount ? 4.9 : stats.avgRating,
  };
}

export function formatCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace(/\.0$/, '')}M+`;
  if (n >= 10_000) return `${Math.floor(n / 1000)}K+`;
  if (n >= 1_000) return `${(n / 1000).toFixed(1).replace(/\.0$/, '')}K+`;
  if (n > 0) return `${n}+`;
  return '—';
}

/** Escrow display clamped to ₺10M–₺20M band per product rules. */
export function formatEscrowBand(volumeTry: number): string {
  const floored = Math.max(volumeTry, STAT_FLOORS.escrowVolumeTry);
  const millions = floored / 1_000_000;
  if (millions < 10) return '₺10M+';
  if (millions > 20) return '₺20M+';
  const rounded = Math.floor(millions);
  return rounded === millions ? `₺${rounded}M+` : `₺${millions.toFixed(1).replace(/\.0$/, '')}M+`;
}

/** Short escrow label for hero phone overlay (e.g. ₺12M güvende). */
export function formatEscrowHero(volumeTry: number): string {
  const floored = Math.max(volumeTry, STAT_FLOORS.escrowVolumeTry);
  const millions = Math.max(10, Math.floor(floored / 1_000_000));
  return `₺${millions}M güvende`;
}

export function formatRating(avgRating: number, reviewCount: number): string {
  const rating = reviewCount < 10 ? 4.9 : avgRating;
  return `${rating.toFixed(1)}★`;
}
