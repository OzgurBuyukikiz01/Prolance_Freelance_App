'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { createServiceClient } from '@/lib/supabaseAdmin';

export async function adminLogin(formData: FormData) {
  const supabase = await createClient();

  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  const { data, error } = await supabase.auth.signInWithPassword({ email, password });

  if (error || !data.user) {
    redirect('/admin/login?error=' + encodeURIComponent(error?.message ?? 'Giriş başarısız'));
  }

  // Check is_admin using service role (bypasses RLS)
  const sb = createServiceClient();
  const { data: profile } = await sb
    .from('profiles')
    .select('is_admin')
    .eq('id', data.user.id)
    .single();

  if (!profile?.is_admin) {
    // Sign out the non-admin immediately
    await supabase.auth.signOut();
    redirect('/admin/login?error=' + encodeURIComponent('Bu panele erişim yetkiniz yok.'));
  }

  revalidatePath('/', 'layout');
  redirect('/dashboard');
}

export async function adminLogout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath('/', 'layout');
  redirect('/admin/login');
}
