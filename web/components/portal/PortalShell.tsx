'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion } from 'framer-motion';
import { Briefcase, FileCheck, Home, MessageCircle, User } from 'lucide-react';
import { NotificationBell, NotificationBellMobile } from '@/components/portal/NotificationBell';
import { cn } from '@/lib/utils';

const NAV_ITEMS = [
  { href: '/portal', label: 'Home', icon: Home, exact: true },
  { href: '/portal/jobs', label: 'Jobs', icon: Briefcase, exact: false },
  { href: '/portal/contracts', label: 'Contracts', icon: FileCheck, exact: false },
  { href: '/portal/messages', label: 'Messages', icon: MessageCircle, exact: false },
  { href: '/portal/profile', label: 'Profile', icon: User, exact: false },
] as const;

function isActive(pathname: string, href: string, exact: boolean) {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(`${href}/`);
}

type PortalShellProps = {
  children: React.ReactNode;
  userName: string;
  initialUnreadCount?: number;
};

export function PortalShell({ children, userName, initialUnreadCount = 0 }: PortalShellProps) {
  const pathname = usePathname();
  const notifActive = isActive(pathname, '/portal/notifications', false);

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(56,189,248,0.10),_transparent_32%),linear-gradient(180deg,_#020617_0%,_#0f172a_44%,_#111827_100%)]">
      <motion.div
        className="flex min-h-screen"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.35 }}
      >
        <aside className="hidden w-[280px] shrink-0 flex-col border-r border-white/8 bg-slate-950/50 px-4 pb-5 pt-5 backdrop-blur-2xl lg:flex">
          <Link
            href="/portal"
            className="mb-8 rounded-3xl border border-white/10 bg-white/[0.04] px-4 py-4 shadow-[0_18px_45px_rgba(2,6,23,0.28)]"
          >
            <div className="flex items-center gap-3">
              <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-brand text-sm font-black text-white shadow-brand">
                P
              </span>
              <div>
                <p className="font-display text-lg font-bold text-white">Prolance</p>
                <p className="text-xs text-slate-400">Client and freelancer workspace</p>
              </div>
            </div>
          </Link>

          <div className="mb-5 rounded-3xl border border-white/10 bg-gradient-to-br from-white/[0.05] to-white/[0.02] px-4 py-4">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
              Signed in as
            </p>
            <p className="mt-2 truncate text-sm font-semibold text-slate-100" title={userName}>
              {userName}
            </p>
          </div>

          <nav className="flex flex-1 flex-col gap-1.5">
            {NAV_ITEMS.map((item) => {
              const active = isActive(pathname, item.href, item.exact);
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 rounded-2xl px-3.5 py-3 text-sm font-medium transition-all',
                    active
                      ? 'bg-white text-slate-950 shadow-[0_12px_30px_rgba(255,255,255,0.18)]'
                      : 'text-slate-400 hover:bg-white/[0.06] hover:text-white',
                  )}
                >
                  <Icon className="h-5 w-5 shrink-0" />
                  <span>{item.label}</span>
                </Link>
              );
            })}
            <NotificationBell initialUnreadCount={initialUnreadCount} active={notifActive} />
          </nav>

          <p className="px-1 pt-4 text-xs text-slate-500">
            Keep jobs, proposals, and contracts synced in one place.
          </p>
        </aside>

        <motion.div
          className="flex min-w-0 flex-1 flex-col pb-20 lg:pb-0"
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, delay: 0.05 }}
        >
          <header className="sticky top-0 z-40 border-b border-white/8 bg-slate-950/70 px-4 backdrop-blur-2xl lg:hidden">
            <div className="flex h-16 items-center justify-between">
              <Link href="/portal" className="flex items-center gap-3 font-bold text-white">
                <span className="flex h-9 w-9 items-center justify-center rounded-2xl bg-brand text-sm font-black text-white shadow-brand">
                  P
                </span>
                <div>
                  <p className="font-display text-base">Prolance</p>
                  <p className="text-[11px] font-medium text-slate-500">Workspace</p>
                </div>
              </Link>
              <span className="max-w-[150px] truncate text-xs text-slate-400">{userName}</span>
            </div>
          </header>

          <main className="mx-auto flex w-full max-w-6xl flex-1 px-4 py-6 lg:px-8 lg:py-10">
            <div className="w-full rounded-[32px] border border-white/8 bg-slate-950/30 p-4 shadow-[0_22px_80px_rgba(2,6,23,0.28)] backdrop-blur-xl sm:p-6 lg:p-8">
              {children}
            </div>
          </main>
        </motion.div>
      </motion.div>

      <nav className="fixed inset-x-0 bottom-0 z-50 border-t border-white/8 bg-slate-950/90 backdrop-blur-2xl lg:hidden">
        <div className="mx-auto flex h-16 max-w-lg items-stretch justify-around px-1 pb-[env(safe-area-inset-bottom)]">
          {NAV_ITEMS.map((item) => {
            const active = isActive(pathname, item.href, item.exact);
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex min-w-0 flex-1 flex-col items-center justify-center gap-0.5 px-1 transition-colors',
                  active ? 'text-white' : 'text-slate-500',
                )}
              >
                <span
                  className={cn(
                    'flex h-8 w-8 items-center justify-center rounded-2xl transition-colors',
                    active && 'bg-white text-slate-950',
                  )}
                >
                  <Icon className={cn('h-4.5 w-4.5', active && 'stroke-[2.5]')} />
                </span>
                <span className="w-full truncate text-center text-[10px] font-medium">
                  {item.label.split(' ')[0]}
                </span>
              </Link>
            );
          })}
          <NotificationBellMobile initialUnreadCount={initialUnreadCount} active={notifActive} />
        </div>
      </nav>
    </div>
  );
}
