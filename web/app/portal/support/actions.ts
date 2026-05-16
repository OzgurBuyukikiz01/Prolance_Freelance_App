'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function createSupportTicket(formData: FormData) {
  const subject = (formData.get('subject') as string)?.trim() ?? '';
  const body = (formData.get('body') as string)?.trim() ?? '';
  const priority = (formData.get('priority') as string) || 'NORMAL';

  if (subject.length < 5) {
    redirect(`/portal/support?error=${encodeURIComponent('Konu en az 5 karakter olmalı.')}`);
  }
  if (body.length < 20) {
    redirect(`/portal/support?error=${encodeURIComponent('Açıklama en az 20 karakter olmalı.')}`);
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { error } = await supabase.from('tickets').insert({
    author_id: user.id,
    subject,
    body,
    priority,
    status: 'OPEN',
  });

  if (error) {
    redirect(`/portal/support?error=${encodeURIComponent(error.message)}`);
  }

  revalidatePath('/portal/support');
  redirect('/portal/support?submitted=1');
}
