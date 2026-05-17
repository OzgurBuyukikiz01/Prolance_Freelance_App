import Link from 'next/link';
import { redirect } from 'next/navigation';
import { PortalHeroHeader } from '@/components/portal/PortalHeroHeader';
import { PortalHomeClient } from '@/components/portal/PortalHomeClient';
import type { JobListItem } from '@/components/portal/JobsListClient';
import { createClient } from '@/lib/supabase/server';
import { applyStatFloors, STAT_FLOORS } from '@/lib/landing-stats';
import { createServiceClient } from '@/lib/supabaseAdmin';
import { formatCents } from '@/lib/portal/format';

const ROLE_LABELS: Record<string, string> = {
  FREELANCER: 'Freelancer',
  CLIENT: 'İşveren',
};

const ROLE_COLORS: Record<string, string> = {
  FREELANCER: 'bg-white/20 text-white border-white/30',
  CLIENT: 'bg-emerald-400/20 text-emerald-50 border-emerald-200/40',
};

async function fetchPlatformStats() {
  try {
    const sb = createServiceClient();
    const [{ count: userCount }, { data: escrowRows }, { data: profileRows }] =
      await Promise.all([
        sb.from('profiles').select('*', { count: 'exact', head: true }),
        sb
          .from('escrow_transactions')
          .select('amount_cents')
          .in('status', ['FUNDED', 'HELD', 'RELEASED']),
        sb.from('profiles').select('completed_jobs'),
      ]);
    const completedSum = (profileRows ?? []).reduce(
      (sum, row) => sum + Number(row.completed_jobs ?? 0),
      0,
    );
    const escrowVolumeTry =
      (escrowRows ?? []).reduce((sum, row) => sum + Number(row.amount_cents ?? 0), 0) / 100;
    const floored = applyStatFloors({
      userCount: userCount ?? 0,
      jobCount: 0,
      escrowVolumeTry,
      avgRating: 4.9,
      reviewCount: STAT_FLOORS.reviewCount,
    });
    return {
      userCount: floored.userCount,
      escrowVolumeTry: floored.escrowVolumeTry,
      satisfactionPct: 98,
      completedJobs: Math.max(completedSum, 1400),
    };
  } catch {
    return {
      userCount: STAT_FLOORS.userCount,
      escrowVolumeTry: STAT_FLOORS.escrowVolumeTry,
      satisfactionPct: 98,
      completedJobs: 1400,
    };
  }
}

export default async function PortalPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const [{ data: profile }, { data: jobs, error: jobsError }, platformStats] = await Promise.all([
    supabase
      .from('profiles')
      .select('full_name, role, is_admin, avatar_url, earnings_available_cents')
      .eq('id', user.id)
      .single(),
    supabase
      .from('jobs')
      .select(
        'id, title, description, budget_min, budget_max, budget_type, skills, posted_date, proposal_count, client_name, category, status',
      )
      .eq('status', 'open')
      .order('posted_date', { ascending: false })
      .limit(10),
    fetchPlatformStats(),
  ]);

  const name = profile?.full_name || user.email?.split('@')[0] || 'Kullanıcı';
  const role = profile?.role ?? 'FREELANCER';
  const isAdmin = profile?.is_admin ?? false;
  const isFreelancer = role === 'FREELANCER';
  const earningsAvailableCents = (profile?.earnings_available_cents as number | null) ?? 0;

  // Sum pending balance from payout_pending proposals (freelancer only)
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
      <PortalHeroHeader
        name={name}
        roleLabel={ROLE_LABELS[role] ?? role}
        roleClassName={ROLE_COLORS[role] ?? 'bg-white/20 text-white border-white/30'}
        avatarUrl={profile?.avatar_url ?? null}
        isAdmin={isAdmin}
        platformStats={platformStats}
      />

      {isAdmin && (
        <Link
          href="/dashboard"
          className="mb-6 flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 py-3 text-sm font-bold text-white shadow-lg transition-all hover:from-amber-600 hover:to-orange-600"
        >
          Admin Panele Geç
        </Link>
      )}

      {/* Freelancer balance summary */}
      {isFreelancer && (pendingCents > 0 || earningsAvailableCents > 0) && (
        <div className="grid grid-cols-2 gap-3 mb-6 p-4 rounded-2xl bg-white/80 border border-slate-100 shadow-sm">
          <div>
            <p className="text-xs text-slate-400">Bekleyen Ödeme</p>
            <p className="text-base font-bold text-purple-700 mt-0.5">
              {formatCents(pendingCents)}
            </p>
          </div>
          <div>
            <p className="text-xs text-slate-400">Kullanılabilir Bakiye</p>
            <p className="text-base font-bold text-emerald-700 mt-0.5">
              {formatCents(earningsAvailableCents)}
            </p>
          </div>
        </div>
      )}

      {/* Contracts quick link */}
      <Link
        href="/portal/contracts"
        className="mb-6 flex items-center justify-between gap-2 rounded-2xl bg-indigo-600 hover:bg-indigo-700 px-5 py-3.5 text-sm font-semibold text-white transition-colors shadow-sm"
      >
        <span>Sözleşmelerim</span>
        <span className="opacity-70">→</span>
      </Link>

      {jobsError ? (
        <p className="rounded-xl border border-red-100 bg-red-50 p-4 text-sm text-red-600">
          İlanlar yüklenemedi: {jobsError.message}
        </p>
      ) : (
        <PortalHomeClient jobs={(jobs ?? []) as JobListItem[]} />
      )}
    </div>
  );
}
