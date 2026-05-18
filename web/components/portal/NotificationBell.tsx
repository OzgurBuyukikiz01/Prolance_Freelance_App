'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Bell } from 'lucide-react';
import { cn } from '@/lib/utils';
import { createClient } from '@/lib/supabase/client';

export function NotificationBell({
  initialUnreadCount,
  active,
}: {
  initialUnreadCount: number;
  active: boolean;
}) {
  const [unread, setUnread] = useState(initialUnreadCount);

  useEffect(() => {
    const supabase = createClient();
    let userId: string | null = null;

    supabase.auth.getUser().then(({ data }) => {
      userId = data.user?.id ?? null;
      if (!userId) return;

      const channel = supabase
        .channel(`bell-notifications:${userId}`)
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
            filter: `profile_id=eq.${userId}`,
          },
          () => {
            setUnread((prev) => prev + 1);
          },
        )
        .on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'notifications',
            filter: `profile_id=eq.${userId}`,
          },
          () => {
            // Refetch unread count after read status changes
            supabase
              .from('notifications')
              .select('id', { count: 'exact', head: true })
              .eq('profile_id', userId!)
              .is('read_at', null)
              .then(({ count }) => {
                setUnread(count ?? 0);
              });
          },
        )
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    });
  }, []);

  return (
    <Link
      href="/portal/notifications"
      className={cn(
        'relative flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors',
        active
          ? 'bg-brand text-white shadow-brand'
          : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900',
      )}
    >
      <span className="relative shrink-0">
        <Bell className="w-5 h-5" />
        {unread > 0 && (
          <span className="absolute -top-1.5 -right-1.5 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[9px] font-bold text-white leading-none">
            {unread > 9 ? '9+' : unread}
          </span>
        )}
      </span>
      Bildirimler
    </Link>
  );
}

export function NotificationBellMobile({
  initialUnreadCount,
  active,
}: {
  initialUnreadCount: number;
  active: boolean;
}) {
  const [unread, setUnread] = useState(initialUnreadCount);

  useEffect(() => {
    const supabase = createClient();

    supabase.auth.getUser().then(({ data }) => {
      const userId = data.user?.id;
      if (!userId) return;

      const channel = supabase
        .channel(`bell-mobile:${userId}`)
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
            filter: `profile_id=eq.${userId}`,
          },
          () => setUnread((prev) => prev + 1),
        )
        .on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'notifications',
            filter: `profile_id=eq.${userId}`,
          },
          () => {
            supabase
              .from('notifications')
              .select('id', { count: 'exact', head: true })
              .eq('profile_id', userId)
              .is('read_at', null)
              .then(({ count }) => setUnread(count ?? 0));
          },
        )
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    });
  }, []);

  return (
    <Link
      href="/portal/notifications"
      className={cn(
        'flex flex-col items-center justify-center gap-0.5 flex-1 min-w-0 px-1 transition-colors',
        active ? 'text-brand' : 'text-slate-400',
      )}
    >
      <span className="relative">
        <Bell className={cn('w-5 h-5', active && 'stroke-[2.5]')} />
        {unread > 0 && (
          <span className="absolute -top-1.5 -right-1.5 flex h-3.5 w-3.5 items-center justify-center rounded-full bg-red-500 text-[8px] font-bold text-white leading-none">
            {unread > 9 ? '9+' : unread}
          </span>
        )}
      </span>
      <span className="text-[10px] font-medium">Bildiri.</span>
    </Link>
  );
}
