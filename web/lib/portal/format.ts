export function formatBudget(min: number, max: number, type?: string): string {
  const fmt = (n: number) =>
    new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 0 }).format(n);
  if (min === max) return `₺${fmt(min)}`;
  return `₺${fmt(min)} – ₺${fmt(max)}`;
}

export function formatRelativeTime(iso: string): string {
  const date = new Date(iso);
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60_000);
  if (mins < 1) return 'Az önce';
  if (mins < 60) return `${mins} dk önce`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours} sa önce`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days} gün önce`;
  return date.toLocaleDateString('tr-TR', { day: 'numeric', month: 'short' });
}

export function parseSkills(raw: unknown): string[] {
  if (Array.isArray(raw)) return raw.map((s) => String(s));
  return [];
}

export const PROPOSAL_STATUS_LABELS: Record<string, { label: string; className: string }> = {
  pending: { label: 'Beklemede', className: 'bg-amber-50 text-amber-700 border-amber-200' },
  accepted: { label: 'Kabul edildi', className: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
  rejected: { label: 'Reddedildi', className: 'bg-red-50 text-red-700 border-red-200' },
};
