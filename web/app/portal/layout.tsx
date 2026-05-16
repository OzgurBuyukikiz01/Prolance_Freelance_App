import { redirect } from 'next/navigation';
import { PortalShell } from '@/components/portal/PortalShell';
import { createClient } from '@/lib/supabase/server';

export default async function PortalLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, avatar_url')
    .eq('id', user.id)
    .single();

  const userName = profile?.full_name || user.email?.split('@')[0] || 'Kullanıcı';

  const { count: unreadNotificationCount } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('profile_id', user.id)
    .is('read_at', null);

  return (
    <PortalShell
      userName={userName}
      avatarUrl={profile?.avatar_url || null}
      unreadNotificationCount={unreadNotificationCount ?? 0}
    >
      {children}
    </PortalShell>
  );
}
