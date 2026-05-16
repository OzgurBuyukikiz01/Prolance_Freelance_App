'use server';

import { revalidatePath } from 'next/cache';
import { createServiceClient } from '@/lib/supabaseAdmin';
import { createClient } from '@/lib/supabase/server';
import { logAudit } from '@/lib/supabaseAdmin';

export async function updateTicket(formData: FormData) {
  const sb = createServiceClient();
  const auth = await createClient();
  const { data: { user } } = await auth.auth.getUser();

  const ticketId = formData.get('ticket_id') as string;
  const status = formData.get('status') as string;
  const adminNotes = formData.get('admin_notes') as string;

  await sb
    .from('tickets')
    .update({ status, admin_notes: adminNotes, updated_at: new Date().toISOString() })
    .eq('id', ticketId);

  await logAudit(user?.id ?? 'system', 'ticket_update', ticketId, `Status → ${status}`);

  revalidatePath(`/tickets/${ticketId}`);
  revalidatePath('/tickets');
}
