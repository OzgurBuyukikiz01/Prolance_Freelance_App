import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';
import { DisputeResolvePanel } from '@/components/admin/DisputeResolvePanel';

export const dynamic = 'force-dynamic';

export default async function DisputeDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const sb = createServiceClient();

  const { data: escrow, error } = await sb
    .from('escrow_transactions')
    .select(
      `*, 
       employer:profiles!escrow_transactions_employer_id_fkey(full_name, email),
       freelancer:profiles!escrow_transactions_freelancer_id_fkey(full_name, email)`,
    )
    .eq('id', id)
    .single();

  if (error || !escrow) {
    return (
      <div className="p-8">
        <p className="text-red-400">Kayıt bulunamadı.</p>
        <Link href="/disputes" className="text-amber-400 text-sm mt-2 block">
          ← Anlaşmazlıklara Dön
        </Link>
      </div>
    );
  }

  const employer = escrow.employer as Record<string, string> | null;
  const freelancer = escrow.freelancer as Record<string, string> | null;
  const isDisputed = escrow.status === 'DISPUTED';

  return (
    <div className="p-8 max-w-2xl">
      <Link href="/disputes" className="text-slate-400 hover:text-white text-sm mb-6 block">
        ← Tüm Anlaşmazlıklar
      </Link>

      {/* Info card */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 mb-6 space-y-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-extrabold text-white">Escrow Kaydı</h1>
          <span
            className={`text-xs font-bold px-2.5 py-1 rounded-full border ${
              isDisputed
                ? 'bg-red-500/15 text-red-400 border-red-500/30'
                : 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
            }`}
          >
            {escrow.status}
          </span>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <div className="text-xs text-slate-500 mb-1">İşveren</div>
            <div className="text-white font-medium">{employer?.full_name ?? '—'}</div>
            <div className="text-slate-400 text-xs">{employer?.email}</div>
          </div>
          <div>
            <div className="text-xs text-slate-500 mb-1">Freelancer</div>
            <div className="text-white font-medium">{freelancer?.full_name ?? '—'}</div>
            <div className="text-slate-400 text-xs">{freelancer?.email}</div>
          </div>
          <div>
            <div className="text-xs text-slate-500 mb-1">Tutar</div>
            <div className="text-2xl font-extrabold text-white">
              ₺{(escrow.amount as number).toLocaleString()}
            </div>
          </div>
          <div>
            <div className="text-xs text-slate-500 mb-1">Oluşturulma</div>
            <div className="text-white text-sm">
              {new Date(escrow.created_at).toLocaleString('tr-TR')}
            </div>
          </div>
        </div>

        {escrow.dispute_reason && (
          <div>
            <div className="text-xs text-slate-500 mb-1">Anlaşmazlık Sebebi</div>
            <div className="bg-slate-800 rounded-xl px-4 py-3 text-slate-300 text-sm">
              {escrow.dispute_reason}
            </div>
          </div>
        )}
      </div>

      {/* Decision */}
      {isDisputed ? (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
          <h2 className="text-white font-bold mb-2">Admin Kararı</h2>
          <p className="text-slate-400 text-sm mb-5">
            Parayı kime göndereceğinize karar verin. Bu işlem geri alınamaz.
          </p>
          <DisputeResolvePanel escrowId={escrow.id as string} />
        </div>
      ) : (
        <div className="bg-slate-800/50 border border-slate-700 rounded-2xl p-5 text-slate-400 text-sm">
          Bu anlaşmazlık zaten çözümlendi: <strong className="text-white">{escrow.status}</strong>
        </div>
      )}
    </div>
  );
}
