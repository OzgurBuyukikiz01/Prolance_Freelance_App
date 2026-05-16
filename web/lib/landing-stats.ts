export type LandingStats = {
  userCount: number;
  jobCount: number;
  escrowVolumeTry: number;
  avgRating: number;
  reviewCount: number;
};

export function formatCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace(/\.0$/, '')}M+`;
  if (n >= 10_000) return `${Math.floor(n / 1000)}K+`;
  if (n >= 1_000) return `${(n / 1000).toFixed(1).replace(/\.0$/, '')}K+`;
  if (n > 0) return `${n}+`;
  return '—';
}

/** Escrow display clamped to ₺10M–₺20M band per product rules. */
export function formatEscrowBand(volumeTry: number): string {
  const millions = volumeTry / 1_000_000;
  if (millions < 10) return '₺10M+';
  if (millions > 20) return '₺20M+';
  const rounded = Math.floor(millions);
  return rounded === millions ? `₺${rounded}M+` : `₺${millions.toFixed(1).replace(/\.0$/, '')}M+`;
}

export function formatRating(avgRating: number, reviewCount: number): string {
  const rating = reviewCount < 10 ? 4.9 : avgRating;
  return `${rating.toFixed(1)}★`;
}
