import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';
import { updateTicket } from './actions';

export const dynamic = 'force-dynamic';

const STATUS_OPTIONS = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];

export default async function TicketDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const sb = createServiceClient();

  const { data: ticket, error } = await sb
    .from('tickets')
    .select('*, profiles(full_name, email, avatar_url)')
    .eq('id', id)
    .single();

  if (error || !ticket) {
    return (
      <div className="p-8">
        <p className="text-red-400">Ticket bulunamadı.</p>
        <Link href="/tickets" className="text-amber-400 text-sm mt-2 block">
          ← Ticketlara Dön
        </Link>
      </div>
    );
  }

  const profile = ticket.profiles as Record<string, string> | null;

  return (
    <div className="p-8 max-w-3xl">
      <Link href="/tickets" className="text-slate-400 hover:text-white text-sm mb-6 block">
        ← Tüm Ticketlar
      </Link>

      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 mb-6">
        <div className="flex items-start justify-between gap-4 mb-4">
          <div>
            <h1 className="text-xl font-extrabold text-white mb-1">{ticket.subject}</h1>
            <div className="flex items-center gap-2 text-sm text-slate-400">
              <span>{profile?.full_name ?? '—'}</span>
              <span>·</span>
              <span>{profile?.email}</span>
              <span>·</span>
              <span>{new Date(ticket.created_at).toLocaleString('tr-TR')}</span>
            </div>
          </div>
          <span className="shrink-0 text-xs font-bold bg-amber-500/15 text-amber-400 border border-amber-500/30 px-2.5 py-1 rounded-full">
            {ticket.priority}
          </span>
        </div>

        {ticket.description && (
          <div className="bg-slate-800 rounded-xl p-4 text-slate-300 text-sm leading-relaxed whitespace-pre-wrap">
            {ticket.description}
          </div>
        )}
      </div>

      {/* Admin Update Form */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <h2 className="text-white font-bold mb-4">Admin İşlemi</h2>
        <form action={updateTicket} className="flex flex-col gap-4">
          <input type="hidden" name="ticket_id" value={ticket.id} />

          <div className="flex flex-col gap-1.5">
            <label className="text-slate-300 text-sm font-medium">Durum</label>
            <select
              name="status"
              defaultValue={ticket.status}
              className="bg-slate-800 border border-slate-700 text-white rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/40"
            >
              {STATUS_OPTIONS.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-slate-300 text-sm font-medium">Admin Notu</label>
            <textarea
              name="admin_notes"
              rows={4}
              defaultValue={ticket.admin_notes ?? ''}
              placeholder="Çözüm notu, inceleme sonucu..."
              className="bg-slate-800 border border-slate-700 text-white rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/40 resize-none placeholder:text-slate-500"
            />
          </div>

          <button
            type="submit"
            className="bg-amber-500 hover:bg-amber-400 text-slate-900 font-bold py-3 rounded-xl transition-colors"
          >
            Güncelle
          </button>
        </form>
      </div>
    </div>
  );
}
