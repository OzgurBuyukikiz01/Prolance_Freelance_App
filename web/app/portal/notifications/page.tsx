import { redirect } from 'next/navigation';
import { MagicCard } from '@/components/ui/magic-card';
import { markAllNotificationsRead, markNotificationRead } from '@/app/portal/notifications/actions';
import { createClient } from '@/lib/supabase/server';
import { formatRelativeTime } from '@/lib/portal/format';

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

  const { data: notifications, error } = await supabase
    .from('notifications')
    .select('id, title, body, type, read_at, created_at')
    .eq('profile_id', user.id)
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-600">
        Bildirimler yüklenemedi: {error.message}
      </MagicCard>
    );
  }

  const unreadCount = (notifications ?? []).filter((n) => !n.read_at).length;

  const typeIcon = (type: string | null) => {
    switch (type) {
      case 'job':
        return '💼';
      case 'payment':
        return '💳';
      case 'message':
        return '💬';
      case 'system':
        return '⚙️';
      default:
        return '🔔';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Bildirimler</h1>
          <p className="text-sm text-slate-500 mt-1">
            {unreadCount > 0 ? `${unreadCount} okunmamış` : 'Tümü okundu'}
          </p>
        </div>
        {unreadCount > 0 && (
          <form action={markAllNotificationsRead}>
            <button
              type="submit"
              className="text-sm font-semibold text-brand hover:text-brand-dark"
            >
              Tümünü okundu işaretle
            </button>
          </form>
        )}
      </div>

      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}

      {!notifications?.length ? (
        <MagicCard innerClassName="p-8 text-center text-sm text-slate-500">
          Henüz bildirim yok.
        </MagicCard>
      ) : (
        <ul className="space-y-3">
          {notifications.map((n) => {
            const isRead = Boolean(n.read_at);
            return (
              <li key={n.id}>
                <MagicCard
                  className={isRead ? 'opacity-80' : 'ring-1 ring-brand/20'}
                  innerClassName="p-4"
                >
                  <div className="flex items-start justify-between gap-3">
                    <span className="text-lg shrink-0" aria-hidden>
                      {typeIcon(n.type)}
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="font-semibold text-slate-900">{n.title}</p>
                      <p className="text-sm text-slate-600 mt-1">{n.body}</p>
                      <p className="text-xs text-slate-400 mt-2">
                        {formatRelativeTime(n.created_at)}
                        {n.type ? ` · ${n.type}` : ''}
                      </p>
                    </div>
                    {!isRead && (
                      <form action={markNotificationRead}>
                        <input type="hidden" name="id" value={n.id} />
                        <button
                          type="submit"
                          className="text-xs font-semibold text-brand hover:text-brand-dark whitespace-nowrap"
                        >
                          Okundu
                        </button>
                      </form>
                    )}
                  </div>
                </MagicCard>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
