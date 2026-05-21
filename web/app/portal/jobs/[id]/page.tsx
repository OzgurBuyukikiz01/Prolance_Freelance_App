import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { acceptProposal, rejectProposal } from '@/app/portal/jobs/[id]/actions';
import { PortalRealtimeRefresh } from '@/components/portal/PortalRealtimeRefresh';
import { ProposalForm } from '@/components/portal/ProposalForm';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import {
  PROPOSAL_STATUS_LABELS,
  formatBudget,
  formatRelativeTime,
  parseSkills,
} from '@/lib/portal/format';

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ error?: string; submitted?: string; accepted?: string }>;
};

export default async function PortalJobDetailPage({ params, searchParams }: PageProps) {
  const { id } = await params;
  const query = await searchParams;

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

  const { data: job } = await supabase.from('jobs').select('*').eq('id', id).single();

  if (!job) notFound();

  const isOwner = job.client_id === user.id;
  const isFreelancer = profile?.role === 'FREELANCER';

  let proposalRows: Array<{
    id: string;
    freelancer_id: string;
    bid: number;
    delivery_days: number;
    cover_letter: string;
    status: string;
    created_at: string;
    freelancerName: string;
    freelancerTitle: string;
  }> = [];

  if (isOwner) {
    const { data: rawProposals } = await supabase
      .from('proposals')
      .select('id, freelancer_id, bid, delivery_days, cover_letter, status, created_at')
      .eq('job_id', id)
      .order('created_at', { ascending: false });

    proposalRows = await Promise.all(
      (rawProposals ?? []).map(async (proposal) => {
        const { data: freelancer } = await supabase
          .from('profiles')
          .select('full_name, title')
          .eq('id', proposal.freelancer_id)
          .maybeSingle();

        return {
          ...proposal,
          freelancerName: freelancer?.full_name ?? 'Freelancer',
          freelancerTitle: freelancer?.title ?? '',
        };
      }),
    );
  }

  const { data: existingProposal } =
    isFreelancer && !isOwner
      ? await supabase
          .from('proposals')
          .select('id, status')
          .eq('job_id', id)
          .eq('freelancer_id', user.id)
          .maybeSingle()
      : { data: null };

  const skills = parseSkills(job.skills);

  return (
    <div className="space-y-6">
      <PortalRealtimeRefresh
        channelKey={`job-detail:${id}`}
        targets={[
          { table: 'jobs', filter: `id=eq.${id}` },
          { table: 'proposals', filter: `job_id=eq.${id}` },
        ]}
      />

      <Link href="/portal/jobs" className="text-sm font-medium text-brand hover:text-brand-dark">
        Back to Jobs
      </Link>

      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.submitted === '1' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Your proposal has been submitted.
        </div>
      )}
      {query.accepted === '1' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Proposal accepted and escrow record created.
        </div>
      )}

      <MagicCard innerClassName="p-6">
        <div className="mb-4 flex flex-wrap items-start justify-between gap-3">
          <div>
            <h1 className="text-2xl font-extrabold text-white">{job.title}</h1>
            <p className="mt-1 text-sm text-slate-500">
              {job.client_name} · {formatRelativeTime(job.posted_date)} · {job.category}
            </p>
          </div>
          <span className="text-lg font-bold text-brand">
            {formatBudget(job.budget_min, job.budget_max, job.budget_type)}
          </span>
        </div>
        <p className="whitespace-pre-wrap text-sm leading-relaxed text-slate-400">{job.description}</p>
        {skills.length > 0 && (
          <div className="mt-4 flex flex-wrap gap-2">
            {skills.map((skill) => (
              <span
                key={skill}
                className="rounded-lg bg-brand-light px-2.5 py-1 text-xs font-medium text-brand"
              >
                {skill}
              </span>
            ))}
          </div>
        )}
        <p className="mt-4 text-xs text-slate-400">{job.proposal_count} proposals · {job.duration}</p>
      </MagicCard>

      {isOwner && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-4 text-lg font-bold text-white">Received Proposals</h2>
          {!proposalRows.length ? (
            <p className="text-sm text-slate-400">No proposals yet.</p>
          ) : (
            <ul className="space-y-4">
              {proposalRows.map((proposal) => {
                const statusMeta =
                  PROPOSAL_STATUS_LABELS[proposal.status] ?? PROPOSAL_STATUS_LABELS.pending;

                return (
                  <li key={proposal.id} className="rounded-2xl border border-white/8 bg-white/4 p-4">
                    <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
                      <div>
                        <p className="font-semibold text-white">{proposal.freelancerName}</p>
                        {proposal.freelancerTitle && (
                          <p className="text-xs text-slate-500">{proposal.freelancerTitle}</p>
                        )}
                      </div>
                      <span
                        className={`rounded-full border px-2.5 py-1 text-xs font-semibold ${statusMeta.className}`}
                      >
                        {statusMeta.label}
                      </span>
                    </div>
                    <p className="mb-2 text-sm font-bold text-brand">
                      ${proposal.bid.toLocaleString('en-US')}
                    </p>
                    <p className="mb-3 whitespace-pre-wrap text-sm text-slate-400">
                      {proposal.cover_letter}
                    </p>
                    <p className="mb-3 text-xs text-slate-500">
                      {proposal.delivery_days} days · {formatRelativeTime(proposal.created_at)}
                    </p>
                    {proposal.status === 'pending' && (
                      <div className="flex gap-2">
                        <form action={acceptProposal}>
                          <input type="hidden" name="proposal_id" value={proposal.id} />
                          <input type="hidden" name="job_id" value={id} />
                          <input
                            type="hidden"
                            name="freelancer_id"
                            value={proposal.freelancer_id}
                          />
                          <input type="hidden" name="bid" value={proposal.bid} />
                          <button
                            type="submit"
                            className="rounded-xl bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-700"
                          >
                            Accept
                          </button>
                        </form>
                        <form action={rejectProposal}>
                          <input type="hidden" name="proposal_id" value={proposal.id} />
                          <input type="hidden" name="job_id" value={id} />
                          <button
                            type="submit"
                            className="rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-red-50 hover:text-red-600"
                          >
                            Decline
                          </button>
                        </form>
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
          )}
        </MagicCard>
      )}

      {isFreelancer && !isOwner && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-4 text-lg font-bold text-white">Submit a Proposal</h2>
          {existingProposal ? (
            <p className="text-sm text-slate-400">
              You&apos;ve already submitted a proposal for this job (
              {PROPOSAL_STATUS_LABELS[existingProposal.status]?.label ?? existingProposal.status}
              ).
            </p>
          ) : job.status === 'open' ? (
            <ProposalForm
              jobId={id}
              defaultBid={Math.round((job.budget_min + job.budget_max) / 2)}
            />
          ) : (
            <p className="text-sm text-slate-400">This job is no longer accepting proposals.</p>
          )}
        </MagicCard>
      )}
    </div>
  );
}
