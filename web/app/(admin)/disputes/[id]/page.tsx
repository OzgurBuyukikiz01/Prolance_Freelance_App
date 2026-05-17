import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';
import { DisputeResolvePanel } from '@/components/admin/DisputeResolvePanel';

export const dynamic = 'force-dynamic';

type Message = {
  id: string;
  sender_id: string;
  body: string | null;
  attachment_url: string | null;
  attachment_type: string | null;
  created_at: string;
  sender: { full_name: string | null } | null;
};

type Delivery = {
  id: string;
  file_name: string;
  storage_path: string | null;
  created_at: string;
};

function formatTime(iso: string) {
  return new Date(iso).toLocaleString('tr-TR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

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

  // Proposal details
  let proposalDisputeNote: string | null = null;
  if (escrow.proposal_id) {
    const { data: proposal } = await sb
      .from('proposals')
      .select('dispute_note')
      .eq('id', escrow.proposal_id)
      .single();
    proposalDisputeNote = proposal?.dispute_note ?? null;
  }

  // Delivery files
  let deliveries: Delivery[] = [];
  if (escrow.proposal_id) {
    const { data } = await sb
      .from('proposal_deliveries')
      .select('id, file_name, storage_path, created_at')
      .eq('proposal_id', escrow.proposal_id)
      .order('created_at', { ascending: true });
    deliveries = (data ?? []) as Delivery[];
  }

  // Conversation between the two parties
  let messages: Message[] = [];
  if (escrow.employer_id && escrow.freelancer_id) {
    const { data: conv } = await sb
      .from('conversations')
      .select('id')
      .contains('participant_ids', [escrow.employer_id, escrow.freelancer_id])
      .maybeSingle();

    if (conv?.id) {
      const { data: msgs } = await sb
        .from('messages')
        .select('id, sender_id, body, attachment_url, attachment_type, created_at, sender:profiles!messages_sender_id_fkey(full_name)')
        .eq('conversation_id', conv.id)
        .order('created_at', { ascending: true })
        .limit(100);
      messages = (msgs ?? []) as unknown as Message[];
    }
  }

  return (
    <div className="p-8 max-w-4xl space-y-6">
      <Link href="/disputes" className="text-slate-400 hover:text-white text-sm block">
        ← Tüm Anlaşmazlıklar
      </Link>

      {/* ── Parties & Amount ── */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-extrabold text-white">Escrow Kaydı</h1>
          <span
            className={`text-xs font-bold px-2.5 py-1 rounded-full border ${
              isDisputed
                ? 'bg-red-500/15 text-red-400 border-red-500/30'
                : escrow.status === 'RELEASED'
                  ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
                  : 'bg-slate-700 text-slate-300 border-slate-600'
            }`}
          >
            {escrow.status}
          </span>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <div className="text-xs text-slate-500 mb-1">İşveren (Client)</div>
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
              ₺{((escrow.amount_cents as number) / 100).toLocaleString('tr-TR', { minimumFractionDigits: 2 })}
            </div>
          </div>
          <div>
            <div className="text-xs text-slate-500 mb-1">Oluşturulma</div>
            <div className="text-white text-sm">{formatTime(escrow.created_at)}</div>
          </div>
        </div>

        {/* Dispute reason */}
        {(escrow.dispute_reason || proposalDisputeNote) && (
          <div>
            <div className="text-xs text-slate-500 mb-1">İtiraz Sebebi</div>
            <div className="bg-red-950/40 border border-red-500/20 rounded-xl px-4 py-3 text-red-300 text-sm">
              {escrow.dispute_reason || proposalDisputeNote}
            </div>
          </div>
        )}
      </div>

      {/* ── Delivery Files ── */}
      {deliveries.length > 0 && (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
          <h2 className="text-white font-bold mb-4">Freelancer Teslimatları</h2>
          <div className="space-y-2">
            {deliveries.map((d) => (
              <div
                key={d.id}
                className="flex items-center gap-3 bg-slate-800 rounded-xl px-4 py-3"
              >
                <span className="text-lg">📦</span>
                <div className="flex-1 min-w-0">
                  <p className="text-white text-sm font-medium truncate">{d.file_name}</p>
                  <p className="text-slate-500 text-xs">{formatTime(d.created_at)}</p>
                </div>
                {d.storage_path && d.storage_path !== 'demo://no-file' && (
                  <a
                    href={d.storage_path}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-amber-400 text-xs hover:underline shrink-0"
                  >
                    Görüntüle →
                  </a>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── Conversation Timeline ── */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <h2 className="text-white font-bold mb-4">
          Taraflar Arası Konuşma
          {messages.length > 0 && (
            <span className="ml-2 text-xs text-slate-500 font-normal">({messages.length} mesaj)</span>
          )}
        </h2>

        {messages.length === 0 ? (
          <p className="text-slate-500 text-sm">Bu taraflar arasında mesajlaşma kaydı bulunamadı.</p>
        ) : (
          <div className="space-y-3 max-h-[480px] overflow-y-auto pr-1">
            {messages.map((msg) => {
              const isEmployer = msg.sender_id === escrow.employer_id;
              return (
                <div
                  key={msg.id}
                  className={`flex gap-3 ${isEmployer ? 'flex-row' : 'flex-row-reverse'}`}
                >
                  {/* Avatar */}
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 text-xs font-bold ${
                      isEmployer
                        ? 'bg-blue-500/20 text-blue-400'
                        : 'bg-emerald-500/20 text-emerald-400'
                    }`}
                  >
                    {isEmployer ? 'C' : 'F'}
                  </div>

                  <div className={`flex flex-col gap-1 max-w-[70%] ${isEmployer ? 'items-start' : 'items-end'}`}>
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-slate-500">
                        {msg.sender?.full_name ?? (isEmployer ? employer?.full_name : freelancer?.full_name) ?? '—'}
                      </span>
                      <span className="text-xs text-slate-600">{formatTime(msg.created_at)}</span>
                    </div>

                    {msg.body && (
                      <div
                        className={`rounded-2xl px-4 py-2.5 text-sm ${
                          isEmployer
                            ? 'bg-slate-800 text-slate-200 rounded-tl-sm'
                            : 'bg-slate-700 text-slate-200 rounded-tr-sm'
                        }`}
                      >
                        {msg.body}
                      </div>
                    )}

                    {msg.attachment_url && (
                      <a
                        href={msg.attachment_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-medium ${
                          isEmployer
                            ? 'bg-blue-500/10 text-blue-400 hover:bg-blue-500/20'
                            : 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20'
                        }`}
                      >
                        <span>
                          {msg.attachment_type === 'image' ? '🖼️' : '📎'}
                        </span>
                        Ek Dosya Görüntüle
                      </a>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* ── Decision ── */}
      {isDisputed ? (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
          <h2 className="text-white font-bold mb-1">Admin Kararı</h2>
          <p className="text-slate-400 text-sm mb-5">
            Yukarıdaki konuşma ve teslimatları inceleyin, ardından haklı tarafı seçin ve kararınızı yazın.
            <span className="text-red-400"> Bu işlem geri alınamaz.</span>
          </p>
          <DisputeResolvePanel
            escrowId={escrow.id as string}
            proposalId={escrow.proposal_id as string | null}
            employerName={employer?.full_name ?? 'İşveren'}
            freelancerName={freelancer?.full_name ?? 'Freelancer'}
          />
        </div>
      ) : (
        <div className="bg-slate-800/50 border border-slate-700 rounded-2xl p-5 space-y-2">
          <p className="text-slate-400 text-sm">
            Bu anlaşmazlık çözümlendi: <strong className="text-white">{escrow.status}</strong>
            {escrow.resolved_at && (
              <span className="ml-2 text-slate-500 text-xs">{formatTime(escrow.resolved_at)}</span>
            )}
          </p>
          {escrow.resolution_note && (
            <div className="mt-2 bg-slate-900 rounded-xl px-4 py-3">
              <p className="text-xs text-slate-500 mb-1">Admin Açıklaması</p>
              <p className="text-slate-200 text-sm">{escrow.resolution_note}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
