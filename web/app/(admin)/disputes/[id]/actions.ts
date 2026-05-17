'use server';

import { revalidatePath } from 'next/cache';
import { createServiceClient, logAudit } from '@/lib/supabaseAdmin';
import { createClient } from '@/lib/supabase/server';

export async function resolveDispute(formData: FormData) {
  const sb = createServiceClient();
  const auth = await createClient();
  const {
    data: { user },
  } = await auth.auth.getUser();

  const escrowId = formData.get('escrow_id') as string;
  const proposalId = formData.get('proposal_id') as string | null;
  const resolution = formData.get('resolution') as 'release' | 'refund';
  const resolutionNote = (formData.get('resolution_note') as string)?.trim();

  if (!resolutionNote || resolutionNote.length < 20) {
    throw new Error('Karar açıklaması en az 20 karakter olmalıdır.');
  }

  const newStatus = resolution === 'release' ? 'RELEASED' : 'REFUNDED';

  // 1. Fetch escrow to get party IDs
  const { data: escrow } = await sb
    .from('escrow_transactions')
    .select('employer_id, freelancer_id')
    .eq('id', escrowId)
    .single();

  // 2. Update escrow with resolution details
  await sb.from('escrow_transactions').update({
    status: newStatus,
    resolution_note: resolutionNote,
    resolved_by: user?.id ?? null,
    resolved_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }).eq('id', escrowId);

  // 3. Write admin decision to proposal as well
  if (proposalId) {
    await sb.from('proposals').update({
      admin_resolution_note: resolutionNote,
    }).eq('id', proposalId);
  }

  // 4. Notify both parties
  if (escrow?.freelancer_id && escrow?.employer_id) {
    await sb.from('notifications').insert([
      {
        profile_id: escrow.freelancer_id,
        title:
          resolution === 'release'
            ? 'İtiraz Kararı: Lehinize sonuçlandı ✓'
            : 'İtiraz Kararı: Aleyhinize sonuçlandı',
        body: resolutionNote,
        type: 'dispute_resolved',
        payload: { escrow_id: escrowId, resolution },
      },
      {
        profile_id: escrow.employer_id,
        title:
          resolution === 'refund'
            ? 'İtiraz Kararı: Ödemeniz iade edildi ✓'
            : 'İtiraz Kararı: Freelancer lehine sonuçlandı',
        body: resolutionNote,
        type: 'dispute_resolved',
        payload: { escrow_id: escrowId, resolution },
      },
    ]);
  }

  // 5. Audit log
  await logAudit(
    user?.id ?? 'system',
    'escrow_resolution',
    escrowId,
    `${resolution === 'release' ? 'Freelancer' : 'İşveren'} lehine karar. Not: ${resolutionNote.slice(0, 120)}`,
  );

  revalidatePath(`/disputes/${escrowId}`);
  revalidatePath('/disputes');
}
