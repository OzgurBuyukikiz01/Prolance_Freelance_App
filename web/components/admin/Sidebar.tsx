'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { adminLogout } from '@/app/admin/login/actions';
import {
  LayoutDashboard,
  Ticket,
  ShieldAlert,
  Users,
  ScrollText,
  LogOut,
  Briefcase,
} from 'lucide-react';

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/jobs', label: 'İlan Moderasyonu', icon: Briefcase },
  { href: '/tickets', label: 'Ticketlar', icon: Ticket },
  { href: '/disputes', label: 'Anlaşmazlıklar', icon: ShieldAlert },
  { href: '/users', label: 'Kullanıcılar', icon: Users },
  { href: '/audit', label: 'Audit Log', icon: ScrollText },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-60 flex-shrink-0 bg-slate-900 border-r border-slate-800 flex flex-col min-h-screen">
      {/* Brand */}
      <div className="px-5 py-5 border-b border-slate-800 flex items-center gap-2.5">
        <span className="w-8 h-8 rounded-lg bg-amber-500 flex items-center justify-center text-slate-900 font-black text-sm">
          P
        </span>
        <div>
          <div className="text-white font-extrabold text-sm leading-none">Prolance</div>
          <div className="text-amber-400 text-[10px] font-semibold tracking-widest uppercase">
            Admin
          </div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 flex flex-col gap-1">
        {navItems.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || pathname.startsWith(href + '/');
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                active
                  ? 'bg-amber-500/15 text-amber-400'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800'
              }`}
            >
              <Icon size={16} />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="px-3 py-4 border-t border-slate-800">
        <form action={adminLogout}>
          <button
            type="submit"
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-slate-400 hover:text-red-400 hover:bg-red-500/10 transition-colors"
          >
            <LogOut size={16} />
            Çıkış Yap
          </button>
        </form>
      </div>
    </aside>
  );
}
