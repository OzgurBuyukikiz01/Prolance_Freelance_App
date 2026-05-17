'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { buildMilestoneRows } from '@/lib/portal/schedule-milestones';

export async function submitProposal(formData: FormData) {
  const jobId = formData.get('job_id') as string;
  const bid = Number(formData.get('bid'));
  const deliveryDays = Number(formData.get('delivery_days'));
  const coverLetter = (formData.get('cover_letter') as string)?.trim() ?? '';

  if (!jobId || !Number.isFinite(bid) || bid <= 0 || !Number.isFinite(deliveryDays) || deliveryDays < 1) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Geçerli teklif bilgileri girin.')}`);
  }

  if (coverLetter.length < 10) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Kapak yazısı en az 10 karakter olmalı.')}`);
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { error } = await supabase.from('proposals').insert({
    job_id: jobId,
    freelancer_id: user.id,
    bid,
    delivery_days: deliveryDays,
    cover_letter: coverLetter,
    attachments: [],
    status: 'pending',
  });

  if (error) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent(error.message)}`);
  }

  revalidatePath(`/portal/jobs/${jobId}`);
  revalidatePath('/portal/proposals');
  redirect(`/portal/jobs/${jobId}?submitted=1`);
}

export async function acceptProposal(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const jobId = formData.get('job_id') as string;
  const freelancerId = formData.get('freelancer_id') as string;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  // Use RPC to accept proposal — handles demo_balance deduction, escrow creation, lifecycle phase
  const { data, error } = await supabase.rpc('rpc_accept_proposal', {
    p_proposal_id: proposalId,
  });

  if (error || !data?.ok) {
    const msg = data?.err === 'insufficient_demo_balance'
      ? 'Demo bakiyeniz yetersiz. Lütfen admin ile iletişime geçin.'
      : data?.err === 'job_already_accepted'
      ? 'Bu iş için zaten bir teklif kabul edildi.'
      : (error?.message ?? data?.err ?? 'Teklif kabul edilemedi.');
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent(msg)}`);
  }

  // Reject remaining pending proposals on the same job
  await supabase
    .from('proposals')
    .update({ status: 'rejected' })
    .eq('job_id', jobId)
    .neq('id', proposalId)
    .eq('status', 'pending');

  // Fetch delivery_days for milestone creation
  const { data: proposal } = await supabase
    .from('proposals')
    .select('delivery_days')
    .eq('id', proposalId)
    .maybeSingle();

  if (proposal?.delivery_days && freelancerId && user.id) {
    const milestones = buildMilestoneRows(
      jobId,
      proposalId,
      proposal.delivery_days,
      freelancerId,
      user.id,
    );
    if (milestones?.length) {
      await supabase.from('job_schedule_items').insert(milestones);
    }
  }

  revalidatePath(`/portal/jobs/${jobId}`);
  revalidatePath('/portal/calendar');
  revalidatePath('/portal/proposals');
  revalidatePath('/portal/contracts');
  redirect(`/portal/jobs/${jobId}?accepted=1`);
}

export async function rejectProposal(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const jobId = formData.get('job_id') as string;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: job } = await supabase
    .from('jobs')
    .select('client_id')
    .eq('id', jobId)
    .single();

  if (!job || job.client_id !== user.id) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Yetkisiz işlem.')}`);
  }

  const { error } = await supabase
    .from('proposals')
    .update({ status: 'rejected' })
    .eq('id', proposalId);

  if (error) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent(error.message)}`);
  }

  revalidatePath(`/portal/jobs/${jobId}`);
  redirect(`/portal/jobs/${jobId}`);
}

export async function openEscrowDispute(formData: FormData) {
  const escrowId = formData.get('escrow_id') as string;
  const jobId = formData.get('job_id') as string;
  const reason = (formData.get('reason') as string)?.trim() ?? '';

  if (!escrowId || !jobId) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Escrow kaydı bulunamadı.')}`);
  }
  if (reason.length < 10) {
    redirect(
      `/portal/jobs/${jobId}?error=${encodeURIComponent('Anlaşmazlık nedeni en az 10 karakter olmalı.')}`,
    );
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: escrow } = await supabase
    .from('escrow_transactions')
    .select('employer_id, freelancer_id, status')
    .eq('id', escrowId)
    .single();

  if (
    !escrow ||
    (escrow.employer_id !== user.id && escrow.freelancer_id !== user.id)
  ) {
    redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent('Yetkisiz işlem.')}`);
  }

  const { error: invokeError } = await supabase.functions.invoke('escrow', {
    body: { op: 'dispute', escrowId, reason },
  });

  if (invokeError) {
    const { error: updateError } = await supabase
      .from('escrow_transactions')
      .update({ status: 'DISPUTED', dispute_reason: reason })
      .eq('id', escrowId);

    if (updateError) {
      redirect(`/portal/jobs/${jobId}?error=${encodeURIComponent(updateError.message)}`);
    }
  }

  revalidatePath(`/portal/jobs/${jobId}`);
  redirect(`/portal/jobs/${jobId}?dispute=1`);
}
