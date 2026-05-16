export type EscrowStatusKey = 'FUNDED' | 'HELD' | 'RELEASED' | 'DISPUTED' | 'REFUNDED';

const ESCROW_STATUS_LABELS: Record<
  string,
  { label: string; className: string; canDispute: boolean }
> = {
  FUNDED: {
    label: 'Yatırıldı',
    className: 'bg-blue-50 text-blue-700 border-blue-200',
    canDispute: true,
  },
  HELD: {
    label: 'Escrow’da',
    className: 'bg-amber-50 text-amber-800 border-amber-200',
    canDispute: true,
  },
  RELEASED: {
    label: 'Serbest bırakıldı',
    className: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    canDispute: false,
  },
  DISPUTED: {
    label: 'Anlaşmazlık',
    className: 'bg-red-50 text-red-700 border-red-200',
    canDispute: false,
  },
  REFUNDED: {
    label: 'İade edildi',
    className: 'bg-slate-100 text-slate-600 border-slate-200',
    canDispute: false,
  },
};

export function getEscrowStatusMeta(status: string | null | undefined) {
  const key = (status ?? '').toUpperCase();
  return (
    ESCROW_STATUS_LABELS[key] ?? {
      label: status ?? 'Bilinmiyor',
      className: 'bg-slate-100 text-slate-600 border-slate-200',
      canDispute: false,
    }
  );
}
