import Link from 'next/link';
import { redirect } from 'next/navigation';
import { logout } from '@/app/login/actions';
import { createClient } from '@/lib/supabase/server';
import { MagicCard } from '@/components/ui/magic-card';
import { PortalStats } from '@/components/portal/PortalStats';

const ROLE_LABELS: Record<string, string> = {
  FREELANCER: 'Freelancer',
  CLIENT: 'İşveren',
};

const ROLE_COLORS: Record<string, string> = {
  FREELANCER: 'bg-indigo-50 text-indigo-700 border-indigo-100',
  CLIENT: 'bg-emerald-50 text-emerald-700 border-emerald-100',
};

export default async function PortalPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, role, is_admin, avatar_url, completed_jobs, rating, total_earnings')
    .eq('id', user.id)
    .single();

  const name = profile?.full_name || user.email?.split('@')[0] || 'Kullanıcı';
  const role = profile?.role ?? 'FREELANCER';
  const isAdmin = profile?.is_admin ?? false;
  const completedJobs = (profile?.completed_jobs as number | null) ?? 0;
  const rating = profile?.rating != null ? Number(profile.rating) : null;
  const totalEarnings = (profile?.total_earnings as number | null) ?? 0;

  return (
    <div>
      <MagicCard innerClassName="p-8 mb-6">
        <div className="flex items-center gap-5 mb-6">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-brand to-indigo-500 flex items-center justify-center text-white text-2xl font-extrabold shadow-brand flex-shrink-0">
            {name.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-xl font-extrabold text-slate-900 truncate">
                Hoş geldin, {name}!
              </h1>
              {isAdmin && (
                <span className="bg-amber-50 text-amber-700 border border-amber-200 text-xs font-bold px-2.5 py-1 rounded-full">
                  Admin
                </span>
              )}
            </div>
            <div className="flex items-center gap-2 mt-1.5 flex-wrap">
              <span
                className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${
                  ROLE_COLORS[role] ?? 'bg-slate-50 text-slate-600 border-slate-100'
                }`}
              >
                {ROLE_LABELS[role] ?? role}
              </span>
              <span className="text-xs text-slate-400">{user.email}</span>
            </div>
          </div>
        </div>

        <PortalStats
          completedJobs={completedJobs}
          rating={rating}
          totalEarnings={totalEarnings}
        />

        <div className="flex flex-col gap-3">
          {isAdmin && (
            <Link
              href="/dashboard"
              className="flex items-center justify-center gap-2.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-bold py-3.5 rounded-xl transition-all shadow-lg"
            >
              Admin Panele Geç
            </Link>
          )}
          <Link
            href="/portal/jobs"
            className="flex items-center justify-center gap-2 bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors"
          >
            İş İlanlarına Göz At
          </Link>
          <Link
            href="/portal/proposals"
            className="flex items-center justify-center gap-2 border border-slate-200 hover:border-brand/40 hover:bg-brand-light text-slate-700 font-medium py-3 rounded-xl transition-colors text-sm"
          >
            Tekliflerim
          </Link>
          <form action={logout}>
            <button
              type="submit"
              className="w-full flex items-center justify-center gap-2 border border-slate-200 hover:border-red-200 hover:bg-red-50 hover:text-red-600 text-slate-600 font-medium py-3 rounded-xl transition-colors text-sm"
            >
              Çıkış Yap
            </button>
          </form>
        </div>
      </MagicCard>
    </div>
  );
}
