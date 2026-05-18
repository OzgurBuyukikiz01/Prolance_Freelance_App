import { createClient } from '@/lib/supabase/server';
import { logout } from '@/app/login/actions';

function LoginLink() {
  return (
    <a
      href="/login"
      className="inline-flex items-center gap-1.5 bg-brand hover:bg-brand-dark text-white text-sm font-semibold px-4 py-2 rounded-xl transition-colors shadow-brand"
    >
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
      </svg>
      Sign In
    </a>
  );
}

export default async function AuthNav() {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return <LoginLink />;
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('full_name, is_admin')
      .eq('id', user.id)
      .single();

    const name = profile?.full_name || user.email?.split('@')[0] || 'User';
    const initial = name.charAt(0).toUpperCase();

    return (
      <div className="flex items-center gap-2">
        {profile?.is_admin && (
          <a
            href="/dashboard"
            className="hidden sm:inline-flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold px-3 py-1.5 rounded-lg transition-colors"
          >
            Admin Panel
          </a>
        )}
        <a
          href="/portal"
          className="flex items-center gap-2 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-xl transition-colors"
        >
          <div className="w-6 h-6 rounded-lg bg-brand flex items-center justify-center text-white text-[11px] font-bold">
            {initial}
          </div>
          <span className="text-sm font-medium text-slate-700 hidden sm:block max-w-[100px] truncate">
            {name}
          </span>
        </a>
        <form action={logout}>
          <button
            type="submit"
            className="p-2 rounded-xl text-slate-400 hover:text-red-500 hover:bg-red-50 transition-colors"
            title="Sign Out"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </form>
      </div>
    );
  } catch (error) {
    console.error('[AuthNav] Supabase unavailable:', error);
    return <LoginLink />;
  }
}
