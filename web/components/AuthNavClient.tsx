'use client';

import { useState, useTransition } from 'react';
import Link from 'next/link';
import { logout } from '@/app/login/actions';
import { ConfirmDialog } from '@/components/auth/ConfirmDialog';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';

type AuthNavClientProps = {
  name: string;
  isAdmin: boolean;
  avatarUrl: string | null;
};

export function AuthNavClient({ name, isAdmin, avatarUrl }: AuthNavClientProps) {
  const [logoutOpen, setLogoutOpen] = useState(false);
  const [pending, startTransition] = useTransition();
  const initial = name.charAt(0).toUpperCase();

  const handleLogout = () => {
    startTransition(async () => {
      await logout();
    });
  };

  return (
    <>
      <div className="flex items-center gap-2">
        {isAdmin && (
          <a
            href="/dashboard"
            className="hidden sm:inline-flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold px-3 py-1.5 rounded-lg transition-colors"
          >
            Admin Panel
          </a>
        )}
        <Link
          href="/portal"
          className="flex items-center gap-2 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-xl transition-colors"
        >
          <Avatar className="h-6 w-6">
            {avatarUrl ? <AvatarImage src={avatarUrl} alt={name} /> : null}
            <AvatarFallback className="bg-brand text-[10px] font-bold text-white">
              {initial}
            </AvatarFallback>
          </Avatar>
          <span className="text-sm font-medium text-slate-700 hidden sm:block max-w-[100px] truncate">
            {name}
          </span>
        </Link>
        <button
          type="button"
          onClick={() => setLogoutOpen(true)}
          className="p-2 rounded-xl text-slate-400 hover:text-red-500 hover:bg-red-50 transition-colors"
          title="Çıkış Yap"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
        </button>
      </div>

      <ConfirmDialog
        open={logoutOpen}
        onOpenChange={setLogoutOpen}
        title="Çıkış yapmak istediğinize emin misiniz?"
        description="Oturumunuz sonlandırılacak."
        confirmLabel="Çıkış Yap"
        cancelLabel="Vazgeç"
        onConfirm={handleLogout}
        loading={pending}
        variant="destructive"
      />
    </>
  );
}
