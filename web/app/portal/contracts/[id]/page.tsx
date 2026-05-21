import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import {
  acceptDelivery,
  claimEarnings,
  declineDelivery,
  demoExpireDeadline,
  reportIssue,
  submitDelivery,
  submitReview,
} from './actions';
import { LiveCountdown } from '@/components/portal/LiveCountdown';
import { PortalRealtimeRefresh } from '@/components/portal/PortalRealtimeRefresh';
import { QuickMessageButton } from '@/components/portal/QuickMessageButton';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { LIFECYCLE_LABELS, formatCents, formatRelativeTime } from '@/lib/portal/format';

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ error?: string; success?: string }>;
};

const STAR_VALUES = [1, 2, 3, 4, 5];

export default async function ContractDetailPage({ params, searchParams }: PageProps) {
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
  const role = profile?.role ?? 'FREELANCER';
  const isClient = role === 'CLIENT';

  const { data: proposal } = await supabase
    .from('proposals')
    .select(
      'id, job_id, freelancer_id, bid, delivery_days, funded_amount_cents, freelancer_payout_cents, lifecycle_phase, payout_finalized, delivery_dispute_deadline, dispute_note, admin_resolution_note, created_at',
    )
    .eq('id', id)
    .single();

  if (!proposal) notFound();

  const { data: job } = await supabase
    .from('jobs')
    .select('id, title, client_id, description')
    .eq('id', proposal.job_id)
    .single();

  if (!job) notFound();

  const isOwner = job.client_id === user.id;
  const isFreelancer = proposal.freelancer_id === user.id;
  if (!isOwner && !isFreelancer) redirect('/portal/contracts');

  const { data: deliveries } = await supabase
    .from('proposal_deliveries')
    .select('id, file_name, storage_path, created_at')
    .eq('proposal_id', id)
    .order('created_at', { ascending: false });

  const otherPartyId = isClient ? proposal.freelancer_id : job.client_id;
  const { data: otherParty } = await supabase
    .from('profiles')
    .select('full_name, title, rating, completed_jobs')
    .eq('id', otherPartyId)
    .maybeSingle();

  const { data: existingReview } = isClient
    ? await supabase
        .from('reviews')
        .select('id, rating, comment, created_at')
        .eq('job_id', proposal.job_id)
        .eq('reviewer_id', user.id)
        .maybeSingle()
    : { data: null };

  const phase = proposal.lifecycle_phase as string;
  const phaseMeta = LIFECYCLE_LABELS[phase] ?? LIFECYCLE_LABELS.escrow_funded;
  const fundedCents = proposal.funded_amount_cents ?? Math.round(proposal.bid * 100);
  const deadlinePassed =
    proposal.delivery_dispute_deadline != null &&
    new Date(proposal.delivery_dispute_deadline).getTime() < Date.now();
  const canClaimEarnings =
    !isClient && phase === 'payout_pending' && deadlinePassed && !proposal.payout_finalized;
  const canReportIssue = isClient && phase === 'payout_pending' && !deadlinePassed;
  const showReviewSection =
    isClient && (phase === 'payout_pending' || phase === 'closed') && !existingReview;

  return (
    <div className="space-y-5">
      <PortalRealtimeRefresh
        channelKey={`contract:${id}`}
        targets={[
          { table: 'proposals', filter: `id=eq.${id}` },
          { table: 'proposal_deliveries', filter: `proposal_id=eq.${id}` },
          { table: 'reviews', filter: `job_id=eq.${proposal.job_id}` },
        ]}
      />

      <Link href="/portal/contracts" className="text-sm font-medium text-brand hover:text-brand-dark">
        Back to My Contracts
      </Link>

      {query.error && (
        <div className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-400">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.success === 'delivered' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Delivery submitted. The client will review it.
        </div>
      )}
      {query.success === 'accepted' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Delivery accepted. Payment will be released to the freelancer in 24 hours.
        </div>
      )}
      {query.success === 'declined' && (
        <div className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-3 text-sm text-amber-400">
          Delivery declined. Escrow funds have been refunded.
        </div>
      )}
      {query.success === 'reported' && (
        <div className="rounded-xl border border-orange-500/30 bg-orange-500/10 px-4 py-3 text-sm text-orange-400">
          Issue reported. Escrow funds have been refunded.
        </div>
      )}
      {query.success === 'claimed' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Payment transferred to your balance.
        </div>
      )}
      {query.success === 'deadline_expired' && (
        <div className="rounded-xl border border-purple-500/30 bg-purple-500/10 px-4 py-3 text-sm text-purple-400">
          Demo: 24-hour window expired. The freelancer can now claim payment.
        </div>
      )}
      {query.success === 'reviewed' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Your review has been submitted.
        </div>
      )}

      <MagicCard innerClassName="p-6">
        <div className="mb-4 flex flex-wrap items-start justify-between gap-3">
          <div>
            <h1 className="text-xl font-extrabold text-white">{job.title}</h1>
            <p className="mt-1 text-xs text-slate-400">
              {isClient ? 'Freelancer' : 'Client'}:{' '}
              <span className="font-medium text-slate-300">{otherParty?.full_name ?? '-'}</span>
              {otherParty?.title ? ` · ${otherParty.title}` : ''}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span
              className={`rounded-full border px-3 py-1.5 text-xs font-semibold ${phaseMeta.className}`}
            >
              {phaseMeta.label}
            </span>
            <QuickMessageButton
              currentUserId={user.id}
              otherUserId={otherPartyId}
              label={isClient ? 'Message freelancer' : 'Message client'}
              className="inline-flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2 text-xs font-semibold text-slate-200 transition hover:border-brand/30 hover:bg-brand/10 hover:text-white"
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4 border-t border-white/8 pt-4 sm:grid-cols-3">
          <div>
            <p className="text-xs text-slate-400">Escrow Amount</p>
            <p className="mt-0.5 font-bold text-white">{formatCents(fundedCents)}</p>
          </div>
          {phase === 'payout_pending' && (
            <div>
              <p className="text-xs text-slate-400">
                {isClient ? '24h Dispute Window' : 'Pending Payment'}
              </p>
              {isClient ? (
                <LiveCountdown
                  deadline={proposal.delivery_dispute_deadline}
                  expiredText="Dispute window closed"
                  className="mt-0.5 block font-bold text-white"
                />
              ) : (
                <p className="mt-0.5 font-bold text-white">
                  {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
                </p>
              )}
            </div>
          )}
          <div>
            <p className="text-xs text-slate-400">Delivery Time</p>
            <p className="mt-0.5 font-bold text-white">{proposal.delivery_days} days</p>
          </div>
        </div>
      </MagicCard>

      {!isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-1 text-lg font-bold text-white">Submit Delivery</h2>
          <p className="mb-5 text-sm text-slate-400">
            Add a note and optional link for your completed work.
          </p>
          <form action={submitDelivery} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-300">
                Delivery Note <span className="text-red-400">*</span>
              </label>
              <textarea
                name="note"
                rows={4}
                required
                minLength={5}
                placeholder="Describe the work you delivered"
                className="w-full resize-none rounded-xl border border-white/10 bg-white/5 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-brand focus:outline-none focus:ring-2 focus:ring-brand/30"
              />
            </div>
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-300">Link (optional)</label>
              <input
                type="url"
                name="url"
                placeholder="https://drive.google.com/... or GitHub link"
                className="w-full rounded-xl border border-white/10 bg-white/5 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-brand focus:outline-none focus:ring-2 focus:ring-brand/30"
              />
            </div>
            <button
              type="submit"
              className="w-full rounded-xl bg-brand px-6 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-brand-dark sm:w-auto"
            >
              Submit Delivery
            </button>
          </form>
        </MagicCard>
      )}

      {!isClient && phase === 'awaiting_client_review' && (
        <MagicCard innerClassName="p-6 text-center">
          <h2 className="mb-1 font-bold text-white">Awaiting Review</h2>
          <p className="text-sm text-slate-400">
            Your client is reviewing the delivery. Payment begins once accepted.
          </p>
        </MagicCard>
      )}

      {!isClient && phase === 'payout_pending' && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-1 text-lg font-bold text-white">Payment Approved</h2>
          <p className="mb-4 text-sm text-slate-400">
            Your client accepted the delivery. You can claim payment after the 24-hour dispute window.
          </p>
          <div className="mb-5 flex items-center gap-3 rounded-xl border border-violet-500/20 bg-violet-500/10 p-4">
            <div>
              <p className="text-xs font-medium text-violet-400">Pending Payment</p>
              <p className="text-xl font-extrabold text-violet-300">
                {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
              </p>
            </div>
          </div>
          {canClaimEarnings ? (
            <form action={claimEarnings}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="w-full rounded-xl bg-emerald-600 px-6 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700 sm:w-auto"
              >
                Claim Payment
              </button>
            </form>
          ) : (
            <LiveCountdown
              deadline={proposal.delivery_dispute_deadline}
              prefix="Time remaining: "
              expiredText="Ready to claim"
              className="text-sm font-medium text-slate-300"
            />
          )}
        </MagicCard>
      )}

      {!isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <h2 className="mb-1 font-bold text-white">Project Complete</h2>
          <p className="mb-4 text-sm text-slate-400">
            Payment has been added to your balance.{' '}
            <span className="font-semibold text-emerald-400">
              {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
            </span>
          </p>
          <Link href="/portal/profile" className="text-sm font-semibold text-brand hover:text-brand-dark">
            View Your Profile
          </Link>
        </MagicCard>
      )}

      {isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6 text-center">
          <h2 className="mb-1 font-bold text-white">Awaiting Delivery</h2>
          <p className="text-sm text-slate-400">
            The freelancer is working on your project. You can review it here once submitted.
          </p>
        </MagicCard>
      )}

      {isClient && phase === 'awaiting_client_review' && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-4 text-lg font-bold text-white">Review Delivery</h2>
          <div className="mb-6 space-y-3">
            {deliveries.map((delivery) => (
              <div
                key={delivery.id}
                className="flex items-start gap-3 rounded-xl border border-white/8 bg-white/4 p-4"
              >
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium text-white">{delivery.file_name}</p>
                  {delivery.storage_path && delivery.storage_path !== 'demo://no-file' && (
                    <a
                      href={delivery.storage_path}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="mt-0.5 inline-block max-w-xs truncate text-xs text-brand hover:underline"
                    >
                      {delivery.storage_path}
                    </a>
                  )}
                  <p className="mt-0.5 text-xs text-slate-400">
                    {formatRelativeTime(delivery.created_at)}
                  </p>
                </div>
              </div>
            ))}
          </div>
          <div className="flex flex-wrap gap-3">
            <form action={acceptDelivery}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="rounded-xl bg-emerald-600 px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700"
              >
                Accept Delivery
              </button>
            </form>
            <form action={declineDelivery}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="rounded-xl border border-white/10 px-5 py-2.5 text-sm font-semibold text-slate-300 transition-colors hover:border-red-500/30 hover:bg-red-500/10 hover:text-red-400"
              >
                Request Revision
              </button>
            </form>
          </div>
        </MagicCard>
      )}

      {isClient && phase === 'payout_pending' && (
        <MagicCard innerClassName="p-6">
          <div className="mb-4">
            <h2 className="font-bold text-white">Delivery Accepted</h2>
            {deadlinePassed ? (
              <p className="text-sm text-slate-400">Dispute window closed. Payment released.</p>
            ) : (
              <LiveCountdown
                deadline={proposal.delivery_dispute_deadline}
                prefix="Dispute window: "
                className="mt-1 block text-sm font-medium text-slate-300"
              />
            )}
          </div>

          {canReportIssue && (
            <details className="mt-2">
              <summary className="cursor-pointer select-none text-sm font-semibold text-red-400 hover:text-red-300">
                Report an Issue (Dispute)
              </summary>
              <form action={reportIssue} className="mt-3 space-y-3">
                <input type="hidden" name="proposal_id" value={id} />
                <textarea
                  name="note"
                  rows={3}
                  required
                  minLength={10}
                  placeholder="Describe the issue"
                  className="w-full resize-none rounded-xl border border-red-500/30 bg-red-500/10 px-3 py-2.5 text-sm text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-red-500/20"
                />
                <button
                  type="submit"
                  className="rounded-xl bg-red-600 px-5 py-2 text-sm font-semibold text-white transition-colors hover:bg-red-700"
                >
                  Submit Issue
                </button>
              </form>
            </details>
          )}

          {!deadlinePassed && (
            <div className="mt-4 border-t border-dashed border-white/10 pt-4">
              <p className="mb-2 text-xs font-mono text-slate-500">DEMO MODE</p>
              <form action={demoExpireDeadline}>
                <input type="hidden" name="proposal_id" value={id} />
                <button
                  type="submit"
                  className="rounded-lg border border-purple-500/30 bg-purple-500/10 px-3 py-1.5 text-xs font-medium text-purple-400 transition-colors hover:bg-purple-500/20"
                >
                  Demo: Skip 24 Hours
                </button>
              </form>
            </div>
          )}
        </MagicCard>
      )}

      {isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <h2 className="mb-1 font-bold text-white">Project Complete</h2>
          <p className="text-sm text-slate-400">Great collaboration.</p>
        </MagicCard>
      )}

      {phase === 'disputed' && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-2 font-bold text-white">Dispute Opened</h2>
          <p className="mb-3 text-sm text-slate-400">
            {proposal.dispute_note
              ? `Note: ${proposal.dispute_note}`
              : 'This contract has been disputed and escrow funds have been refunded to the client.'}
          </p>
          {proposal.admin_resolution_note && (
            <div className="mt-3 rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-3">
              <p className="mb-1 text-xs font-semibold text-amber-400">Admin Decision</p>
              <p className="text-sm text-amber-300">{proposal.admin_resolution_note}</p>
            </div>
          )}
        </MagicCard>
      )}

      {showReviewSection && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-1 text-lg font-bold text-white">Review the Freelancer</h2>
          <p className="mb-5 text-sm text-slate-400">
            Share your experience working with{' '}
            <span className="font-medium text-slate-200">{otherParty?.full_name}</span>.
          </p>
          <form action={submitReview} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <input type="hidden" name="job_id" value={proposal.job_id} />
            <input type="hidden" name="reviewee_id" value={proposal.freelancer_id} />
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-300">
                Rating <span className="text-red-400">*</span>
              </label>
              <div className="flex gap-2">
                {STAR_VALUES.map((value) => (
                  <label key={value} className="cursor-pointer">
                    <input type="radio" name="rating" value={value} required className="sr-only peer" />
                    <span className="select-none text-2xl text-slate-600 transition-colors hover:text-amber-300 peer-checked:text-amber-400">
                      ★
                    </span>
                  </label>
                ))}
              </div>
            </div>
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-300">Comment (optional)</label>
              <textarea
                name="comment"
                rows={3}
                placeholder="Describe your experience"
                className="w-full resize-none rounded-xl border border-white/10 bg-white/5 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-brand focus:outline-none focus:ring-2 focus:ring-brand/30"
              />
            </div>
            <button
              type="submit"
              className="rounded-xl bg-brand px-6 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-brand-dark"
            >
              Submit Review
            </button>
          </form>
        </MagicCard>
      )}

      {isClient && existingReview && (
        <MagicCard innerClassName="p-5">
          <h3 className="mb-2 text-sm font-bold text-slate-300">Your Submitted Review</h3>
          <div className="mb-1 flex items-center gap-1">
            {STAR_VALUES.map((value) => (
              <span
                key={value}
                className={value <= existingReview.rating ? 'text-amber-400' : 'text-slate-600'}
              >
                ★
              </span>
            ))}
            <span className="ml-2 text-xs text-slate-400">
              {formatRelativeTime(existingReview.created_at)}
            </span>
          </div>
          {existingReview.comment && (
            <p className="mt-1 text-sm text-slate-400">{existingReview.comment}</p>
          )}
        </MagicCard>
      )}

      {!isClient && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="mb-3 text-base font-bold text-white">Submitted Deliveries</h2>
          <div className="space-y-2">
            {deliveries.map((delivery) => (
              <div
                key={delivery.id}
                className="flex items-start gap-3 rounded-xl border border-white/8 bg-white/4 p-3"
              >
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-white">{delivery.file_name}</p>
                  {delivery.storage_path && delivery.storage_path !== 'demo://no-file' && (
                    <a
                      href={delivery.storage_path}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-block max-w-xs truncate text-xs text-brand hover:underline"
                    >
                      {delivery.storage_path}
                    </a>
                  )}
                  <p className="mt-0.5 text-xs text-slate-400">
                    {formatRelativeTime(delivery.created_at)}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </MagicCard>
      )}
    </div>
  );
}
