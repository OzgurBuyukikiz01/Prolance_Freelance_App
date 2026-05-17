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
      'id, job_id, freelancer_id, bid, delivery_days, funded_amount_cents, freelancer_payout_cents, lifecycle_phase, payout_finalized, delivery_dispute_deadline, dispute_note, created_at',
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

  // Verify the current user is a participant
  const isOwner = job.client_id === user.id;
  const isFreelancer = proposal.freelancer_id === user.id;
  if (!isOwner && !isFreelancer) redirect('/portal/contracts');

  // Fetch deliveries
  const { data: deliveries } = await supabase
    .from('proposal_deliveries')
    .select('id, file_name, storage_path, created_at')
    .eq('proposal_id', id)
    .order('created_at', { ascending: false });

  // Fetch other party info
  const otherPartyId = isClient ? proposal.freelancer_id : job.client_id;
  const { data: otherParty } = await supabase
    .from('profiles')
    .select('full_name, title, rating, completed_jobs')
    .eq('id', otherPartyId)
    .maybeSingle();

  // Check if client already submitted a review
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
        ← Sözleşmelerime Dön
      </Link>

      {/* Alerts */}
      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.success === 'delivered' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Teslimatınız gönderildi. İşveren inceleyecek.
        </div>
      )}
      {query.success === 'accepted' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Teslimat kabul edildi. Ödeme 24 saat sonra freelancer&apos;a aktarılacak.
        </div>
      )}
      {query.success === 'declined' && (
        <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-700">
          Teslimat reddedildi. Escrow tutarı iade edildi.
        </div>
      )}
      {query.success === 'reported' && (
        <div className="rounded-xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm text-orange-700">
          Sorun bildiriminiz alındı. Escrow tutarı iade edildi.
        </div>
      )}
      {query.success === 'claimed' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Ödeme bakiyenize aktarıldı!
        </div>
      )}
      {query.success === 'deadline_expired' && (
        <div className="rounded-xl border border-purple-200 bg-purple-50 px-4 py-3 text-sm text-purple-700">
          Demo: 24 saatlik süre geçirildi. Freelancer ödemeyi talep edebilir.
        </div>
      )}
      {query.success === 'reviewed' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Değerlendirmeniz gönderildi.
        </div>
      )}

      {/* Contract Header */}
      <MagicCard innerClassName="p-6">
        <div className="flex flex-wrap items-start justify-between gap-3 mb-4">
          <div>
            <h1 className="text-xl font-extrabold text-slate-900">{job.title}</h1>
            <p className="text-xs text-slate-400 mt-1">
              {isClient ? 'Freelancer' : 'İşveren'}:{' '}
              <span className="font-medium text-slate-600">{otherParty?.full_name ?? '—'}</span>
              {otherParty?.title ? ` · ${otherParty.title}` : ''}
            </p>
          </div>
          <span
            className={`text-xs font-semibold px-3 py-1.5 rounded-full border ${phaseMeta.className}`}
          >
            {phaseMeta.label}
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-slate-100">
          <div>
            <p className="text-xs text-slate-400">Escrow Tutarı</p>
            <p className="font-bold text-slate-900 mt-0.5">{formatCents(fundedCents)}</p>
          </div>
          {phase === 'payout_pending' && (
            <div>
              <p className="text-xs text-slate-400">
                {isClient ? '24s İtiraz Süresi' : 'Bekleyen Ödeme'}
              </p>
              <p className="font-bold text-slate-900 mt-0.5">
                {isClient
                  ? formatDeadlineCountdown(proposal.delivery_dispute_deadline)
                  : formatCents(proposal.freelancer_payout_cents)}
              </p>
            </div>
          )}
          <div>
            <p className="text-xs text-slate-400">Teslim Süresi</p>
            <p className="font-bold text-slate-900 mt-0.5">{proposal.bid} gün</p>
          </div>
        </div>
      </MagicCard>

      {/* === FREELANCER VIEWS === */}

      {/* Freelancer: submit delivery */}
      {!isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-1">Teslimat Gönder</h2>
          <p className="text-sm text-slate-500 mb-5">
            Tamamladığınız çalışmanın notunu ve varsa bağlantısını girin.
          </p>
          <form action={submitDelivery} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1.5">
                Teslimat Notu <span className="text-red-500">*</span>
              </label>
              <textarea
                name="note"
                rows={4}
                required
                minLength={5}
                placeholder="Teslim ettiğiniz çalışmayı açıklayın..."
                className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand resize-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1.5">
                Bağlantı / Link (isteğe bağlı)
              </label>
              <input
                type="url"
                name="url"
                placeholder="https://drive.google.com/... veya GitHub linki"
                className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
              />
            </div>
            <button
              type="submit"
              className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-brand hover:bg-brand-dark text-white text-sm font-semibold transition-colors"
            >
              Teslimatı Gönder
            </button>
          </form>
        </MagicCard>
      )}

      {/* Freelancer: waiting for client review */}
      {!isClient && phase === 'awaiting_client_review' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-amber-50 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">⏳</span>
          </div>
          <h2 className="font-bold text-slate-900 mb-1">İnceleme Bekleniyor</h2>
          <p className="text-sm text-slate-500">İşvereniniz teslimatınızı inceliyor. Kabul ettiğinde ödeme süreci başlayacak.</p>
        </MagicCard>
      )}

      {/* Freelancer: payout pending */}
      {!isClient && phase === 'payout_pending' && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-1">Ödeme Onaylandı</h2>
          <p className="text-sm text-slate-500 mb-4">
            İşvereniniz teslimatı kabul etti. 24 saatlik itiraz süresi dolduktan sonra ödemeyi talep edebilirsiniz.
          </p>
          <div className="flex items-center gap-3 p-4 rounded-xl bg-purple-50 border border-purple-100 mb-5">
            <span className="text-2xl">💰</span>
            <div>
              <p className="text-xs text-purple-600 font-medium">Bekleyen Ödeme</p>
              <p className="text-xl font-extrabold text-purple-800">
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
                Ödemeyi Al
              </button>
            </form>
          ) : (
            <p className="text-sm text-slate-500">
              Süre: {formatDeadlineCountdown(proposal.delivery_dispute_deadline)}
            </p>
          )}
        </MagicCard>
      )}

      {/* Freelancer: closed */}
      {!isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-emerald-50 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🎉</span>
          </div>
          <h2 className="font-bold text-slate-900 mb-1">Proje Tamamlandı</h2>
          <p className="text-sm text-slate-500 mb-4">
            Ödeme bakiyenize aktarıldı.{' '}
            <span className="font-semibold text-emerald-700">
              {formatCents(proposal.freelancer_payout_cents ?? fundedCents)}
            </span>
          </p>
          <Link
            href="/portal/profile"
            className="text-sm font-semibold text-brand hover:text-brand-dark"
          >
            Profilinizi Görüntüleyin →
          </Link>
        </MagicCard>
      )}

      {/* === CLIENT VIEWS === */}

      {/* Client: waiting for delivery */}
      {isClient && phase === 'escrow_funded' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🔄</span>
          </div>
          <h2 className="font-bold text-slate-900 mb-1">Teslimat Bekleniyor</h2>
          <p className="text-sm text-slate-500">Freelancer çalışmasını hazırlıyor. Teslim ettiğinde buradan inceleyebilirsiniz.</p>
        </MagicCard>
      )}

      {/* Client: delivery ready for review */}
      {isClient && phase === 'awaiting_client_review' && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-4">Teslimat İnceleme</h2>
          <div className="space-y-3 mb-6">
            {deliveries.map((d) => (
              <div
                key={d.id}
                className="flex items-start gap-3 p-4 rounded-xl border border-slate-100 bg-slate-50"
              >
                <span className="text-xl mt-0.5">📦</span>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-900 text-sm">{d.file_name}</p>
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
                ✓ Teslimatı Kabul Et
              </button>
            </form>
            <form action={declineDelivery}>
              <input type="hidden" name="proposal_id" value={id} />
              <button
                type="submit"
                className="px-5 py-2.5 rounded-xl border border-slate-200 hover:border-red-200 hover:bg-red-50 hover:text-red-600 text-slate-600 text-sm font-semibold transition-colors"
              >
                Revizyon İste
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
              <h2 className="font-bold text-slate-900">Teslimat Kabul Edildi</h2>
              <p className="text-sm text-slate-500">
                {deadlinePassed
                  ? 'İtiraz süresi doldu. Ödeme serbest bırakıldı.'
                  : `İtiraz süresi: ${formatDeadlineCountdown(proposal.delivery_dispute_deadline)}`}
              </p>
            </div>
          </div>

          {canReportIssue && (
            <details className="mt-2">
              <summary className="text-sm font-semibold text-red-600 cursor-pointer hover:text-red-700 select-none">
                ⚠ Sorun Bildir (İtiraz)
              </summary>
              <form action={reportIssue} className="mt-3 space-y-3">
                <input type="hidden" name="proposal_id" value={id} />
                <textarea
                  name="note"
                  rows={3}
                  required
                  minLength={10}
                  placeholder="Sorunu açıklayın..."
                  className="w-full rounded-xl border border-red-200 bg-red-50/30 px-3 py-2.5 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-red-200 resize-none"
                />
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-red-600 hover:bg-red-700 text-white text-sm font-semibold transition-colors"
                >
                  Sorun Gönder
                </button>
              </form>
            </details>
          )}

          {/* Demo acceleration — clearly marked */}
          {!deadlinePassed && (
            <div className="mt-4 pt-4 border-t border-dashed border-slate-200">
              <p className="text-xs text-slate-400 mb-2 font-mono">DEMO MODU</p>
              <form action={demoExpireDeadline}>
                <input type="hidden" name="proposal_id" value={id} />
                <button
                  type="submit"
                  className="text-xs px-3 py-1.5 rounded-lg border border-purple-200 bg-purple-50 text-purple-700 hover:bg-purple-100 font-medium transition-colors"
                >
                  ⚡ Demo: 24 Saati Geç (Sunum için)
                </button>
              </form>
            </div>
          )}
        </MagicCard>
      )}

      {/* Client: project closed */}
      {isClient && phase === 'closed' && (
        <MagicCard innerClassName="p-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-emerald-50 flex items-center justify-center mx-auto mb-3">
            <span className="text-2xl">🏁</span>
          </div>
          <h2 className="font-bold text-slate-900 mb-1">Proje Tamamlandı</h2>
          <p className="text-sm text-slate-500">Harika bir iş birliği oldu!</p>
        </MagicCard>
      )}

      {/* Disputed state */}
      {phase === 'disputed' && (
        <MagicCard innerClassName="p-6">
          <div className="flex items-center gap-3 mb-2">
            <span className="text-2xl">⚠️</span>
            <h2 className="font-bold text-slate-900">İtiraz Açıldı</h2>
          </div>
          <p className="text-sm text-slate-500">
            Bu sözleşmeye itiraz edildi.{' '}
            {proposal.dispute_note ? (
              <span>Not: {proposal.dispute_note}</span>
            ) : (
              'Escrow tutarı işverene iade edildi.'
            )}
          </p>
        </MagicCard>
      )}

      {/* === REVIEW SECTION (CLIENT only, after payout_pending or closed) === */}
      {showReviewSection && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-1">Freelancer&apos;ı Değerlendir</h2>
          <p className="text-sm text-slate-500 mb-5">
            <span className="font-medium text-slate-700">{otherParty?.full_name}</span> ile çalışma deneyiminizi paylaşın.
          </p>
          <form action={submitReview} className="space-y-4">
            <input type="hidden" name="proposal_id" value={id} />
            <input type="hidden" name="job_id" value={proposal.job_id} />
            <input type="hidden" name="reviewee_id" value={proposal.freelancer_id} />
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Puan <span className="text-red-500">*</span>
              </label>
              <div className="flex gap-2">
                {STAR_VALUES.map((v) => (
                  <label key={v} className="cursor-pointer">
                    <input type="radio" name="rating" value={v} required className="sr-only peer" />
                    <span className="text-2xl text-slate-300 peer-checked:text-amber-400 hover:text-amber-300 transition-colors select-none">
                      ★
                    </span>
                  </label>
                ))}
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1.5">
                Yorum (isteğe bağlı)
              </label>
              <textarea
                name="comment"
                rows={3}
                placeholder="Deneyiminizi anlatın..."
                className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand resize-none"
              />
            </div>
            <button
              type="submit"
              className="px-6 py-2.5 rounded-xl bg-brand hover:bg-brand-dark text-white text-sm font-semibold transition-colors"
            >
              Değerlendirmeyi Gönder
            </button>
          </form>
        </MagicCard>
      )}

      {/* Existing review display */}
      {isClient && existingReview && (
        <MagicCard innerClassName="p-5">
          <h3 className="text-sm font-bold text-slate-700 mb-2">Gönderilen Değerlendirme</h3>
          <div className="flex items-center gap-1 mb-1">
            {STAR_VALUES.map((v) => (
              <span key={v} className={v <= existingReview.rating ? 'text-amber-400' : 'text-slate-200'}>★</span>
            ))}
            <span className="text-xs text-slate-400 ml-2">{formatRelativeTime(existingReview.created_at)}</span>
          </div>
          {existingReview.comment && (
            <p className="text-sm text-slate-600 mt-1">{existingReview.comment}</p>
          )}
        </MagicCard>
      )}

      {/* Delivery history (for freelancer after submit, or reference) */}
      {!isClient && deliveries && deliveries.length > 0 && (
        <MagicCard innerClassName="p-6">
          <h2 className="text-base font-bold text-slate-900 mb-3">Gönderilen Teslimatlar</h2>
          <div className="space-y-2">
            {deliveries.map((d) => (
              <div key={d.id} className="flex items-start gap-3 p-3 rounded-xl border border-slate-100 bg-slate-50">
                <span className="text-lg mt-0.5">📄</span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900 truncate">{d.file_name}</p>
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
