'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function createJobListing(formData: FormData) {
  const title = (formData.get('title') as string)?.trim() ?? '';
  const description = (formData.get('description') as string)?.trim() ?? '';
  const category = (formData.get('category') as string)?.trim() ?? 'Genel';
  const budgetMin = Number(formData.get('budget_min'));
  const budgetMax = Number(formData.get('budget_max'));
  const budgetType = (formData.get('budget_type') as string) || 'fixed';
  const duration = (formData.get('duration') as string)?.trim() || '1-3 months';
  const experienceLevel = (formData.get('experience_level') as string)?.trim() || 'Intermediate';
  const skillsRaw = (formData.get('skills') as string)?.trim() ?? '';
  const skills = skillsRaw
    ? skillsRaw
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean)
    : [];

  if (title.length < 5) {
    redirect(`/portal/jobs/new?error=${encodeURIComponent('Başlık en az 5 karakter olmalı.')}`);
  }
  if (description.length < 20) {
    redirect(`/portal/jobs/new?error=${encodeURIComponent('Açıklama en az 20 karakter olmalı.')}`);
  }
  if (!Number.isFinite(budgetMin) || !Number.isFinite(budgetMax) || budgetMin <= 0 || budgetMax < budgetMin) {
    redirect(`/portal/jobs/new?error=${encodeURIComponent('Geçerli bütçe aralığı girin.')}`);
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('role, full_name, avatar_url')
    .eq('id', user.id)
    .single();

  if (profile?.role !== 'CLIENT') {
    redirect('/portal/jobs/new?error=' + encodeURIComponent('Yalnızca işveren hesapları ilan yayınlayabilir.'));
  }

  const { data: inserted, error } = await supabase
    .from('jobs')
    .insert({
      client_id: user.id,
      title,
      description,
      client_name: profile.full_name || user.email?.split('@')[0] || 'İşveren',
      client_avatar: profile.avatar_url || '',
      budget_min: budgetMin,
      budget_max: budgetMax,
      budget_type: budgetType,
      category,
      skills,
      experience_level: experienceLevel,
      duration,
      is_user_posted: true,
      listing_kind: 'job_offer',
      status: 'pending_review',
    })
    .select('id')
    .single();

  if (error || !inserted) {
    redirect(`/portal/jobs/new?error=${encodeURIComponent(error?.message ?? 'İlan oluşturulamadı.')}`);
  }

  revalidatePath('/portal/jobs');
  redirect(`/portal/jobs/${inserted.id}?posted=1`);
}
