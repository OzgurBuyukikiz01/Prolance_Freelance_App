'use server';

import { revalidatePath } from 'next/cache';
import { createServiceClient, logAudit } from '@/lib/supabaseAdmin';
import { createClient } from '@/lib/supabase/server';

export async function toggleBan(formData: FormData) {
  const sb = createServiceClient();
  const auth = await createClient();
  const { data: { user: adminUser } } = await auth.auth.getUser();

  const userId = formData.get('user_id') as string;
  const action = formData.get('action') as string; // 'ban' | 'unban'
  const isBanned = action === 'ban';

  await sb.from('profiles').update({ is_banned: isBanned }).eq('id', userId);

  await logAudit(
    adminUser?.id ?? 'system',
    isBanned ? 'user_banned' : 'user_unbanned',
    userId,
    `Admin ${isBanned ? 'banned user' : 'unbanned user'}`,
  );

  revalidatePath(`/users/${userId}`);
  revalidatePath('/users');
}
