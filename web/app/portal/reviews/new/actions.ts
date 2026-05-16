'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function submitReview(formData: FormData) {
  const jobId = formData.get('job_id') as string;
  const revieweeId = formData.get('reviewee_id') as string;
  const rating = Number(formData.get('rating'));
  const comment = (formData.get('comment') as string)?.trim() ?? '';

  if (!jobId || !revieweeId) {
    redirect('/portal?error=' + encodeURIComponent('Geçersiz değerlendirme isteği.'));
  }
  if (!Number.isFinite(rating) || rating < 1 || rating > 5) {
    redirect(
      `/portal/reviews/new?jobId=${jobId}&error=${encodeURIComponent('1–5 arası puan seçin.')}`,
    );
  }
  if (comment.length < 10) {
    redirect(
      `/portal/reviews/new?jobId=${jobId}&error=${encodeURIComponent('Yorum en az 10 karakter olmalı.')}`,
    );
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: existing } = await supabase
    .from('reviews')
    .select('id')
    .eq('job_id', jobId)
    .eq('reviewer_id', user.id)
    .maybeSingle();

  if (existing) {
    redirect(
      `/portal/jobs/${jobId}?error=${encodeURIComponent('Bu iş için zaten değerlendirme yaptınız.')}`,
    );
  }

  const { error } = await supabase.from('reviews').insert({
    job_id: jobId,
    reviewer_id: user.id,
    reviewee_id: revieweeId,
    rating,
    comment,
  });

  if (error) {
    redirect(
      `/portal/reviews/new?jobId=${jobId}&error=${encodeURIComponent(error.message)}`,
    );
  }

  revalidatePath(`/portal/jobs/${jobId}`);
  revalidatePath('/portal/profile');
  redirect(`/portal/jobs/${jobId}?reviewed=1`);
}
