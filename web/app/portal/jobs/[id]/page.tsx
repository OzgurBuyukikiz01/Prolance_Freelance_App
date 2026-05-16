import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { EscrowDisputeButton } from '@/components/portal/EscrowDisputeButton';
import { ProposalForm } from '@/components/portal/ProposalForm';
import { MagicCard } from '@/components/ui/magic-card';
import { acceptProposal, rejectProposal } from '@/app/portal/jobs/[id]/actions';
import { createClient } from '@/lib/supabase/server';
import { getEscrowStatusMeta } from '@/lib/portal/escrow';
import {
  PROPOSAL_STATUS_LABELS,
  formatBudget,
  formatRelativeTime,
  parseSkills,
} from '@/lib/portal/format';

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{
    error?: string;
    submitted?: string;
    accepted?: string;
    dispute?: string;
    reviewed?: string;
    posted?: string;
  }>;
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
    .select('role, full_name')
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
      .select('id, job_id, freelancer_id, bid, delivery_days, cover_letter, status, created_at')
      .eq('job_id', id)
      .order('created_at', { ascending: false });

    proposalRows = await Promise.all(
      (rawProposals ?? []).map(async (p) => {
        const { data: freelancer } = await supabase
          .from('profiles')
          .select('full_name, title')
          .eq('id', p.freelancer_id)
          .maybeSingle();
        return {
          ...p,
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

  const { count: acceptedCount } = await supabase
    .from('proposals')
    .select('*', { count: 'exact', head: true })
    .eq('job_id', id)
    .eq('status', 'accepted');

  const showCalendarLink =
    (isOwner && (acceptedCount ?? 0) > 0) || existingProposal?.status === 'accepted';

  const { data: escrowRow } = await supabase
    .from('escrow_transactions')
    .select('id, status, amount_cents, currency, dispute_reason, updated_at')
    .eq('job_id', id)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  const escrowMeta = escrowRow ? getEscrowStatusMeta(escrowRow.status) : null;
  const escrowAmount =
    escrowRow != null
      ? `₺${(Number(escrowRow.amount_cents) / 100).toLocaleString('tr-TR', {
          minimumFractionDigits: 0,
          maximumFractionDigits: 2,
        })}`
      : null;

  const canLeaveReview =
    job.status === 'completed' &&
    (isOwner || existingProposal?.status === 'accepted');

  let existingReviewId: string | null = null;
  if (canLeaveReview) {
    const { data: reviewRow } = await supabase
      .from('reviews')
      .select('id')
      .eq('job_id', id)
      .eq('reviewer_id', user.id)
      .maybeSingle();
    existingReviewId = reviewRow?.id ?? null;
  }

  const skills = parseSkills(job.skills);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <Link href="/portal/jobs" className="text-sm font-medium text-brand hover:text-brand-dark">
          ← İlanlara dön
        </Link>
        {showCalendarLink && (
          <Link
            href="/portal/calendar"
            className="text-sm font-semibold text-brand hover:text-brand-dark"
          >
            Takvime git →
          </Link>
        )}
      </div>

      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.submitted === '1' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Teklifiniz gönderildi.
        </div>
      )}
      {query.accepted === '1' && (
        <SuccessBanner message="Teklif kabul edildi ve escrow kaydı oluşturuldu." />
      )}
      {query.dispute === '1' && (
        <SuccessBanner message="Anlaşmazlık talebiniz alındı." />
      )}
      {query.reviewed === '1' && (
        <SuccessBanner message="Değerlendirmeniz kaydedildi. Teşekkürler!" />
      )}
      {query.posted === '1' && (
        <SuccessBanner message="İlanınız incelemeye gönderildi." />
      )}

      <MagicCard innerClassName="p-6">
        <div className="flex flex-wrap items-start justify-between gap-3 mb-4">
          <div>
            <h1 className="text-2xl font-extrabold text-slate-900">{job.title}</h1>
            <p className="text-sm text-slate-500 mt-1">
              {job.client_name} · {formatRelativeTime(job.posted_date)} · {job.category}
            </p>
          </div>
          <span className="text-lg font-bold text-brand">
            {formatBudget(job.budget_min, job.budget_max, job.budget_type)}
          </span>
        </div>
        <p className="text-slate-600 text-sm leading-relaxed whitespace-pre-wrap">{job.description}</p>
        {skills.length > 0 && (
          <div className="flex flex-wrap gap-2 mt-4">
            {skills.map((skill) => (
              <span
                key={skill}
                className="text-xs font-medium px-2.5 py-1 rounded-lg bg-brand-light text-brand"
              >
                {skill}
              </span>
            ))}
          </div>
        )}
        <p className="text-xs text-slate-400 mt-4">{job.proposal_count} teklif · {job.duration}</p>
      </MagicCard>

      {escrowRow && escrowMeta && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-2">Escrow</h2>
          <EscrowSummary
            amount={escrowAmount ?? ''}
            label={escrowMeta.label}
            className={escrowMeta.className}
          />
          {escrowRow.dispute_reason ? (
            <p className="text-sm text-slate-600 mt-3 whitespace-pre-wrap">
              <span className="font-medium text-slate-700">Anlaşmazlık notu: </span>
              {escrowRow.dispute_reason}
            </p>
          ) : null}
          {escrowMeta.canDispute ? (
            <EscrowDisputeButton escrowId={escrowRow.id} jobId={id} />
          ) : null}
        </MagicCard>
      )}

      {canLeaveReview && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-2">Değerlendirme</h2>
          {existingReviewId ? (
            <p className="text-sm text-slate-600">Bu iş için değerlendirme yaptınız.</p>
          ) : (
            <Link
              href={`/portal/reviews/new?jobId=${id}`}
              className="inline-flex text-sm font-semibold px-4 py-2 rounded-xl bg-brand hover:bg-brand-dark text-white"
            >
              Değerlendirme yaz
            </Link>
          )}
        </MagicCard>
      )}

      {isOwner && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-4">Gelen teklifler</h2>
          {!proposalRows.length ? (
            <p className="text-sm text-slate-500">Henüz teklif yok.</p>
          ) : (
            <ul className="space-y-4">
              {proposalRows.map((p) => {
                const statusMeta = PROPOSAL_STATUS_LABELS[p.status] ?? PROPOSAL_STATUS_LABELS.pending;
                return (
                  <li
                    key={p.id}
                    className="border border-slate-100 rounded-2xl p-4 bg-slate-50/50"
                  >
                    <div className="flex flex-wrap items-start justify-between gap-2 mb-2">
                      <div>
                        <p className="font-semibold text-slate-900">{p.freelancerName}</p>
                        {p.freelancerTitle && (
                          <p className="text-xs text-slate-500">{p.freelancerTitle}</p>
                        )}
                      </div>
                      <span
                        className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${statusMeta.className}`}
                      >
                        {statusMeta.label}
                      </span>
                    </div>
                    <p className="text-sm font-bold text-brand mb-2">₺{p.bid.toLocaleString('tr-TR')}</p>
                    <p className="text-sm text-slate-600 whitespace-pre-wrap mb-3">{p.cover_letter}</p>
                    <p className="text-xs text-slate-400 mb-3">
                      {p.delivery_days} gün · {formatRelativeTime(p.created_at)}
                    </p>
                    {p.status === 'pending' && (
                      <div className="flex gap-2">
                        <form action={acceptProposal}>
                          <input type="hidden" name="proposal_id" value={p.id} />
                          <input type="hidden" name="job_id" value={id} />
                          <input type="hidden" name="freelancer_id" value={p.freelancer_id} />
                          <input type="hidden" name="bid" value={p.bid} />
                          <button
                            type="submit"
                            className="text-sm font-semibold px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white"
                          >
                            Kabul et
                          </button>
                        </form>
                        <form action={rejectProposal}>
                          <input type="hidden" name="proposal_id" value={p.id} />
                          <input type="hidden" name="job_id" value={id} />
                          <button
                            type="submit"
                            className="text-sm font-semibold px-4 py-2 rounded-xl border border-slate-200 hover:bg-red-50 hover:text-red-600 text-slate-600"
                          >
                            Reddet
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
          <h2 className="text-lg font-bold text-slate-900 mb-4">Teklif ver</h2>
          {existingProposal ? (
            <p className="text-sm text-slate-600">
              Bu ilana zaten teklif verdiniz (
              {PROPOSAL_STATUS_LABELS[existingProposal.status]?.label ?? existingProposal.status}
              ).
            </p>
          ) : job.status === 'open' ? (
            <ProposalForm
              jobId={id}
              defaultBid={Math.round((job.budget_min + job.budget_max) / 2)}
            />
          ) : (
            <p className="text-sm text-slate-500">Bu ilan artık teklif kabul etmiyor.</p>
          )}
        </MagicCard>
      )}
    </div>
  );
}

function SuccessBanner({ message }: { message: string }) {
  return (
    <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
      {message}
    </div>
  );
}

function EscrowSummary({
  amount,
  label,
  className,
}: {
  amount: string;
  label: string;
  className: string;
}) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-2">
      <p className="text-sm font-semibold text-slate-900">{amount}</p>
      <span className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${className}`}>
        {label}
      </span>
    </div>
  );
}
