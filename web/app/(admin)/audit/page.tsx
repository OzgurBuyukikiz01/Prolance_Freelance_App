import { createServiceClient } from '@/lib/supabaseAdmin';

export const dynamic = 'force-dynamic';

const ACTION_COLORS: Record<string, string> = {
  ticket_update: 'bg-primary-500/15 text-primary-400 border-primary-500/30',
  escrow_resolution: 'bg-indigo-500/15 text-indigo-400 border-indigo-500/30',
  user_banned: 'bg-red-500/15 text-red-400 border-red-500/30',
  user_unbanned: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
};

export default async function AuditPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string }>;
}) {
  const params = await searchParams;
  const page = Math.max(1, parseInt(params.page ?? '1', 10));
  const pageSize = 50;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const sb = createServiceClient();
  const { data: logs, count, error } = await sb
    .from('admin_audit_log')
    .select('*, admin:profiles!admin_audit_log_admin_id_fkey(full_name, email)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);

  const totalPages = Math.ceil((count ?? 0) / pageSize);

  return (
    <div className="p-8 max-w-5xl">
      <div className="mb-6">
        <h1 className="text-2xl font-extrabold text-white">Audit Log</h1>
        <p className="text-slate-400 text-sm mt-1">
          Tüm admin işlemleri — {count ?? 0} kayıt
        </p>
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
              <th className="px-4 py-3 font-medium">İşlem</th>
              <th className="px-4 py-3 font-medium">Admin</th>
              <th className="px-4 py-3 font-medium">Hedef ID</th>
              <th className="px-4 py-3 font-medium">Detay</th>
              <th className="px-4 py-3 font-medium">Tarih</th>
            </tr>
          </thead>
          <tbody>
            {(logs ?? []).map((l: Record<string, unknown>) => {
              const admin = l.admin as Record<string, string> | null;
              return (
                <tr
                  key={l.id as string}
                  className="border-b border-slate-800/50 hover:bg-slate-800/30 transition-colors"
                >
                  <td className="px-4 py-3">
                    <span
                      className={`text-xs font-semibold px-2 py-1 rounded-full border ${
                        ACTION_COLORS[l.action as string] ?? 'bg-slate-700 text-slate-300 border-slate-600'
                      }`}
                    >
                      {l.action as string}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-300 text-xs">
                    {admin?.full_name ?? admin?.email ?? (l.admin_id as string)?.slice(0, 8)}
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs font-mono">
                    {(l.entity_id as string)?.slice(0, 8)}…
                  </td>
                  <td className="px-4 py-3 text-slate-400 text-xs max-w-xs truncate">
                    {((l.details as Record<string, string>)?.detail) || '—'}
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs whitespace-nowrap">
                    {new Date(l.created_at as string).toLocaleString('tr-TR')}
                  </td>
                </tr>
              );
            })}
            {(logs ?? []).length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-8 text-center text-slate-500 text-sm">
                  Henüz audit logu yok.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-4">
          <p className="text-slate-500 text-xs">
            Sayfa {page} / {totalPages}
          </p>
          <div className="flex gap-2">
            {page > 1 && (
              <a
                href={`/audit?page=${page - 1}`}
                className="text-xs bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded-lg hover:text-white transition-colors"
              >
                ← Önceki
              </a>
            )}
            {page < totalPages && (
              <a
                href={`/audit?page=${page + 1}`}
                className="text-xs bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded-lg hover:text-white transition-colors"
              >
                Sonraki →
              </a>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
