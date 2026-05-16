'use server';

import { revalidatePath } from 'next/cache';
import { createServiceClient, logAudit } from '@/lib/supabaseAdmin';
import { createClient } from '@/lib/supabase/server';

export async function resolveDispute(formData: FormData) {
  const sb = createServiceClient();
  const auth = await createClient();
  const { data: { user } } = await auth.auth.getUser();

  const escrowId = formData.get('escrow_id') as string;
  const resolution = formData.get('resolution') as string; // 'release' | 'refund'

  const newStatus = resolution === 'release' ? 'RELEASED' : 'REFUNDED';

  await sb
    .from('escrow_transactions')
    .update({ status: newStatus, updated_at: new Date().toISOString() })
    .eq('id', escrowId);

  await logAudit(
    user?.id ?? 'system',
    'escrow_resolution',
    escrowId,
    `Admin ${resolution === 'release' ? 'freelancer\'a serbest bıraktı' : 'işverene iade etti'}`,
  );

  revalidatePath(`/disputes/${escrowId}`);
  revalidatePath('/disputes');
}
