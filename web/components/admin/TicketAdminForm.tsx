'use client';

import { useState } from 'react';
import { updateTicket } from '@/app/(admin)/tickets/[id]/actions';
import { AdminModal } from '@/components/admin/ui/AdminModal';

const STATUS_OPTIONS = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];

type TicketAdminFormProps = {
  ticketId: string;
  defaultStatus: string;
  defaultNotes: string;
};

export function TicketAdminForm({
  ticketId,
  defaultStatus,
  defaultNotes,
}: TicketAdminFormProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="bg-amber-500 hover:bg-amber-400 text-slate-900 font-bold py-3 px-5 rounded-xl transition-colors"
      >
        Durumu güncelle
      </button>

      <AdminModal
        open={open}
        onOpenChange={setOpen}
        title="Ticket güncelle"
        description="Durum ve admin notunu kaydedin."
      >
        <form
          action={async (fd) => {
            await updateTicket(fd);
            setOpen(false);
          }}
          className="flex flex-col gap-4"
        >
          <input type="hidden" name="ticket_id" value={ticketId} />

          <div className="flex flex-col gap-1.5">
            <label className="text-slate-300 text-sm font-medium">Durum</label>
            <select
              name="status"
              defaultValue={defaultStatus}
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
              defaultValue={defaultNotes}
              placeholder="Çözüm notu, inceleme sonucu..."
              className="bg-slate-800 border border-slate-700 text-white rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/40 resize-none placeholder:text-slate-500"
            />
          </div>

          <div className="flex gap-2 justify-end">
            <button
              type="button"
              onClick={() => setOpen(false)}
              className="px-4 py-2 rounded-lg text-slate-400 text-sm hover:text-white"
            >
              İptal
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-400 text-slate-900 font-bold text-sm"
            >
              Kaydet
            </button>
          </div>
        </form>
      </AdminModal>
    </>
  );
}
