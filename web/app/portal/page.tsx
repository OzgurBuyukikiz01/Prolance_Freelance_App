import Link from 'next/link';
import { redirect } from 'next/navigation';
import { logout } from '@/app/login/actions';
import { createClient } from '@/lib/supabase/server';
import { MagicCard } from '@/components/ui/magic-card';
import { PortalStats } from '@/components/portal/PortalStats';
import { formatCents } from '@/lib/portal/format';

const ROLE_LABELS: Record<string, string> = {
  FREELANCER: 'Freelancer',
  CLIENT: 'Client',
};

const ROLE_COLORS: Record<string, string> = {
  FREELANCER: 'bg-indigo-500/10 text-indigo-300 border-indigo-500/20',
  CLIENT: 'bg-emerald-500/10 text-emerald-300 border-emerald-500/20',
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
    .select('full_name, role, is_admin, avatar_url, completed_jobs, rating, total_earnings, earnings_available_cents')
    .eq('id', user.id)
    .single();

  const name = profile?.full_name || user.email?.split('@')[0] || 'User';
  const role = profile?.role ?? 'FREELANCER';
  const isAdmin = profile?.is_admin ?? false;
  const isFreelancer = role === 'FREELANCER';
  const completedJobs = (profile?.completed_jobs as number | null) ?? 0;
  const rating = profile?.rating != null ? Number(profile.rating) : null;
  const totalEarnings = (profile?.total_earnings as number | null) ?? 0;
  const earningsAvailableCents = (profile?.earnings_available_cents as number | null) ?? 0;

  // Sum pending balance from payout_pending proposals
  let pendingCents = 0;
  if (isFreelancer) {
    const { data: pendingProposals } = await supabase
      .from('proposals')
      .select('freelancer_payout_cents, funded_amount_cents')
      .eq('freelancer_id', user.id)
      .eq('lifecycle_phase', 'payout_pending')
      .eq('payout_finalized', false);
    pendingCents = (pendingProposals ?? []).reduce(
      (acc, p) => acc + (p.freelancer_payout_cents ?? p.funded_amount_cents ?? 0),
      0,
    );
  }

  return (
    <div>
      <MagicCard innerClassName="p-8 mb-6">
        <div className="flex items-center gap-5 mb-6">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-brand to-indigo-500 flex items-center justify-center text-white text-2xl font-extrabold shadow-brand flex-shrink-0">
            {name.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-xl font-display font-bold text-white truncate">
                Welcome back, {name}!
              </h1>
              {isAdmin && (
                <span className="bg-amber-500/10 text-amber-300 border border-amber-500/20 text-xs font-bold px-2.5 py-1 rounded-full">
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

        {/* Freelancer balance summary */}
        {isFreelancer && (pendingCents > 0 || earningsAvailableCents > 0) && (
          <div className="grid grid-cols-2 gap-3 mb-4 p-4 rounded-xl bg-white/4 border border-white/8">
            <div>
              <p className="text-xs text-slate-500">Pending Payment</p>
              <p className="text-base font-bold text-violet-400 mt-0.5">
                {formatCents(pendingCents)}
              </p>
            </div>
            <div>
              <p className="text-xs text-slate-500">Available Balance</p>
              <p className="text-base font-bold text-emerald-400 mt-0.5">
                {formatCents(earningsAvailableCents)}
              </p>
            </div>
          </div>
        )}

        <div className="flex flex-col gap-3">
          {isAdmin && (
            <Link
              href="/dashboard"
              className="flex items-center justify-center gap-2.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-bold py-3.5 rounded-xl transition-all shadow-lg"
            >
              Go to Admin Panel
            </Link>
          )}
          <Link
            href="/portal/jobs"
            className="flex items-center justify-center gap-2 bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors"
          >
            Browse Jobs
          </Link>
          <Link
            href="/portal/contracts"
            className="flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            My Contracts
          </Link>
          <Link
            href="/portal/proposals"
            className="flex items-center justify-center gap-2 border border-white/10 hover:border-brand/40 hover:bg-brand/10 text-slate-300 font-medium py-3 rounded-xl transition-colors text-sm"
          >
            My Proposals
          </Link>
          <form action={logout}>
            <button
              type="submit"
              className="w-full flex items-center justify-center gap-2 border border-white/8 hover:border-red-500/30 hover:bg-red-500/10 hover:text-red-400 text-slate-500 font-medium py-3 rounded-xl transition-colors text-sm"
            >
              Sign Out
            </button>
          </form>
        </div>
      </MagicCard>
    </div>
  );
}
