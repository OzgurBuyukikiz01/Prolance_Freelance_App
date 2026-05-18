'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function updateProfile(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const fullName = (formData.get('full_name') as string)?.trim() ?? '';
  const title = (formData.get('title') as string)?.trim() ?? '';
  const bio = (formData.get('bio') as string)?.trim() ?? '';
  const location = (formData.get('location') as string)?.trim() ?? '';
  const website = (formData.get('website') as string)?.trim() ?? '';
  const hourlyRate = Number(formData.get('hourly_rate'));
  const role = formData.get('role') as 'CLIENT' | 'FREELANCER';
  const skillsRaw = (formData.get('skills') as string)?.trim() ?? '';
  const skills = skillsRaw
    ? skillsRaw.split(',').map((s) => s.trim()).filter(Boolean)
    : [];

  if (!fullName) {
    redirect('/portal/profile?error=' + encodeURIComponent('Ad soyad gerekli.'));
  }

  const { error } = await supabase
    .from('profiles')
    .update({
      full_name: fullName,
      title,
      bio,
      location: location || 'Remote',
      website,
      hourly_rate: Number.isFinite(hourlyRate) ? hourlyRate : 0,
      role: role === 'CLIENT' ? 'CLIENT' : 'FREELANCER',
      skills,
    })
    .eq('id', user.id);

  if (error) {
    redirect('/portal/profile?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/profile');
  revalidatePath('/portal');
  redirect('/portal/profile?saved=1');
}

export async function uploadAvatar(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const file = formData.get('avatar') as File | null;
  if (!file || file.size === 0) {
    redirect('/portal/profile?error=' + encodeURIComponent('Please select a file.'));
  }

  const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg';
  const path = `${user.id}/avatar.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from('avatars')
    .upload(path, file, { upsert: true, contentType: file.type });

  if (uploadError) {
    redirect('/portal/profile?error=' + encodeURIComponent(uploadError.message));
  }

  const {
    data: { publicUrl },
  } = supabase.storage.from('avatars').getPublicUrl(path);

  const { error: profileError } = await supabase
    .from('profiles')
    .update({ avatar_url: publicUrl })
    .eq('id', user.id);

  if (profileError) {
    redirect('/portal/profile?error=' + encodeURIComponent(profileError.message));
  }

  revalidatePath('/portal/profile');
  redirect('/portal/profile?saved=1');
}
