'use server';

import { revalidatePath } from 'next/cache';
import { createServiceClient, logAudit } from '@/lib/supabaseAdmin';
import { createClient } from '@/lib/supabase/server';

export async function approveJob(formData: FormData) {
  const jobId = formData.get('job_id') as string;
  if (!jobId) return;

  const sb = createServiceClient();
  const auth = await createClient();
  const {
    data: { user },
  } = await auth.auth.getUser();

  await sb
    .from('jobs')
    .update({
      status: 'open',
      moderated_by: user?.id ?? null,
      rejection_reason: null,
    })
    .eq('id', jobId);

  await logAudit(
    user?.id ?? 'system',
    'job_approve',
    jobId,
    'Admin approved the job listing',
    'jobs',
  );

  revalidatePath('/jobs');
  revalidatePath('/dashboard');
}

export async function rejectJob(formData: FormData) {
  const jobId = formData.get('job_id') as string;
  const reason = ((formData.get('rejection_reason') as string) ?? '').trim();
  if (!jobId || !reason) return;

  const sb = createServiceClient();
  const auth = await createClient();
  const {
    data: { user },
  } = await auth.auth.getUser();

  await sb
    .from('jobs')
    .update({
      status: 'rejected',
      moderated_by: user?.id ?? null,
      rejection_reason: reason,
    })
    .eq('id', jobId);

  await logAudit(
    user?.id ?? 'system',
    'job_reject',
    jobId,
    `Admin rejected the job listing: ${reason}`,
    'jobs',
  );

  revalidatePath('/jobs');
  revalidatePath('/dashboard');
}
