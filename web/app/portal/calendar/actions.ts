'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function createScheduleItem(formData: FormData) {
  const jobId = formData.get('job_id') as string;
  const title = (formData.get('title') as string)?.trim();
  const dueDate = formData.get('due_date') as string;
  const assigneeId = (formData.get('assignee_id') as string) || null;

  if (!jobId || !title || !dueDate) {
    redirect('/portal/calendar?error=' + encodeURIComponent('Tüm alanları doldurun.'));
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { error } = await supabase.from('job_schedule_items').insert({
    job_id: jobId,
    title,
    due_date: dueDate,
    assignee_id: assigneeId,
    created_by: user.id,
  });

  if (error) {
    redirect('/portal/calendar?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/calendar');
  redirect('/portal/calendar?saved=1');
}

export async function deleteScheduleItem(formData: FormData) {
  const id = formData.get('id') as string;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { error } = await supabase.from('job_schedule_items').delete().eq('id', id);
  if (error) {
    redirect('/portal/calendar?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/calendar');
  redirect('/portal/calendar');
}

export async function toggleScheduleComplete(formData: FormData) {
  const id = formData.get('id') as string;
  const completed = formData.get('completed') === 'true';

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { error } = await supabase
    .from('job_schedule_items')
    .update({ completed_at: completed ? new Date().toISOString() : null })
    .eq('id', id);

  if (error) {
    redirect('/portal/calendar?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/calendar');
  redirect('/portal/calendar');
}
