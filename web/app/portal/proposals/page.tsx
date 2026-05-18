import Link from 'next/link';
import { redirect } from 'next/navigation';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { PROPOSAL_STATUS_LABELS, formatRelativeTime } from '@/lib/portal/format';

export default async function PortalProposalsPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: proposals, error } = await supabase
    .from('proposals')
    .select('id, job_id, bid, delivery_days, cover_letter, status, created_at')
    .eq('freelancer_id', user.id)
    .order('created_at', { ascending: false });

  if (error) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-400">
        Failed to load proposals: {error.message}
      </MagicCard>
    );
  }

  const enriched = await Promise.all(
    (proposals ?? []).map(async (p) => {
      const { data: job } = await supabase
        .from('jobs')
        .select('id, title, status')
        .eq('id', p.job_id)
        .maybeSingle();
      return { ...p, job };
    }),
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">My Proposals</h1>
        <p className="text-sm text-slate-400 mt-1">Status of your submitted proposals</p>
      </div>

      {!enriched.length ? (
        <MagicCard innerClassName="p-8 text-center">
          <p className="text-sm text-slate-400 mb-4">You haven&apos;t submitted any proposals yet.</p>
          <Link
            href="/portal/jobs"
            className="inline-flex text-sm font-semibold text-brand hover:text-brand-dark"
          >
            Browse jobs →
          </Link>
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {enriched.map((p) => {
            const statusMeta = PROPOSAL_STATUS_LABELS[p.status] ?? PROPOSAL_STATUS_LABELS.pending;
            return (
              <li key={p.id}>
                <MagicCard>
                  <div className="p-5">
                    <div className="flex flex-wrap items-start justify-between gap-2 mb-2">
                      <div>
                        <Link
                          href={p.job ? `/portal/jobs/${p.job.id}` : '#'}
                          className="font-bold text-white hover:text-brand"
                        >
                          {p.job?.title ?? 'Job'}
                        </Link>
                        <p className="text-xs text-slate-400 mt-0.5">
                          {formatRelativeTime(p.created_at)} · {p.delivery_days} days
                        </p>
                      </div>
                      <span
                        className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${statusMeta.className}`}
                      >
                        {statusMeta.label}
                      </span>
                    </div>
                    <p className="text-sm font-bold text-brand mb-2">
                      ₺{p.bid.toLocaleString('tr-TR')}
                    </p>
                    <p className="text-sm text-slate-400 line-clamp-2">{p.cover_letter}</p>
                    {p.status === 'accepted' && p.job && (
                      <Link
                        href={`/portal/jobs/${p.job.id}`}
                        className="inline-block mt-3 text-xs font-semibold text-brand"
                      >
                        View Job →
                      </Link>
                    )}
                  </div>
                </MagicCard>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
