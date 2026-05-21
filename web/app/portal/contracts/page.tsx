import Link from 'next/link';
import { redirect } from 'next/navigation';
import { LiveCountdown } from '@/components/portal/LiveCountdown';
import { PortalRealtimeRefresh } from '@/components/portal/PortalRealtimeRefresh';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { LIFECYCLE_LABELS, formatCents, formatRelativeTime } from '@/lib/portal/format';

type ContractListItem = {
  id: string;
  job_id: string;
  bid: number;
  funded_amount_cents: number | null;
  lifecycle_phase: string;
  created_at: string;
  jobTitle: string;
  otherPartyName: string;
  delivery_dispute_deadline: string | null;
  payout_finalized: boolean;
};

export default async function ContractsPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  const role = profile?.role ?? 'FREELANCER';
  const isClient = role === 'CLIENT';

  let contracts: ContractListItem[] = [];

  if (isClient) {
    const { data: jobs } = await supabase.from('jobs').select('id').eq('client_id', user.id);
    const jobIds = (jobs ?? []).map((job) => job.id);

    if (jobIds.length > 0) {
      const { data: proposals } = await supabase
        .from('proposals')
        .select(
          'id, job_id, bid, funded_amount_cents, lifecycle_phase, created_at, freelancer_id, delivery_dispute_deadline, payout_finalized',
        )
        .in('job_id', jobIds)
        .eq('status', 'accepted')
        .order('created_at', { ascending: false });

      contracts = await Promise.all(
        (proposals ?? []).map(async (proposal) => {
          const [{ data: job }, { data: freelancer }] = await Promise.all([
            supabase.from('jobs').select('title').eq('id', proposal.job_id).maybeSingle(),
            supabase
              .from('profiles')
              .select('full_name')
              .eq('id', proposal.freelancer_id)
              .maybeSingle(),
          ]);

          return {
            ...proposal,
            jobTitle: job?.title ?? 'Job',
            otherPartyName: freelancer?.full_name ?? 'Freelancer',
          };
        }),
      );
    }
  } else {
    const { data: proposals } = await supabase
      .from('proposals')
      .select(
        'id, job_id, bid, funded_amount_cents, lifecycle_phase, created_at, delivery_dispute_deadline, payout_finalized, job:jobs(title, client_id)',
      )
      .eq('freelancer_id', user.id)
      .eq('status', 'accepted')
      .order('created_at', { ascending: false });

    contracts = await Promise.all(
      (proposals ?? []).map(async (proposal) => {
        const jobData = Array.isArray(proposal.job) ? proposal.job[0] : proposal.job;
        const clientId = jobData?.client_id;
        const { data: client } = clientId
          ? await supabase.from('profiles').select('full_name').eq('id', clientId).maybeSingle()
          : { data: null };

        return {
          id: proposal.id,
          job_id: proposal.job_id,
          bid: proposal.bid,
          funded_amount_cents: proposal.funded_amount_cents,
          lifecycle_phase: proposal.lifecycle_phase,
          created_at: proposal.created_at,
          jobTitle: jobData?.title ?? 'Job',
          otherPartyName: client?.full_name ?? 'Client',
          delivery_dispute_deadline: proposal.delivery_dispute_deadline,
          payout_finalized: proposal.payout_finalized ?? false,
        };
      }),
    );
  }

  return (
    <div className="space-y-6">
      <PortalRealtimeRefresh
        channelKey={`contracts:${user.id}`}
        targets={[
          ...(isClient
            ? [
                { table: 'jobs', filter: `client_id=eq.${user.id}` },
                { table: 'proposals' },
              ]
            : [{ table: 'proposals', filter: `freelancer_id=eq.${user.id}` }]),
          { table: 'proposal_deliveries' },
        ]}
      />

      <div>
        <h1 className="text-2xl font-extrabold text-white">My Contracts</h1>
        <p className="mt-1 text-sm text-slate-400">
          {isClient
            ? 'Accepted proposals and active projects'
            : 'Your accepted proposals and delivery progress'}
        </p>
      </div>

      {!contracts.length ? (
        <MagicCard innerClassName="p-10 text-center">
          <p className="mb-3 text-sm text-slate-400">No accepted proposals yet.</p>
          <Link href="/portal/jobs" className="text-sm font-semibold text-brand hover:text-brand-dark">
            Browse jobs
          </Link>
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {contracts.map((contract) => {
            const phase =
              LIFECYCLE_LABELS[contract.lifecycle_phase] ?? LIFECYCLE_LABELS.escrow_funded;

            return (
              <li key={contract.id}>
                <Link href={`/portal/contracts/${contract.id}`} className="group block">
                  <MagicCard>
                    <div className="p-5">
                      <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
                        <div className="min-w-0">
                          <p className="truncate font-bold text-white transition-colors group-hover:text-brand">
                            {contract.jobTitle}
                          </p>
                          <p className="mt-0.5 text-xs text-slate-400">
                            {isClient ? 'Freelancer' : 'Client'}: {contract.otherPartyName} ·{' '}
                            {formatRelativeTime(contract.created_at)}
                          </p>
                        </div>
                        <span
                          className={`shrink-0 rounded-full border px-2.5 py-1 text-xs font-semibold ${phase.className}`}
                        >
                          {phase.label}
                        </span>
                      </div>

                      <div className="mt-3 flex items-center justify-between">
                        <div>
                          <p className="text-sm font-bold text-brand">
                            {formatCents(
                              contract.funded_amount_cents ?? Math.round(contract.bid * 100),
                            )}
                          </p>
                          {contract.lifecycle_phase === 'payout_pending' &&
                            !contract.payout_finalized &&
                            contract.delivery_dispute_deadline && (
                              <LiveCountdown
                                deadline={contract.delivery_dispute_deadline}
                                prefix={isClient ? 'Dispute window: ' : 'Release in: '}
                                expiredText={isClient ? 'Dispute window closed' : 'Ready to claim'}
                                className="mt-1 block text-xs font-medium text-slate-400"
                              />
                            )}
                        </div>
                        <span className="text-xs text-slate-400 transition-colors group-hover:text-brand">
                          Details
                        </span>
                      </div>
                    </div>
                  </MagicCard>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
