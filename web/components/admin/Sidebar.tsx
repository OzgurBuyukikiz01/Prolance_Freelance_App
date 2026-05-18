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
  { href: '/dashboard', label: 'Dashboard',   icon: LayoutDashboard },
  { href: '/jobs',      label: 'Job Moderation', icon: Briefcase },
  { href: '/tickets',   label: 'Tickets',     icon: Ticket },
  { href: '/disputes',  label: 'Disputes',    icon: ShieldAlert },
  { href: '/users',     label: 'Users',       icon: Users },
  { href: '/audit',     label: 'Audit Log',   icon: ScrollText },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 flex-shrink-0 flex flex-col min-h-screen border-r border-white/10 bg-white/[0.04] backdrop-blur-xl">
      {/* Brand */}
      <div className="px-5 py-5 border-b border-white/10 flex items-center gap-3">
        <span
          className="w-9 h-9 rounded-xl flex items-center justify-center font-black text-sm text-white"
          style={{ background: 'linear-gradient(135deg, #7248FE, #9075FF)' }}
        >
          P
        </span>
        <div>
          <div className="text-white font-extrabold text-sm leading-none">Prolance</div>
          <div className="text-primary-400 text-[10px] font-semibold tracking-widest uppercase mt-0.5">
            Admin Panel
          </div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 flex flex-col gap-0.5">
        {navItems.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || pathname.startsWith(href + '/');
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 ${
                active
                  ? 'bg-primary-500/15 text-primary-400 border-l-2 border-primary-500 pl-[10px]'
                  : 'text-white/50 hover:text-white hover:bg-white/5 border-l-2 border-transparent'
              }`}
            >
              <Icon size={16} className={active ? 'text-primary-400' : ''} />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="px-3 py-4 border-t border-white/10">
        <form action={adminLogout}>
          <button
            type="submit"
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-white/40 hover:text-red-400 hover:bg-red-500/10 transition-all duration-200 border-l-2 border-transparent"
          >
            <LogOut size={16} />
            Sign Out
          </button>
        </form>
      </div>
    </aside>
  );
}
