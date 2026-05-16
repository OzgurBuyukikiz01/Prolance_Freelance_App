import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

interface MetricCardProps {
  title: string;
  value: number | string;
  sub?: string;
  href?: string;
  accent?: string;
}

function MetricCard({ title, value, sub, href, accent = 'text-white' }: MetricCardProps) {
  const inner = (
    <div className="rounded-2xl border border-slate-800 bg-slate-900 p-6 hover:border-slate-700 transition-colors">
      <div className="text-sm text-slate-400 mb-2">{title}</div>
      <div className={`text-4xl font-extrabold ${accent}`}>{value}</div>
      {sub && <div className="text-xs text-slate-500 mt-1.5">{sub}</div>}
    </div>
  );
  return href ? <Link href={href}>{inner}</Link> : inner;
}

export default async function DashboardPage() {
  let metrics = {
    totalJobs: 0,
    openJobs: 0,
    disputed: 0,
    openTickets: 0,
    totalUsers: 0,
    bannedUsers: 0,
    recentAudit: 0,
  };
  let err: string | null = null;

  try {
    const sb = createServiceClient();
    const [
      { count: totalJobs },
      { count: openJobs },
      { count: disputed },
      { count: openTickets },
      { count: totalUsers },
      { count: bannedUsers },
      { count: recentAudit },
    ] = await Promise.all([
      sb.from('jobs').select('*', { count: 'exact', head: true }),
      sb.from('jobs').select('*', { count: 'exact', head: true }).eq('status', 'open'),
      sb
        .from('escrow_transactions')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'DISPUTED'),
      sb.from('tickets').select('*', { count: 'exact', head: true }).eq('status', 'OPEN'),
      sb.from('profiles').select('*', { count: 'exact', head: true }),
      sb.from('profiles').select('*', { count: 'exact', head: true }).eq('is_banned', true),
      sb.from('admin_audit_log').select('*', { count: 'exact', head: true }),
    ]);
    metrics = {
      totalJobs: totalJobs ?? 0,
      openJobs: openJobs ?? 0,
      disputed: disputed ?? 0,
      openTickets: openTickets ?? 0,
      totalUsers: totalUsers ?? 0,
      bannedUsers: bannedUsers ?? 0,
      recentAudit: recentAudit ?? 0,
    };
  } catch (e) {
    err = `${e}`;
  }

  return (
    <div className="p-8 max-w-5xl">
      <div className="mb-8">
        <h1 className="text-2xl font-extrabold text-white">Dashboard</h1>
        <p className="text-slate-400 text-sm mt-1">Platform genel durumu</p>
      </div>

      {err && (
        <div className="mb-6 bg-amber-500/10 border border-amber-500/30 text-amber-400 text-sm px-4 py-3 rounded-xl">
          Metrikler yüklenemedi: {err}. .env.local dosyasını kontrol edin.
        </div>
      )}

      <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
        <MetricCard
          title="Toplam İlan"
          value={metrics.totalJobs}
          sub={`${metrics.openJobs} aktif`}
          href="/dashboard"
        />
        <MetricCard
          title="Açık Ticketlar"
          value={metrics.openTickets}
          sub="Yanıt bekliyor"
          href="/tickets"
          accent="text-amber-400"
        />
        <MetricCard
          title="Escrow Anlaşmazlık"
          value={metrics.disputed}
          sub="DISPUTED durumunda"
          href="/disputes"
          accent={metrics.disputed > 0 ? 'text-red-400' : 'text-white'}
        />
        <MetricCard
          title="Toplam Kullanıcı"
          value={metrics.totalUsers}
          sub={`${metrics.bannedUsers} banlı`}
          href="/users"
        />
        <MetricCard
          title="Banlı Kullanıcı"
          value={metrics.bannedUsers}
          href="/users"
          accent={metrics.bannedUsers > 0 ? 'text-red-400' : 'text-slate-400'}
        />
        <MetricCard
          title="Audit Log Girişi"
          value={metrics.recentAudit}
          href="/audit"
          accent="text-indigo-400"
        />
      </div>

      {/* Quick links */}
      <div className="mt-10">
        <h2 className="text-slate-300 text-sm font-semibold mb-4 uppercase tracking-wider">Hızlı Erişim</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { href: '/tickets', label: 'Ticketları Yönet', color: 'amber' },
            { href: '/disputes', label: 'Anlaşmazlıklar', color: 'red' },
            { href: '/users', label: 'Kullanıcılar', color: 'indigo' },
            { href: '/audit', label: 'Audit Log', color: 'slate' },
          ].map((q) => (
            <Link
              key={q.href}
              href={q.href}
              className="bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-xl px-4 py-3 text-sm font-medium text-slate-300 hover:text-white transition-colors text-center"
            >
              {q.label}
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
