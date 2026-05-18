import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

const STATUS_COLORS: Record<string, string> = {
  OPEN: 'bg-primary-500/15 text-primary-400 border-primary-500/30',
  IN_PROGRESS: 'bg-indigo-500/15 text-indigo-400 border-indigo-500/30',
  RESOLVED: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
  CLOSED: 'bg-slate-700 text-slate-400 border-slate-600',
};

const PRIORITY_COLORS: Record<string, string> = {
  URGENT: 'bg-red-500/15 text-red-400 border-red-500/30',
  HIGH: 'bg-orange-500/15 text-orange-400 border-orange-500/30',
  NORMAL: 'bg-slate-700 text-slate-300 border-slate-600',
  LOW: 'bg-slate-800 text-slate-400 border-slate-700',
};

export default async function TicketsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string; priority?: string }>;
}) {
  const params = await searchParams;
  const sb = createServiceClient();

  let query = sb
    .from('tickets')
    .select(
      'id, subject, status, priority, created_at, profiles(full_name, email)',
      { count: 'exact' },
    )
    .order('created_at', { ascending: false })
    .limit(50);

  if (params.status) query = query.eq('status', params.status);
  if (params.priority) query = query.eq('priority', params.priority);

  const { data: tickets, error } = await query;

  return (
    <div className="p-8 max-w-5xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Support Tickets</h1>
          <p className="text-slate-400 text-sm mt-1">Support requests submitted by users</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex gap-2 flex-wrap mb-6">
        {['', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((s) => (
          <Link
            key={s}
            href={s ? `/tickets?status=${s}` : '/tickets'}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
              params.status === s || (!params.status && s === '')
                ? 'bg-primary-500/15 text-primary-400 border-primary-500/30'
                : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
            }`}
          >
            {s || 'All'}
          </Link>
        ))}
        <span className="text-slate-700 mx-1">|</span>
        {['', 'URGENT', 'HIGH', 'NORMAL', 'LOW'].map((p) => (
          <Link
            key={p}
            href={p ? `/tickets?priority=${p}` : '/tickets'}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
              params.priority === p || (!params.priority && p === '')
                ? 'bg-primary-500/15 text-primary-400 border-primary-500/30'
                : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
            }`}
          >
            {p || 'Priority'}
          </Link>
        ))}
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/30 text-red-400 px-4 py-3 rounded-xl text-sm mb-4">
          {error.message}
        </div>
      )}

      {/* Table */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-slate-800 text-slate-400 text-left">
              <th className="px-4 py-3 font-medium">Subject</th>
              <th className="px-4 py-3 font-medium">User</th>
              <th className="px-4 py-3 font-medium">Status</th>
              <th className="px-4 py-3 font-medium">Priority</th>
              <th className="px-4 py-3 font-medium">Date</th>
              <th className="px-4 py-3 font-medium"></th>
            </tr>
          </thead>
          <tbody>
            {(tickets ?? []).map((t: Record<string, unknown>) => {
              const profile = t.profiles as Record<string, string> | null;
              return (
                <tr
                  key={t.id as string}
                  className="border-b border-slate-800/50 hover:bg-slate-800/40 transition-colors"
                >
                  <td className="px-4 py-3 text-white font-medium truncate max-w-[200px]">
                    {t.subject as string}
                  </td>
                  <td className="px-4 py-3 text-slate-400">
                    {profile?.full_name ?? profile?.email ?? '—'}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`text-xs font-semibold px-2 py-1 rounded-full border ${
                        STATUS_COLORS[t.status as string] ?? ''
                      }`}
                    >
                      {t.status as string}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`text-xs font-semibold px-2 py-1 rounded-full border ${
                        PRIORITY_COLORS[t.priority as string] ?? ''
                      }`}
                    >
                      {t.priority as string}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {new Date(t.created_at as string).toLocaleDateString('en-US')}
                  </td>
                  <td className="px-4 py-3">
                    <Link
                      href={`/tickets/${t.id}`}
                      className="text-primary-400 hover:text-primary-300 text-xs font-semibold transition-colors"
                    >
                      View →
                    </Link>
                  </td>
                </tr>
              );
            })}
            {(tickets ?? []).length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500 text-sm">
                  No tickets found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
