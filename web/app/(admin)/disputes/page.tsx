import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

const STATUS_COLORS: Record<string, string> = {
  FUNDED: 'bg-blue-500/15 text-blue-400 border-blue-500/30',
  HELD: 'bg-indigo-500/15 text-indigo-400 border-indigo-500/30',
  RELEASED: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
  DISPUTED: 'bg-red-500/15 text-red-400 border-red-500/30',
  REFUNDED: 'bg-slate-700 text-slate-300 border-slate-600',
};

export default async function DisputesPage() {
  const sb = createServiceClient();

  const { data: disputes, error } = await sb
    .from('escrow_transactions')
    .select(
      `id, amount, status, dispute_reason, created_at,
       employer:profiles!escrow_transactions_employer_id_fkey(full_name, email),
       freelancer:profiles!escrow_transactions_freelancer_id_fkey(full_name, email)`,
    )
    .order('created_at', { ascending: false })
    .limit(100);

  return (
    <div className="p-8 max-w-5xl">
      <div className="mb-6">
        <h1 className="text-2xl font-extrabold text-white">Escrow Disputes</h1>
        <p className="text-slate-400 text-sm mt-1">
          Transactions in DISPUTED status and all escrow records
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
              <th className="px-4 py-3 font-medium">Client</th>
              <th className="px-4 py-3 font-medium">Freelancer</th>
              <th className="px-4 py-3 font-medium">Amount</th>
              <th className="px-4 py-3 font-medium">Status</th>
              <th className="px-4 py-3 font-medium">Date</th>
              <th className="px-4 py-3 font-medium"></th>
            </tr>
          </thead>
          <tbody>
            {(disputes ?? []).map((d: Record<string, unknown>) => {
              const employer = d.employer as Record<string, string> | null;
              const freelancer = d.freelancer as Record<string, string> | null;
              return (
                <tr
                  key={d.id as string}
                  className="border-b border-slate-800/50 hover:bg-slate-800/40 transition-colors"
                >
                  <td className="px-4 py-3 text-slate-300">
                    {employer?.full_name ?? employer?.email ?? '—'}
                  </td>
                  <td className="px-4 py-3 text-slate-300">
                    {freelancer?.full_name ?? freelancer?.email ?? '—'}
                  </td>
                  <td className="px-4 py-3 text-white font-semibold">
                    ₺{(d.amount as number).toLocaleString()}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`text-xs font-semibold px-2 py-1 rounded-full border ${
                        STATUS_COLORS[d.status as string] ?? ''
                      }`}
                    >
                      {d.status as string}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {new Date(d.created_at as string).toLocaleDateString('en-US')}
                  </td>
                  <td className="px-4 py-3">
                    <Link
                      href={`/disputes/${d.id}`}
                      className="text-primary-400 hover:text-primary-300 text-xs font-semibold transition-colors"
                    >
                      Resolve →
                    </Link>
                  </td>
                </tr>
              );
            })}
            {(disputes ?? []).length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500 text-sm">
                  No records found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
