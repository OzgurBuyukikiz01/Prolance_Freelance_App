import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';
import { toggleBan } from './actions';

export const dynamic = 'force-dynamic';

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const sb = createServiceClient();

  const [{ data: profile }, { data: jobs }, { data: tickets }] = await Promise.all([
    sb
      .from('profiles')
      .select('*')
      .eq('id', id)
      .single(),
    sb
      .from('jobs')
      .select('id, title, status, created_at')
      .eq('client_id', id)
      .order('created_at', { ascending: false })
      .limit(10),
    sb
      .from('tickets')
      .select('id, subject, status, priority, created_at')
      .eq('user_id', id)
      .order('created_at', { ascending: false })
      .limit(10),
  ]);

  if (!profile) {
    return (
      <div className="p-8">
        <p className="text-red-400">Kullanıcı bulunamadı.</p>
        <Link href="/users" className="text-amber-400 text-sm mt-2 block">← Kullanıcılara Dön</Link>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-3xl space-y-6">
      <Link href="/users" className="text-slate-400 hover:text-white text-sm block">
        ← Tüm Kullanıcılar
      </Link>

      {/* Profile card */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <div className="flex items-start gap-5">
          <div className="w-16 h-16 rounded-2xl bg-indigo-600 flex items-center justify-center text-white text-2xl font-extrabold flex-shrink-0">
            {profile.full_name?.charAt(0)?.toUpperCase() ?? '?'}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap mb-1">
              <h1 className="text-xl font-extrabold text-white">{profile.full_name || '—'}</h1>
              {profile.is_admin && (
                <span className="bg-amber-500/15 text-amber-400 border border-amber-500/30 text-xs font-bold px-2 py-0.5 rounded-full">
                  Admin
                </span>
              )}
              {profile.is_banned && (
                <span className="bg-red-500/15 text-red-400 border border-red-500/30 text-xs font-bold px-2 py-0.5 rounded-full">
                  Banlı
                </span>
              )}
            </div>
            <div className="text-slate-400 text-sm">{profile.email}</div>
            <div className="flex items-center gap-4 mt-3 text-sm text-slate-400">
              <span>{profile.role}</span>
              <span>·</span>
              <span>{profile.completed_jobs} iş</span>
              <span>·</span>
              <span>{profile.rating ? `${Number(profile.rating).toFixed(1)}★` : '—'}</span>
            </div>
          </div>
        </div>

        {/* Ban/Unban */}
        {!profile.is_admin && (
          <div className="mt-5 pt-5 border-t border-slate-800">
            <form action={toggleBan} className="inline-block">
              <input type="hidden" name="user_id" value={profile.id} />
              <input type="hidden" name="action" value={profile.is_banned ? 'unban' : 'ban'} />
              <button
                type="submit"
                className={`font-bold text-sm px-5 py-2.5 rounded-xl transition-colors ${
                  profile.is_banned
                    ? 'bg-emerald-600 hover:bg-emerald-500 text-white'
                    : 'bg-red-600 hover:bg-red-500 text-white'
                }`}
              >
                {profile.is_banned ? 'Banı Kaldır' : 'Kullanıcıyı Banla'}
              </button>
            </form>
          </div>
        )}
      </div>

      {/* Jobs */}
      {(jobs ?? []).length > 0 && (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
          <h2 className="text-white font-bold mb-4">İş İlanları ({(jobs ?? []).length})</h2>
          <div className="flex flex-col gap-2">
            {(jobs ?? []).map((j: Record<string, unknown>) => (
              <div key={j.id as string} className="flex items-center justify-between py-2 border-b border-slate-800 last:border-0">
                <span className="text-slate-300 text-sm truncate max-w-sm">{j.title as string}</span>
                <span className="text-slate-500 text-xs ml-4 shrink-0">{j.status as string}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tickets */}
      {(tickets ?? []).length > 0 && (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
          <h2 className="text-white font-bold mb-4">Ticketlar ({(tickets ?? []).length})</h2>
          <div className="flex flex-col gap-2">
            {(tickets ?? []).map((t: Record<string, unknown>) => (
              <div key={t.id as string} className="flex items-center justify-between py-2 border-b border-slate-800 last:border-0">
                <Link href={`/tickets/${t.id}`} className="text-amber-400 text-sm hover:underline truncate max-w-sm">
                  {t.subject as string}
                </Link>
                <span className="text-slate-500 text-xs ml-4 shrink-0">{t.status as string}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
