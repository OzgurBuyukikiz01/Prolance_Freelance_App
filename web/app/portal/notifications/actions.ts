'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function sendTestNotification() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  await supabase.from('notifications').insert({
    profile_id: user.id,
    title: '🧪 Realtime Test',
    body: `This notification was created at ${new Date().toLocaleTimeString('en-US')} — web and Flutter should receive it simultaneously.`,
    type: 'system',
  });
}

export async function markNotificationRead(formData: FormData) {
  const id = formData.get('id') as string;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('id', id)
    .eq('profile_id', user.id);

  if (error) {
    redirect('/portal/notifications?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/notifications');
  redirect('/portal/notifications');
}

export async function markAllNotificationsRead() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('profile_id', user.id)
    .is('read_at', null);

  if (error) {
    redirect('/portal/notifications?error=' + encodeURIComponent(error.message));
  }

  revalidatePath('/portal/notifications');
  redirect('/portal/notifications');
}
