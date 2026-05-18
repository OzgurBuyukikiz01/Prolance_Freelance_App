import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import {
  LIFECYCLE_LABELS,
  formatCents,
  formatDeadlineCountdown,
  formatRelativeTime,
} from '@/lib/portal/format';
import {
  submitDelivery,
  acceptDelivery,
  declineDelivery,
  reportIssue,
  claimEarnings,
  demoExpireDeadline,
  submitReview,
} from './actions';

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
      <Link
        href="/portal/contracts"
        className="text-sm font-medium text-brand hover:text-brand-dark"
      >
        ← Back to My Contracts
      </Link>

      {/* Alerts */}
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
          Payment transferred to your balance!
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

      {/* Contract Header */}
      <MagicCard innerClassName="p-6">
        <div className="flex flex-wrap items-start justify-between gap-3 mb-4">
          <div>
            <h1 className="text-xl font-extrabold text-white">{job.title}</h1>
            <p className="text-xs text-slate-400 mt-1">
              {isClient ? 'Freelancer' : 'Client'}:{' '}
              <span className="font-medium text-slate-300">{otherParty?.full_name ?? '—'}</span>
              {otherParty?.title ? ` · ${otherParty.title}` : ''}
            </p>
          </div>
          <span
            className={`text-xs font-semibold px-3 py-1.5 rounded-full border ${phaseMeta.className}`}
          >
            {phaseMeta.label}
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-white/8">
          <div>
            <p className="text-xs text-slate-400">Escrow Amount</p>
            <p className="font-bold text-white mt-0.5">{formatCents(fundedCents)}</p>
          </div>
          {phase === 'payout_pending' && (
            <div>
              <p className="text-xs text-slate-400">
                {isClient ? '24h Dispute Window' : 'Pending Payment'}
              </p>
              <p className="font-bold text-white mt-0.5">
                {isClient
                  ? formatDeadlineCountdown(proposal.delivery_dispute_deadline)
                  : formatCents(proposal.freelancer_payout_cents)}
              </p>
            </div>
          )}
          <div>
            <p className="text-xs text-slate-400">Delivery Time</p>
            <p className="font-bold text-white mt-0.5">{proposal.bid} days</p>
          </div>
        </div>
      </MagicCard>

      {/* === FREELANCER VIEWS === */}

      {/* Freelancer: submit delivery */}
      {!isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-white mb-1">Submit Delivery</h2>
          <p className="text-sm text-slate-400 mb-5">
            Add a note and optional link for your completed work.
          </p>
          <form action={submitDelivery} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1.5">
                Delivery Note <span className="text-red-400">*</span>
              </label>
              <textarea
                name="note"
                rows={4}
                required
                minLength={5}
                placeholder="Describe the work you've delivered..."
                className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-3 py-2.5 text-sm placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1.5">
                Link (optional)
              </label>
              <input
                type="url"
                name="url"
                placeholder="https://drive.google.com/... or GitHub link"
                className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-3 py-2.5 text-sm placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
              />
            </div>
            <button
              type="submit"
              className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-brand hover:bg-brand-dark text-white text-sm font-semibold transition-colors"
            >
              Submit Delivery
            </button>
          </form>
        </MagicCard>
      )}

      {/* Freelancer: waiting for client review */}
      {!isClient && phase === 'awaiting_client_review' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-amber-500/10 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">⏳</span>
          </div>
          <h2 className="font-bold text-white mb-1">Awaiting Review</h2>
          <p className="text-sm text-slate-400">Your client is reviewing the delivery. Payment will begin once accepted.</p>
        </MagicCard>
      )}

      {/* Freelancer: payout pending */}
      {!isClient && phase === 'payout_pending' && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-white mb-1">Payment Approved</h2>
          <p className="text-sm text-slate-400 mb-4">
            Your client accepted the delivery. You can claim payment after the 24-hour dispute window.
          </p>
          <div className="flex items-center gap-3 p-4 rounded-xl bg-violet-500/10 border border-violet-500/20 mb-5">
            <span className="text-2xl">💰</span>
            <div>
              <p className="text-xs text-violet-400 font-medium">Pending Payment</p>
              <p className="text-xl font-extrabold text-violet-300">
                {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
              </p>
            </div>
          </div>
          {deadlinePassed ? (
            <form action={claimEarnings}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold transition-colors"
              >
                Claim Payment
              </button>
            </form>
          ) : (
            <p className="text-sm text-slate-400">
              Time remaining: {formatDeadlineCountdown(proposal.delivery_dispute_deadline)}
            </p>
          )}
        </MagicCard>
      )}

      {/* Freelancer: closed */}
      {!isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🎉</span>
          </div>
          <h2 className="font-bold text-white mb-1">Project Complete</h2>
          <p className="text-sm text-slate-400 mb-4">
            Payment has been added to your balance.{' '}
            <span className="font-semibold text-emerald-400">
              {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
            </span>
          </p>
          <Link
            href="/portal/profile"
            className="text-sm font-semibold text-brand hover:text-brand-dark"
          >
            View Your Profile →
          </Link>
        </MagicCard>
      )}

      {/* === CLIENT VIEWS === */}

      {/* Client: waiting for delivery */}
      {isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-blue-500/10 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🔄</span>
          </div>
          <h2 className="font-bold text-white mb-1">Awaiting Delivery</h2>
          <p className="text-sm text-slate-400">The freelancer is working on your project. You can review it here once submitted.</p>
        </MagicCard>
      )}

      {/* Client: delivery ready for review */}
      {isClient && phase === 'awaiting_client_review' && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-white mb-4">Review Delivery</h2>
          <div className="space-y-3 mb-6">
            {deliveries.map((d) => (
              <div
                key={d.id}
                className="flex items-start gap-3 p-4 rounded-xl border border-white/8 bg-white/4"
              >
                <span className="text-xl mt-0.5">📦</span>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-white text-sm">{d.file_name}</p>
                  {d.storage_path && d.storage_path !== 'demo://no-file' && (
                    <a
                      href={d.storage_path}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-xs text-brand hover:underline mt-0.5 inline-block truncate max-w-xs"
                    >
                      {d.storage_path}
                    </a>
                  )}
                  <p className="text-xs text-slate-400 mt-0.5">
                    {formatRelativeTime(d.created_at)}
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
                className="px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold transition-colors"
              >
                ✓ Accept Delivery
              </button>
            </form>
            <form action={declineDelivery}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="px-5 py-2.5 rounded-xl border border-white/10 hover:border-red-500/30 hover:bg-red-500/10 hover:text-red-400 text-slate-300 text-sm font-semibold transition-colors"
              >
                Request Revision
              </button>
            </form>
          </div>
        </MagicCard>
      )}

      {/* Client: payout pending — 24h window + optional report issue */}
      {isClient && phase === 'payout_pending' && (
        <MagicCard innerClassName="p-6">
          <div className="flex items-center gap-3 mb-4">
            <span className="text-2xl">✅</span>
            <div>
              <h2 className="font-bold text-white">Delivery Accepted</h2>
              <p className="text-sm text-slate-400">
                {deadlinePassed
                  ? 'Dispute window closed. Payment released.'
                  : `Dispute window: ${formatDeadlineCountdown(proposal.delivery_dispute_deadline)}`}
              </p>
            </div>
          </div>

          {canReportIssue && (
            <details className="mt-2">
              <summary className="text-sm font-semibold text-red-400 cursor-pointer hover:text-red-300 select-none">
                ⚠ Report an Issue (Dispute)
              </summary>
              <form action={reportIssue} className="mt-3 space-y-3">
                <input type="hidden" name="proposal_id" value={id} />
                <textarea
                  name="note"
                  rows={3}
                  required
                  minLength={10}
                  placeholder="Describe the issue..."
                  className="w-full rounded-xl border border-red-500/30 bg-red-500/10 text-white px-3 py-2.5 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-red-500/20 resize-none"
                />
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-red-600 hover:bg-red-700 text-white text-sm font-semibold transition-colors"
                >
                  Submit Issue
                </button>
              </form>
            </details>
          )}

          {/* Demo acceleration — clearly marked */}
          {!deadlinePassed && (
            <div className="mt-4 pt-4 border-t border-dashed border-white/10">
              <p className="text-xs text-slate-500 mb-2 font-mono">DEMO MODE</p>
              <form action={demoExpireDeadline}>
                <input type="hidden" name="proposal_id" value={id} />
                <button
                  type="submit"
                  className="text-xs px-3 py-1.5 rounded-lg border border-purple-500/30 bg-purple-500/10 text-purple-400 hover:bg-purple-500/20 font-medium transition-colors"
                >
                  ⚡ Demo: Skip 24 Hours (for presentation)
                </button>
              </form>
            </div>
          )}
        </MagicCard>
      )}

      {/* Client: project closed */}
      {isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🏁</span>
          </div>
          <h2 className="font-bold text-white mb-1">Project Complete</h2>
          <p className="text-sm text-slate-400">Great collaboration!</p>
        </MagicCard>
      )}

      {/* Disputed state */}
      {phase === 'disputed' && (
        <MagicCard innerClassName="p-6">
          <div className="flex items-center gap-3 mb-2">
            <span className="text-2xl">⚠️</span>
            <h2 className="font-bold text-white">Dispute Opened</h2>
          </div>
          <p className="text-sm text-slate-400 mb-3">
            This contract has been disputed.{' '}
            {proposal.dispute_note ? (
              <span>Note: {proposal.dispute_note}</span>
            ) : (
              'Escrow funds have been refunded to the client.'
            )}
          </p>
          {proposal.admin_resolution_note && (
            <div className="mt-3 rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-3">
              <p className="text-xs font-semibold text-amber-400 mb-1">⚖️ Admin Decision</p>
              <p className="text-sm text-amber-300">{proposal.admin_resolution_note}</p>
            </div>
          )}
        </MagicCard>
      )}

      {/* === REVIEW SECTION (CLIENT only, after payout_pending or closed) === */}
      {showReviewSection && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-white mb-1">Review the Freelancer</h2>
          <p className="text-sm text-slate-400 mb-5">
            Share your experience working with <span className="font-medium text-slate-200">{otherParty?.full_name}</span>.
          </p>
          <form action={submitReview} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <input type="hidden" name="job_id" value={proposal.job_id} />
            <input type="hidden" name="reviewee_id" value={proposal.freelancer_id} />
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Rating <span className="text-red-400">*</span>
              </label>
              <div className="flex gap-2">
                {STAR_VALUES.map((v) => (
                  <label key={v} className="cursor-pointer">
                    <input type="radio" name="rating" value={v} required className="sr-only peer" />
                    <span className="text-2xl text-slate-600 peer-checked:text-amber-400 hover:text-amber-300 transition-colors select-none">
                      ★
                    </span>
                  </label>
                ))}
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1.5">
                Comment (optional)
              </label>
              <textarea
                name="comment"
                rows={3}
                placeholder="Describe your experience..."
                className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-3 py-2.5 text-sm placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand resize-none"
              />
            </div>
            <button
              type="submit"
              className="px-6 py-2.5 rounded-xl bg-brand hover:bg-brand-dark text-white text-sm font-semibold transition-colors"
            >
              Submit Review
            </button>
          </form>
        </MagicCard>
      )}

      {/* Existing review display */}
      {isClient && existingReview && (
        <MagicCard innerClassName="p-5">
          <h3 className="text-sm font-bold text-slate-300 mb-2">Your Submitted Review</h3>
          <div className="flex items-center gap-1 mb-1">
            {STAR_VALUES.map((v) => (
              <span key={v} className={v <= existingReview.rating ? 'text-amber-400' : 'text-slate-600'}>★</span>
            ))}
            <span className="text-xs text-slate-400 ml-2">{formatRelativeTime(existingReview.created_at)}</span>
          </div>
          {existingReview.comment && (
            <p className="text-sm text-slate-400 mt-1">{existingReview.comment}</p>
          )}
        </MagicCard>
      )}

      {/* Delivery history */}
      {!isClient && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-base font-bold text-white mb-3">Submitted Deliveries</h2>
          <div className="space-y-2">
            {deliveries.map((d) => (
              <div key={d.id} className="flex items-start gap-3 p-3 rounded-xl border border-white/8 bg-white/4">
                <span className="text-lg mt-0.5">📄</span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-white truncate">{d.file_name}</p>
                  {d.storage_path && d.storage_path !== 'demo://no-file' && (
                    <a
                      href={d.storage_path}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-xs text-brand hover:underline truncate max-w-xs inline-block"
                    >
                      {d.storage_path}
                    </a>
                  )}
                  <p className="text-xs text-slate-400 mt-0.5">{formatRelativeTime(d.created_at)}</p>
                </div>
              </div>
            ))}
          </div>
        </MagicCard>
      )}
    </div>
  );
}
