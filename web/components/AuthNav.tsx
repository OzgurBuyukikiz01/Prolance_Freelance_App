import { createClient } from '@/lib/supabase/server';
import { AuthNavClient } from '@/components/AuthNavClient';

function LoginLink() {
  return (
    <a
      href="/login"
      className="inline-flex items-center gap-1.5 bg-brand hover:bg-brand-dark text-white text-sm font-semibold px-4 py-2 rounded-xl transition-colors shadow-brand"
    >
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
      </svg>
      Giriş Yap
    </a>
  );
}

export default async function AuthNav() {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return <LoginLink />;
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('full_name, is_admin, avatar_url')
      .eq('id', user.id)
      .single();

    const name = profile?.full_name || user.email?.split('@')[0] || 'Kullanıcı';

    return (
      <AuthNavClient
        name={name}
        isAdmin={Boolean(profile?.is_admin)}
        avatarUrl={profile?.avatar_url || null}
      />
    );
  } catch (error) {
    console.error('[AuthNav] Supabase unavailable:', error);
    return <LoginLink />;
  }
}
