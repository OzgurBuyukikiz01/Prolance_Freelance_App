import { createServiceClient } from '@/lib/supabaseAdmin';
import { DashboardStatCard } from '@/components/dashboard/DashboardStatCard';
import { SignupChart, type SignupChartPoint } from '@/components/dashboard/SignupChart';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

function buildSignupSeries(
  profiles: { created_at: string }[] | null | undefined,
): SignupChartPoint[] {
  const buckets = new Map<string, number>();

  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() - i);
    buckets.set(d.toISOString().slice(0, 10), 0);
  }

  for (const profile of profiles ?? []) {
    const key = new Date(profile.created_at).toISOString().slice(0, 10);
    if (buckets.has(key)) {
      buckets.set(key, (buckets.get(key) ?? 0) + 1);
    }
  }

  return Array.from(buckets.entries()).map(([iso, signups]) => {
    const d = new Date(`${iso}T12:00:00`);
    return {
      date: d.toLocaleDateString('en-US', { weekday: 'short', day: 'numeric' }),
      signups,
    };
  });
}

export default async function DashboardPage() {
  let metrics = {
    totalJobs: 0,
    openJobs: 0,
    pendingJobs: 0,
    disputed: 0,
    openTickets: 0,
    totalUsers: 0,
    bannedUsers: 0,
    recentAudit: 0,
  };
  let signupChart: SignupChartPoint[] = buildSignupSeries([]);
  let err: string | null = null;

  try {
    const sb = createServiceClient();
    const since = new Date();
    since.setDate(since.getDate() - 6);
    since.setHours(0, 0, 0, 0);

    const [
      { count: totalJobs },
      { count: openJobs },
      { count: pendingJobs },
      { count: disputed },
      { count: openTickets },
      { count: totalUsers },
      { count: bannedUsers },
      { count: recentAudit },
      { data: recentProfiles },
    ] = await Promise.all([
      sb.from('jobs').select('*', { count: 'exact', head: true }),
      sb.from('jobs').select('*', { count: 'exact', head: true }).eq('status', 'open'),
      sb
        .from('jobs')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending_review'),
      sb
        .from('escrow_transactions')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'DISPUTED'),
      sb.from('tickets').select('*', { count: 'exact', head: true }).eq('status', 'OPEN'),
      sb.from('profiles').select('*', { count: 'exact', head: true }),
      sb.from('profiles').select('*', { count: 'exact', head: true }).eq('is_banned', true),
      sb.from('admin_audit_log').select('*', { count: 'exact', head: true }),
      sb.from('profiles').select('created_at').gte('created_at', since.toISOString()),
    ]);
    metrics = {
      totalJobs: totalJobs ?? 0,
      openJobs: openJobs ?? 0,
      pendingJobs: pendingJobs ?? 0,
      disputed: disputed ?? 0,
      openTickets: openTickets ?? 0,
      totalUsers: totalUsers ?? 0,
      bannedUsers: bannedUsers ?? 0,
      recentAudit: recentAudit ?? 0,
    };
    signupChart = buildSignupSeries(recentProfiles);
  } catch (e) {
    err = `${e}`;
  }

  return (
    <div className="p-8 max-w-7xl min-h-full">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-gradient-brand">Dashboard</h1>
        <p className="text-white/40 text-sm mt-1.5">Platform overview</p>
      </div>

      {err && (
        <div className="mb-6 bg-primary-500/10 border border-primary-500/30 text-primary-300 text-sm px-4 py-3 rounded-xl">
          Failed to load metrics: {err}. Check your .env.local file.
        </div>
      )}

      {/* Primary stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-4">
        <DashboardStatCard
          title="Total Jobs"
          value={metrics.totalJobs}
          sub={`${metrics.openJobs} active`}
          href="/jobs"
          accent="text-white"
        />
        <DashboardStatCard
          title="Pending Jobs"
          value={metrics.pendingJobs}
          sub="Awaiting moderation"
          href="/jobs"
          accent={metrics.pendingJobs > 0 ? 'text-primary-400' : 'text-white'}
        />
        <DashboardStatCard
          title="Open Tickets"
          value={metrics.openTickets}
          sub="Awaiting response"
          href="/tickets"
          accent="text-accent-400"
        />
        <DashboardStatCard
          title="Total Users"
          value={metrics.totalUsers}
          sub={`${metrics.bannedUsers} banned`}
          href="/users"
          accent="text-secondary-400"
        />
      </div>

      {/* Secondary stats */}
      <div className="grid grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        <DashboardStatCard
          title="Escrow Disputes"
          value={metrics.disputed}
          sub="In DISPUTED status"
          href="/disputes"
          accent={metrics.disputed > 0 ? 'text-red-400' : 'text-white/40'}
        />
        <DashboardStatCard
          title="Banned Users"
          value={metrics.bannedUsers}
          href="/users"
          accent={metrics.bannedUsers > 0 ? 'text-red-400' : 'text-white/40'}
        />
        <DashboardStatCard
          title="Audit Log Entries"
          value={metrics.recentAudit}
          href="/audit"
          accent="text-accent-400"
        />
      </div>

      {/* Signup chart */}
      <div className="mb-8">
        <SignupChart data={signupChart} />
      </div>

      {/* Quick access */}
      <div>
        <h2 className="text-white/40 text-xs font-semibold mb-3 uppercase tracking-widest">
          Quick Access
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
          {[
            { href: '/jobs',     label: 'Job Moderation' },
            { href: '/tickets',  label: 'Manage Tickets' },
            { href: '/disputes', label: 'Disputes' },
            { href: '/users',    label: 'Users' },
            { href: '/audit',    label: 'Audit Log' },
          ].map((q) => (
            <Link
              key={q.href}
              href={q.href}
              className="glass-card px-4 py-3 text-sm font-medium text-white/50 hover:text-white hover:bg-white/[0.07] transition-all duration-200 text-center rounded-xl"
            >
              {q.label}
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
