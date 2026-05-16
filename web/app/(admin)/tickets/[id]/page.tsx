import { createServiceClient } from '@/lib/supabaseAdmin';
import Link from 'next/link';
import { TicketAdminForm } from '@/components/admin/TicketAdminForm';

export const dynamic = 'force-dynamic';

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

      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <h2 className="text-white font-bold mb-4">Admin İşlemi</h2>
        <TicketAdminForm
          ticketId={ticket.id as string}
          defaultStatus={ticket.status as string}
          defaultNotes={(ticket.admin_notes as string) ?? ''}
        />
      </div>
    </div>
  );
}
