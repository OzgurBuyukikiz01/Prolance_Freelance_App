'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion } from 'framer-motion';
import {
  Bell,
  Briefcase,
  Calendar,
  Home,
  MessageCircle,
  User,
} from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';

const NAV_ITEMS = [
  { href: '/portal', label: 'Ana Sayfa', icon: Home, exact: true },
  { href: '/portal/jobs', label: 'İş İlanları', icon: Briefcase, exact: false },
  { href: '/portal/calendar', label: 'Takvim', icon: Calendar, exact: false },
  { href: '/portal/messages', label: 'Mesajlar', icon: MessageCircle, exact: false },
  { href: '/portal/profile', label: 'Profil', icon: User, exact: false },
  { href: '/portal/notifications', label: 'Bildirimler', icon: Bell, exact: false, badgeKey: 'notifications' as const },
] as const;

function isActive(pathname: string, href: string, exact: boolean) {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(`${href}/`);
}

type PortalShellProps = {
  children: React.ReactNode;
  userName: string;
  avatarUrl?: string | null;
  unreadNotificationCount?: number;
};

export function PortalShell({
  children,
  userName,
  avatarUrl,
  unreadNotificationCount = 0,
}: PortalShellProps) {
  const pathname = usePathname();
  const initial = userName.charAt(0).toUpperCase();

  return (
    <motion.div className="min-h-screen bg-hero-gradient">
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full bg-brand/10 blur-3xl" />
        <motion.div
          className="absolute top-1/2 right-0 w-[360px] h-[360px] rounded-full bg-indigo-100/60 blur-3xl"
          animate={{ opacity: [0.5, 0.7, 0.5] }}
          transition={{ duration: 8, repeat: Infinity }}
        />
      </div>

      <motion.div
        className="flex min-h-screen"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.35 }}
      >
        <aside className="hidden lg:flex flex-col w-[220px] shrink-0 border-r border-slate-200/80 bg-white/60 backdrop-blur-md pt-6 pb-4 px-3">
          <Link href="/portal" className="flex items-center gap-2 px-3 mb-8">
            <span className="w-8 h-8 rounded-xl bg-brand flex items-center justify-center text-white text-sm font-black">
              P
            </span>
            <span className="font-bold text-slate-900">Prolance</span>
          </Link>
          <nav className="flex flex-col gap-1 flex-1">
            {NAV_ITEMS.map((item) => {
              const active = isActive(pathname, item.href, item.exact);
              const Icon = item.icon;
              const showBadge =
                'badgeKey' in item &&
                item.badgeKey === 'notifications' &&
                unreadNotificationCount > 0;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors',
                    active
                      ? 'bg-brand text-white shadow-brand'
                      : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900',
                  )}
                >
                  <span className="relative shrink-0">
                    <Icon className="w-5 h-5" />
                    {showBadge && (
                      <Badge
                        variant="destructive"
                        className="absolute -top-1.5 -right-2 h-4 min-w-4 px-1 text-[10px] border-0"
                      >
                        {unreadNotificationCount > 9 ? '9+' : unreadNotificationCount}
                      </Badge>
                    )}
                  </span>
                  {item.label}
                </Link>
              );
            })}
          </nav>
          <p className="px-3 text-xs text-slate-400 truncate" title={userName}>
            {userName}
          </p>
        </aside>

        <motion.div
          className="flex-1 flex flex-col min-w-0 pb-20 lg:pb-0"
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, delay: 0.05 }}
        >
          <header className="lg:hidden sticky top-0 z-40 bg-white/90 backdrop-blur-md border-b border-slate-100 px-4 h-14 flex items-center justify-between">
            <Link href="/portal" className="flex items-center gap-2 font-bold text-slate-900">
              <span className="w-7 h-7 rounded-lg bg-brand flex items-center justify-center text-white text-xs font-black">
                P
              </span>
              Prolance
            </Link>
            <motion.div className="flex items-center gap-2">
              <Link href="/portal/notifications" className="relative p-2 text-slate-500">
                <Bell className="w-5 h-5" />
                {unreadNotificationCount > 0 && (
                  <Badge
                    variant="destructive"
                    className="absolute -top-0.5 -right-0.5 h-4 min-w-4 px-1 text-[10px] border-0"
                  >
                    {unreadNotificationCount > 9 ? '9+' : unreadNotificationCount}
                  </Badge>
                )}
              </Link>
              <Link href="/portal/profile" className="flex items-center gap-2">
                <Avatar size="sm">
                  {avatarUrl ? <AvatarImage src={avatarUrl} alt={userName} /> : null}
                  <AvatarFallback className="bg-brand text-[10px] font-bold text-white">
                    {initial}
                  </AvatarFallback>
                </Avatar>
              </Link>
            </motion.div>
          </header>

          <main className="flex-1 px-4 py-6 lg:px-8 lg:py-8 max-w-3xl lg:max-w-4xl w-full mx-auto">
            {children}
          </main>
        </motion.div>
      </motion.div>

      <nav className="lg:hidden fixed bottom-0 inset-x-0 z-50 bg-white/95 backdrop-blur-xl border-t border-slate-200">
        <div className="flex items-stretch justify-around h-16 max-w-lg mx-auto px-1 pb-[env(safe-area-inset-bottom)]">
          {NAV_ITEMS.map((item) => {
            const active = isActive(pathname, item.href, item.exact);
            const Icon = item.icon;
            const showBadge =
              'badgeKey' in item &&
              item.badgeKey === 'notifications' &&
              unreadNotificationCount > 0;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex flex-col items-center justify-center gap-0.5 flex-1 min-w-0 px-1 transition-colors',
                  active ? 'text-brand' : 'text-slate-400',
                )}
              >
                <span className="relative">
                  <Icon className={cn('w-5 h-5', active && 'stroke-[2.5]')} />
                  {showBadge && (
                    <span className="absolute -top-1 -right-1.5 h-2 w-2 rounded-full bg-red-500 ring-2 ring-white" />
                  )}
                </span>
                <span className="text-[10px] font-medium truncate w-full text-center">
                  {item.label.split(' ')[0]}
                </span>
              </Link>
            );
          })}
        </div>
      </nav>
    </motion.div>
  );
}
