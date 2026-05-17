'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

function contractPath(id: string) {
  return `/portal/contracts/${id}`;
}

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const ALLOWED_FILE_TYPES = [
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/zip',
  'image/jpeg',
  'image/png',
  'image/gif',
  'text/plain',
  'text/csv',
];

export async function submitDelivery(formData: FormData) {
  const proposalId = formData.get('proposal_id') as string;
  const note = (formData.get('note') as string)?.trim();
  const files = formData.getAll('files') as File[];

  if (!note || note.length < 5) {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Lütfen teslimat notu girin (en az 5 karakter).')}`);
  }

  if (files.length === 0 || files[0]?.name === '') {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Lütfen en az 1 dosya yükleyin.')}`);
  }

  if (files.length > 10) {
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Maksimum 10 dosya yükleyebilirsiniz.')}`);
  }

  // Validate files
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(`${file.name} dosyası çok büyük (maksimum 50MB).`)}`);
    }
    if (!ALLOWED_FILE_TYPES.includes(file.type)) {
      redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(`${file.name} dosya türü desteklenmiyor.`)}`);
    }
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  // Register delivery metadata
  const { data: reg, error: regErr } = await supabase.rpc('rpc_register_proposal_delivery', {
    p_proposal_id: proposalId,
    p_file_name: note.slice(0, 512),
    p_storage_path: `deliveries/${proposalId}`,
  });

  if (regErr || !reg?.ok) {
    const msg = reg?.err === 'invalid_phase'
      ? 'Bu sözleşme teslimat için uygun aşamada değil.'
      : (regErr?.message ?? reg?.err ?? 'Teslimat kaydedilemedi.');
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  // Upload files to Supabase Storage
  const storagePath = `deliveries/${proposalId}`;
  const uploadedFiles = [];

  try {
    for (const file of files) {
      const fileExtension = file.name.split('.').pop() || 'bin';
      const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExtension}`;
      const filePath = `${storagePath}/${fileName}`;

      const { data, error: uploadErr } = await supabase.storage
        .from('deliveries')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadErr) {
        throw new Error(`Dosya yükleme başarısız: ${file.name}`);
      }

      uploadedFiles.push({
        name: file.name,
        path: filePath,
        size: file.size,
      });
    }
  } catch (error) {
    const msg = error instanceof Error ? error.message : 'Dosya yükleme başarısız.';
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  // Confirm submission so lifecycle advances to awaiting_client_review
  const { data: confirm, error: confirmErr } = await supabase.rpc(
    'rpc_freelancer_confirm_delivery_submission',
    { p_proposal_id: proposalId },
  );

  if (confirmErr || !confirm?.ok) {
    const msg = confirmErr?.message ?? confirm?.err ?? 'Teslimat onaylanamadı.';
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
    const msg = error?.message ?? data?.err ?? 'Teslimat kabul edilemedi.';
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
    const msg = error?.message ?? data?.err ?? 'İşlem gerçekleştirilemedi.';
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
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Lütfen sorun açıklaması girin (en az 10 karakter).')}`);
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
      ? 'İtiraz süresi doldu. Artık sorun bildirimi yapamazsınız.'
      : (error?.message ?? data?.err ?? 'Sorun bildirimi gönderilemedi.');
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
    const msg = error?.message ?? data?.err ?? 'Ödeme alınamadı.';
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
    const msg = error?.message ?? data?.err ?? 'Demo işlemi başarısız.';
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
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent('Lütfen geçerli bir puan seçin (1-5).')}`);
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
      ? 'Bu proje için zaten bir değerlendirme yaptınız.'
      : error.message;
    redirect(`${contractPath(proposalId)}?error=${encodeURIComponent(msg)}`);
  }

  // Recalculate freelancer rating
  await supabase.rpc('rpc_update_freelancer_rating', { p_freelancer_id: revieweeId });

  revalidatePath(contractPath(proposalId));
  revalidatePath(`/portal/profile`);
  redirect(`${contractPath(proposalId)}?success=reviewed`);
}
