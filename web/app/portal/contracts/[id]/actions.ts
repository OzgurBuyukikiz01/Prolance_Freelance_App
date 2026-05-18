'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

function contractPath(id: string) {
  return `/portal/contracts/${id}`;
}

export async function submitDelivery(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const note = (formData.get('note') as string)?.trim();
  const url = (formData.get('url') as string)?.trim();

  if (!note || note.length < 5) {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Please enter a delivery note (min. 5 characters).')}`);
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  // Register delivery metadata (note as file_name, url or placeholder as storage_path)
  const { data: reg, error: regErr } = await supabase.rpc('rpc_register_proposal_delivery', {
    p_proposal_id: proposalId,
    p_file_name: note.slice(0, 512),
    p_storage_path: url || 'demo://no-file',
  });

  if (regErr || !reg?.ok) {
    const msg = reg?.err === 'invalid_phase'
      ? 'This contract is not in the correct phase for delivery.'
      : (regErr?.message ?? reg?.err ?? 'Failed to save delivery.');
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  // Confirm submission so lifecycle advances to awaiting_client_review
  const { data: confirm, error: confirmErr } = await supabase.rpc(
    'rpc_freelancer_confirm_delivery_submission',
    { p_proposal_id: proposalId },
  );

  if (confirmErr || !confirm?.ok) {
    const msg = confirmErr?.message ?? confirm?.err ?? 'Could not confirm delivery.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  revalidatePath('/portal/contracts');
  redirect(`${contractPath(proposalId)}?success=delivered`);
}

export async function acceptDelivery(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data, error } = await supabase.rpc('rpc_client_review_delivery', {
    p_proposal_id: proposalId,
    p_accept: true,
  });

  if (error || !data?.ok) {
    const msg = error?.message ?? data?.err ?? 'Could not accept delivery.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  revalidatePath('/portal/contracts');
  redirect(`${contractPath(proposalId)}?success=accepted`);
}

export async function declineDelivery(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data, error } = await supabase.rpc('rpc_client_review_delivery', {
    p_proposal_id: proposalId,
    p_accept: false,
  });

  if (error || !data?.ok) {
    const msg = error?.message ?? data?.err ?? 'Action could not be completed.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  revalidatePath('/portal/contracts');
  redirect(`${contractPath(proposalId)}?success=declined`);
}

export async function reportIssue(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const note = (formData.get('note') as string)?.trim() ?? '';

  if (!note || note.length < 10) {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Please describe the issue (min. 10 characters).')}`);
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data, error } = await supabase.rpc('rpc_dispute_delivery_timeline', {
    p_proposal_id: proposalId,
    p_note: note,
  });

  if (error || !data?.ok) {
    const msg = data?.err === 'dispute_window_closed'
      ? 'Dispute window closed. You can no longer report an issue.'
      : (error?.message ?? data?.err ?? 'Failed to submit issue.');
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  revalidatePath('/portal/contracts');
  redirect(`${contractPath(proposalId)}?success=reported`);
}

export async function claimEarnings(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data, error } = await supabase.rpc('rpc_finalize_proposal_payouts');

  if (error || !data?.ok) {
    const msg = error?.message ?? data?.err ?? 'Could not claim payment.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  revalidatePath('/portal/contracts');
  revalidatePath('/portal');
  redirect(`${contractPath(proposalId)}?success=claimed`);
}

export async function demoExpireDeadline(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data, error } = await supabase.rpc('rpc_demo_expire_deadline', {
    p_proposal_id: proposalId,
  });

  if (error || !data?.ok) {
    const msg = error?.message ?? data?.err ?? 'Demo action failed.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  revalidatePath(contractPath(proposalId));
  redirect(`${contractPath(proposalId)}?success=deadline_expired`);
}

export async function submitReview(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const jobId = formData.get('job_id') as string;
  const revieweeId = formData.get('reviewee_id') as string;
  const rating = Number(formData.get('rating'));
  const comment = (formData.get('comment') as string)?.trim() ?? '';

  if (!rating || rating < 1 || rating > 5) {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Please select a valid rating (1-5).')}`);
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { error } = await supabase.from('reviews').insert({
    job_id: jobId,
    reviewer_id: user.id,
    reviewee_id: revieweeId,
    rating,
    comment: comment || null,
  });

  if (error) {
    const msg = error.code === '23505'
      ? 'You have already submitted a review for this project.'
      : error.message;
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  // Recalculate freelancer rating
  await supabase.rpc('rpc_update_freelancer_rating', { p_freelancer_id: revieweeId });

  revalidatePath(contractPath(proposalId));
  revalidatePath(`/portal/profile`);
  redirect(`${contractPath(proposalId)}?success=reviewed`);
}
