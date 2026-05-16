import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { SubmitReviewForm } from '@/components/portal/SubmitReviewForm';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  searchParams: Promise<{ jobId?: string; error?: string }>;
};

export default async function PortalNewReviewPage({ searchParams }: PageProps) {
  const query = await searchParams;
  const jobId = query.jobId;
  if (!jobId) redirect('/portal/jobs');

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: job } = await supabase
    .from('jobs')
    .select('id, title, client_id, status')
    .eq('id', jobId)
    .single();

  if (!job) notFound();

  if (job.status !== 'completed') {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('İş tamamlanmadan değerlendirme yapılamaz.')}`);
  }

  const { data: existingReview } = await supabase
    .from('reviews')
    .select('id')
    .eq('job_id', jobId)
    .eq('reviewer_id', user.id)
    .maybeSingle();

  if (existingReview) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Bu iş için zaten değerlendirme yaptınız.')}`);
  }

  let revieweeId = '';
  let revieweeName = '';

  if (job.client_id === user.id) {
    const { data: accepted } = await supabase
      .from('proposals')
      .select('freelancer_id')
      .eq('job_id', jobId)
      .eq('status', 'accepted')
      .maybeSingle();

    revieweeId = accepted?.freelancer_id ?? '';
    if (revieweeId) {
      const { data: freelancer } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', revieweeId)
        .maybeSingle();
      revieweeName = freelancer?.full_name ?? 'Freelancer';
    }
  } else {
    revieweeId = job.client_id;
    const { data: client } = await supabase
      .from('profiles')
      .select('full_name')
      .eq('id', job.client_id)
      .single();
    revieweeName = client?.full_name ?? 'İşveren';
  }

  if (!revieweeId || revieweeId === user.id) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Değerlendirilecek kullanıcı bulunamadı.')}`);
  }

  return (
    <div className="space-y-6">
      <div>
        <Link
          href={`/portal/jobs/${jobId}`}
          className="text-sm font-medium text-brand hover:text-brand-dark"
        >
          ← İş detayına dön
        </Link>
        <h1 className="text-2xl font-extrabold text-slate-900 mt-2">Değerlendirme</h1>
        <p className="text-sm text-slate-500 mt-1">{job.title}</p>
      </div>
      {query.error ? (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      ) : null}
      <MagicCard innerClassName="p-6">
        <SubmitReviewForm jobId={jobId} revieweeId={revieweeId} revieweeName={revieweeName} />
      </MagicCard>
    </div>
  );
}
