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
      date: d.toLocaleDateString('tr-TR', { weekday: 'short', day: 'numeric' }),
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
    <div className="p-8 max-w-6xl bg-slate-950 min-h-full">
      <div className="mb-8">
        <h1 className="text-2xl font-extrabold text-white">Dashboard</h1>
        <p className="text-slate-400 text-sm mt-1">Platform genel durumu</p>
      </div>

      {err && (
        <div className="mb-6 bg-amber-500/10 border border-amber-500/30 text-amber-400 text-sm px-4 py-3 rounded-xl">
          Metrikler yüklenemedi: {err}. .env.local dosyasını kontrol edin.
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        <DashboardStatCard
          title="Toplam İlan"
          value={metrics.totalJobs}
          sub={`${metrics.openJobs} aktif`}
          href="/jobs"
        />
        <DashboardStatCard
          title="Bekleyen İlan"
          value={metrics.pendingJobs}
          sub="Moderasyon bekliyor"
          href="/jobs"
          accent={metrics.pendingJobs > 0 ? 'text-amber-400' : 'text-white'}
        />
        <DashboardStatCard
          title="Açık Ticketlar"
          value={metrics.openTickets}
          sub="Yanıt bekliyor"
          href="/tickets"
          accent="text-[#6C63FF]"
        />
        <DashboardStatCard
          title="Toplam Kullanıcı"
          value={metrics.totalUsers}
          sub={`${metrics.bannedUsers} banlı`}
          href="/users"
          accent="text-indigo-300"
        />
      </div>

      <div className="mb-10">
        <SignupChart data={signupChart} />
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-3 gap-4 mb-10">
        <DashboardStatCard
          title="Escrow Anlaşmazlık"
          value={metrics.disputed}
          sub="DISPUTED durumunda"
          href="/disputes"
          accent={metrics.disputed > 0 ? 'text-red-400' : 'text-slate-400'}
        />
        <DashboardStatCard
          title="Banlı Kullanıcı"
          value={metrics.bannedUsers}
          href="/users"
          accent={metrics.bannedUsers > 0 ? 'text-red-400' : 'text-slate-400'}
        />
        <DashboardStatCard
          title="Audit Log Girişi"
          value={metrics.recentAudit}
          href="/audit"
          accent="text-[#6C63FF]"
        />
      </div>

      <div>
        <h2 className="text-slate-300 text-sm font-semibold mb-4 uppercase tracking-wider">
          Hızlı Erişim
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { href: '/jobs', label: 'İlan Moderasyonu' },
            { href: '/tickets', label: 'Ticketları Yönet' },
            { href: '/disputes', label: 'Anlaşmazlıklar' },
            { href: '/users', label: 'Kullanıcılar' },
            { href: '/audit', label: 'Audit Log' },
          ].map((q) => (
            <Link
              key={q.href}
              href={q.href}
              className="bg-slate-900 hover:bg-slate-800 border border-slate-800 hover:border-[#6C63FF]/40 rounded-xl px-4 py-3 text-sm font-medium text-slate-300 hover:text-white transition-colors text-center"
            >
              {q.label}
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
