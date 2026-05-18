import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<{ banned?: string; role?: string; q?: string }>;
}) {
  const params = await searchParams;
  const sb = createServiceClient();

  let query = sb
    .from('profiles')
    .select('id, full_name, email, role, is_admin, is_banned, created_at, completed_jobs, rating')
    .order('created_at', { ascending: false })
    .limit(60);

  if (params.banned === '1') query = query.eq('is_banned', true);
  if (params.role) query = query.eq('role', params.role);

  const { data: users, error } = await query;

  const filtered = params.q
    ? (users ?? []).filter(
        (u: Record<string, unknown>) =>
          (u.full_name as string)?.toLowerCase().includes(params.q!.toLowerCase()) ||
          (u.email as string)?.toLowerCase().includes(params.q!.toLowerCase()),
      )
    : (users ?? []);

  return (
    <div className="p-8 max-w-5xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Users</h1>
          <p className="text-slate-400 text-sm mt-1">Manage platform users</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex gap-2 flex-wrap mb-6 items-center">
        <Link
          href="/users"
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
            !params.banned && !params.role
              ? 'bg-primary-500/15 text-primary-400 border-primary-500/30'
              : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
          }`}
        >
          All
        </Link>
        <Link
          href="/users?banned=1"
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
            params.banned === '1'
              ? 'bg-red-500/15 text-red-400 border-red-500/30'
              : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
          }`}
        >
          Banned
        </Link>
        <Link
          href="/users?role=FREELANCER"
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
            params.role === 'FREELANCER'
              ? 'bg-indigo-500/15 text-indigo-400 border-indigo-500/30'
              : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
          }`}
        >
          Freelancer
        </Link>
        <Link
          href="/users?role=CLIENT"
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-colors ${
            params.role === 'CLIENT'
              ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
              : 'bg-slate-800 text-slate-400 border-slate-700 hover:text-white'
          }`}
        >
          Client
        </Link>

        <form className="ml-auto">
          <input
            name="q"
            type="search"
            defaultValue={params.q}
            placeholder="Search name or email..."
            className="bg-slate-800 border border-slate-700 text-white text-sm rounded-xl px-4 py-1.5 w-56 focus:outline-none focus:ring-2 focus:ring-primary-500/40 placeholder:text-slate-500"
          />
        </form>
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/30 text-red-400 px-4 py-3 rounded-xl text-sm mb-4">
          {error.message}
        </div>
      )}

      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-slate-800 text-slate-400 text-left">
              <th className="px-4 py-3 font-medium">User</th>
              <th className="px-4 py-3 font-medium">Role</th>
              <th className="px-4 py-3 font-medium">Jobs</th>
              <th className="px-4 py-3 font-medium">Status</th>
              <th className="px-4 py-3 font-medium">Joined</th>
              <th className="px-4 py-3 font-medium"></th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((u: Record<string, unknown>) => (
              <tr
                key={u.id as string}
                className="border-b border-slate-800/50 hover:bg-slate-800/40 transition-colors"
              >
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                      {(u.full_name as string)?.charAt(0)?.toUpperCase() ?? '?'}
                    </div>
                    <div>
                      <div className="text-white font-medium text-xs leading-none mb-0.5">
                        {(u.full_name as string) || '—'}
                        {Boolean(u.is_admin) && (
                          <span className="ml-1.5 text-[10px] bg-primary-500/15 text-primary-400 border border-primary-500/30 px-1.5 py-0.5 rounded-full font-bold">
                            Admin
                          </span>
                        )}
                      </div>
                      <div className="text-slate-500 text-[11px]">{u.email as string}</div>
                    </div>
                  </div>
                </td>
                <td className="px-4 py-3 text-slate-300 text-xs">{u.role as string}</td>
                <td className="px-4 py-3 text-slate-400 text-xs">{u.completed_jobs as number}</td>
                <td className="px-4 py-3">
                  {u.is_banned ? (
                    <span className="text-xs font-semibold px-2 py-1 rounded-full border bg-red-500/15 text-red-400 border-red-500/30">
                      Banned
                    </span>
                  ) : (
                    <span className="text-xs font-semibold px-2 py-1 rounded-full border bg-emerald-500/15 text-emerald-400 border-emerald-500/30">
                      Active
                    </span>
                  )}
                </td>
                <td className="px-4 py-3 text-slate-500 text-xs">
                  {new Date(u.created_at as string).toLocaleDateString('en-US')}
                </td>
                <td className="px-4 py-3">
                  <Link
                    href={`/users/${u.id}`}
                    className="text-primary-400 hover:text-primary-300 text-xs font-semibold transition-colors"
                  >
                    Details →
                  </Link>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500 text-sm">
                  No users found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
