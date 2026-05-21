import Link from 'next/link';
import { redirect } from 'next/navigation';
import { PortalRealtimeRefresh } from '@/components/portal/PortalRealtimeRefresh';
import { QuickMessageButton } from '@/components/portal/QuickMessageButton';
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
    (proposals ?? []).map(async (proposal) => {
      const { data: job } = await supabase
        .from('jobs')
        .select('id, title, status, client_id')
        .eq('id', proposal.job_id)
        .maybeSingle();
      return { ...proposal, job };
    }),
  );

  return (
    <div className="space-y-6">
      <PortalRealtimeRefresh
        channelKey={`proposals:${user.id}`}
        targets={[{ table: 'proposals', filter: `freelancer_id=eq.${user.id}` }]}
      />
      <div>
        <h1 className="text-2xl font-extrabold text-white">My Proposals</h1>
        <p className="text-sm text-slate-400 mt-1">Status of your submitted proposals</p>
      </div>

      {!enriched.length ? (
        <MagicCard innerClassName="p-8 text-center">
          <p className="text-sm text-slate-400 mb-4">You have not submitted any proposals yet.</p>
          <Link
            href="/portal/jobs"
            className="inline-flex text-sm font-semibold text-brand hover:text-brand-dark"
          >
            Browse jobs →
          </Link>
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {enriched.map((proposal) => {
            const statusMeta =
              PROPOSAL_STATUS_LABELS[proposal.status] ?? PROPOSAL_STATUS_LABELS.pending;
            return (
              <li key={proposal.id}>
                <MagicCard>
                  <div className="p-5">
                    <div className="flex flex-wrap items-start justify-between gap-2 mb-2">
                      <div>
                        <Link
                          href={proposal.job ? `/portal/jobs/${proposal.job.id}` : '#'}
                          className="font-bold text-white hover:text-brand"
                        >
                          {proposal.job?.title ?? 'Job'}
                        </Link>
                        <p className="text-xs text-slate-400 mt-0.5">
                          {formatRelativeTime(proposal.created_at)} · {proposal.delivery_days} days
                        </p>
                      </div>
                      <span
                        className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${statusMeta.className}`}
                      >
                        {statusMeta.label}
                      </span>
                    </div>
                    <p className="text-sm font-bold text-brand mb-2">
                      ${proposal.bid.toLocaleString('en-US')}
                    </p>
                    <p className="text-sm text-slate-400 line-clamp-2">{proposal.cover_letter}</p>
                    {proposal.status === 'accepted' && proposal.job && (
                      <div className="mt-3 flex flex-wrap items-center gap-2">
                        <Link
                          href={`/portal/jobs/${proposal.job.id}`}
                          className="inline-flex items-center text-xs font-semibold text-brand"
                        >
                          View job →
                        </Link>
                        {proposal.job.client_id && (
                          <QuickMessageButton
                            currentUserId={user.id}
                            otherUserId={proposal.job.client_id}
                            label="Message client"
                            className="inline-flex items-center gap-1 rounded-lg border border-brand/30 bg-brand/10 px-2.5 py-1 text-xs font-semibold text-brand hover:bg-brand/15"
                          />
                        )}
                      </div>
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
