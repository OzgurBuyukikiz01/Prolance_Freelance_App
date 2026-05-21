export function formatBudget(min: number, max: number, type?: string): string {
  const fmt = (n: number) =>
    new Intl.NumberFormat('en-US', { maximumFractionDigits: 0 }).format(n);
  const suffix = type === 'hourly' ? '/hr' : '';
  if (min === max) return `$${fmt(min)}${suffix}`;
  return `$${fmt(min)} - $${fmt(max)}${suffix}`;
}

export function formatRelativeTime(iso: string): string {
  const date = new Date(iso);
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60_000);
  if (mins < 1) return 'Just now';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return date.toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
}

export function parseSkills(raw: unknown): string[] {
  if (Array.isArray(raw)) return raw.map((value) => String(value));
  return [];
}

export const PROPOSAL_STATUS_LABELS: Record<string, { label: string; className: string }> = {
  pending: { label: 'Pending', className: 'bg-amber-50 text-amber-700 border-amber-200' },
  accepted: { label: 'Accepted', className: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
  rejected: { label: 'Rejected', className: 'bg-red-50 text-red-700 border-red-200' },
};

export const LIFECYCLE_LABELS: Record<string, { label: string; className: string }> = {
  submitted: { label: 'Submitted', className: 'bg-slate-50 text-slate-600 border-slate-200' },
  escrow_funded: { label: 'Escrow funded', className: 'bg-blue-50 text-blue-700 border-blue-200' },
  awaiting_client_review: { label: 'Awaiting review', className: 'bg-amber-50 text-amber-700 border-amber-200' },
  delivered: { label: 'Delivered', className: 'bg-indigo-50 text-indigo-700 border-indigo-200' },
  payout_pending: { label: 'Payout pending', className: 'bg-purple-50 text-purple-700 border-purple-200' },
  closed: { label: 'Completed', className: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
  disputed: { label: 'Disputed', className: 'bg-red-50 text-red-700 border-red-200' },
};

export function formatCents(cents: number | null | undefined): string {
  if (cents == null) return '$0';
  return `$${(cents / 100).toLocaleString('en-US', { maximumFractionDigits: 0 })}`;
}

export function formatDeadlineCountdown(deadline: string | null | undefined): string {
  if (!deadline) return '';
  const diff = new Date(deadline).getTime() - Date.now();
  if (diff <= 0) return 'Expired';
  const hours = Math.floor(diff / 3_600_000);
  const mins = Math.floor((diff % 3_600_000) / 60_000);
  const seconds = Math.floor((diff % 60_000) / 1000);
  if (hours > 0) return `${hours}h ${mins}m ${seconds}s left`;
  if (mins > 0) return `${mins}m ${seconds}s left`;
  return `${seconds}s left`;
}
