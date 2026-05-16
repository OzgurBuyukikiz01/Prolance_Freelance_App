import Link from 'next/link';
import { formatCount, formatEscrowBand } from '@/lib/landing-stats';

type PortalHeroHeaderProps = {
  name: string;
  roleLabel: string;
  roleClassName: string;
  avatarUrl: string | null;
  isAdmin?: boolean;
  platformStats: {
    userCount: number;
    escrowVolumeTry: number;
    satisfactionPct: number;
    completedJobs: number;
  };
};

export function PortalHeroHeader({
  name,
  roleLabel,
  roleClassName,
  avatarUrl,
  isAdmin,
  platformStats,
}: PortalHeroHeaderProps) {
  const initial = name.charAt(0).toUpperCase();
  const strip = [
    { value: formatCount(platformStats.userCount), label: 'Freelancer' },
    { value: formatEscrowBand(platformStats.escrowVolumeTry), label: 'Escrow' },
    { value: `%${platformStats.satisfactionPct}`, label: 'Memnuniyet' },
    { value: formatCount(platformStats.completedJobs), label: 'Tamamlanan' },
  ];

  return (
    <div className="relative -mx-4 -mt-4 mb-8 overflow-hidden rounded-2xl bg-gradient-to-br from-brand via-indigo-600 to-violet-700 px-5 py-6 text-white shadow-brand sm:-mx-0 sm:mt-0">
      <div className="pointer-events-none absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/10 blur-2xl" />
      <div className="relative flex items-start justify-between gap-4">
        <div className="flex min-w-0 items-center gap-4">
          {avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={avatarUrl}
              alt=""
              className="h-14 w-14 shrink-0 rounded-2xl border-2 border-white/30 object-cover"
            />
          ) : (
            <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-white/20 text-2xl font-extrabold backdrop-blur-sm">
              {initial}
            </div>
          )}
          <div className="min-w-0">
            <p className="text-sm text-indigo-100">Merhaba,</p>
            <h1 className="truncate text-xl font-extrabold sm:text-2xl">{name}</h1>
            <div className="mt-1.5 flex flex-wrap items-center gap-2">
              <span className={`rounded-full border px-2.5 py-0.5 text-xs font-semibold ${roleClassName}`}>
                {roleLabel}
              </span>
              {isAdmin && (
                <span className="rounded-full border border-amber-200/50 bg-amber-400/20 px-2.5 py-0.5 text-xs font-bold text-amber-100">
                  Admin
                </span>
              )}
            </div>
          </div>
        </div>
        <div className="flex shrink-0 gap-2">
          <Link
            href="/portal/jobs/new"
            className="rounded-xl bg-white/15 px-3 py-2 text-xs font-semibold backdrop-blur-sm transition-colors hover:bg-white/25"
          >
            + İlan
          </Link>
          <Link
            href="/portal/messages"
            className="rounded-xl bg-white/15 px-3 py-2 text-xs font-semibold backdrop-blur-sm transition-colors hover:bg-white/25"
          >
            Mesajlar
          </Link>
        </div>
      </div>
      <div className="relative mt-6 grid grid-cols-4 gap-2 border-t border-white/20 pt-4">
        {strip.map((s) => (
          <div key={s.label} className="text-center">
            <p className="text-sm font-extrabold tabular-nums sm:text-base">{s.value}</p>
            <p className="text-[10px] text-indigo-100 sm:text-xs">{s.label}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
