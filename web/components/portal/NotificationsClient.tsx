'use client';

import { useEffect, useState, useCallback, useTransition } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, CheckCheck } from 'lucide-react';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/client';
import { formatRelativeTime } from '@/lib/portal/format';
import {
  markNotificationRead,
  markAllNotificationsRead,
  sendTestNotification,
} from '@/app/portal/notifications/actions';

type NotificationRow = {
  id: string;
  title: string;
  body: string;
  type: string;
  read_at: string | null;
  created_at: string;
};

type ToastItem = { id: string; title: string; body: string };

export function NotificationsClient({
  initialNotifications,
  userId,
  initialError,
}: {
  initialNotifications: NotificationRow[];
  userId: string;
  initialError?: string;
}) {
  const [notifications, setNotifications] = useState<NotificationRow[]>(initialNotifications);
  const [toasts, setToasts] = useState<ToastItem[]>([]);
  const [isPending, startTransition] = useTransition();

  const pushToast = useCallback((item: ToastItem) => {
    setToasts((prev) => [...prev, item]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== item.id));
    }, 4500);
  }, []);

  useEffect(() => {
    const supabase = createClient();
    const channel = supabase
      .channel(`notifications:${userId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          filter: `profile_id=eq.${userId}`,
        },
        (payload) => {
          const row = payload.new as NotificationRow;
          setNotifications((prev) => [row, ...prev]);
          pushToast({ id: row.id, title: row.title, body: row.body });
        },
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [userId, pushToast]);

  const unreadCount = notifications.filter((n) => !n.read_at).length;

  return (
    <div className="space-y-6">
      {/* Toast overlay */}
      <div className="fixed top-4 right-4 z-[9999] flex flex-col gap-2 pointer-events-none">
        <AnimatePresence>
          {toasts.map((t) => (
            <motion.div
              key={t.id}
              initial={{ opacity: 0, x: 60, scale: 0.95 }}
              animate={{ opacity: 1, x: 0, scale: 1 }}
              exit={{ opacity: 0, x: 60, scale: 0.95 }}
              transition={{ duration: 0.25 }}
              className="pointer-events-auto flex items-start gap-3 rounded-2xl bg-white shadow-xl border border-brand/30 px-4 py-3 max-w-xs"
            >
              <span className="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-brand/10">
                <Bell className="w-4 h-4 text-brand" />
              </span>
              <div className="min-w-0">
                <p className="text-sm font-semibold text-slate-900 truncate">{t.title}</p>
                <p className="text-xs text-slate-500 truncate">{t.body}</p>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {/* Header */}
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Notifications</h1>
          <p className="text-sm text-slate-400 mt-1">
            {unreadCount > 0 ? `${unreadCount} unread` : 'All caught up'}
          </p>
        </div>
        <div className="flex items-center gap-2">
          {/* Test notification trigger — always visible for demo */}
          <form
            action={() =>
              startTransition(async () => {
                await sendTestNotification();
              })
            }
          >
            <button
              type="submit"
              disabled={isPending}
              className="text-xs font-semibold border border-dashed border-brand/50 text-brand rounded-lg px-3 py-1.5 hover:bg-brand/5 disabled:opacity-50 transition-colors"
            >
              🧪 Send Test Notification
            </button>
          </form>
          {unreadCount > 0 && (
            <form action={markAllNotificationsRead}>
              <button
                type="submit"
                className="flex items-center gap-1 text-sm font-semibold text-brand hover:text-brand-dark"
              >
                <CheckCheck className="w-4 h-4" />
                Mark all as read
              </button>
            </form>
          )}
        </div>
      </div>

      {initialError && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(initialError)}
        </div>
      )}

      <AnimatePresence initial={false}>
        {!notifications.length ? (
          <MagicCard innerClassName="p-8 text-center text-sm text-slate-400">
            No notifications yet.
          </MagicCard>
        ) : (
          <ul className="space-y-3">
            {notifications.map((n, i) => {
              const isRead = Boolean(n.read_at);
              return (
                <motion.li
                  key={n.id}
                  initial={{ opacity: 0, y: -12 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.25, delay: i === 0 ? 0 : 0 }}
                >
                  <MagicCard className={isRead ? 'opacity-80' : ''} innerClassName="p-4">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          {!isRead && (
                            <span className="inline-block w-2 h-2 rounded-full bg-brand shrink-0" />
                          )}
                          <p className="font-semibold text-white">{n.title}</p>
                        </div>
                        <p className="text-sm text-slate-400 mt-1">{n.body}</p>
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
                            Mark read
                          </button>
                        </form>
                      )}
                    </div>
                  </MagicCard>
                </motion.li>
              );
            })}
          </ul>
        )}
      </AnimatePresence>
    </div>
  );
}
