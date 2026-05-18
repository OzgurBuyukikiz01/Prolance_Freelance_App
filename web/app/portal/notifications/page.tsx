import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { NotificationsClient } from '@/components/portal/NotificationsClient';

type PageProps = {
  searchParams: Promise<{ error?: string }>;
};

export default async function PortalNotificationsPage({ searchParams }: PageProps) {
  const query = await searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: notifications } = await supabase
    .from('notifications')
    .select('id, title, body, type, read_at, created_at')
    .eq('profile_id', user.id)
    .order('created_at', { ascending: false })
    .limit(50);

  return (
    <NotificationsClient
      initialNotifications={notifications ?? []}
      userId={user.id}
      initialError={query.error}
    />
  );
}
