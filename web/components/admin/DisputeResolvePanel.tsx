'use client';

import { useState } from 'react';
import { resolveDispute } from '@/app/(admin)/disputes/[id]/actions';
import { AdminModal } from '@/components/admin/ui/AdminModal';

type DisputeResolvePanelProps = {
  escrowId: string;
  proposalId: string | null;
  employerName: string;
  freelancerName: string;
};

export function DisputeResolvePanel({
  escrowId,
  proposalId,
  employerName,
  freelancerName,
}: DisputeResolvePanelProps) {
  const [resolution, setResolution] = useState<'release' | 'refund' | null>(null);
  const [note, setNote] = useState('');
  const [open, setOpen] = useState(false);
  const [pending, setPending] = useState(false);

  const noteValid = note.trim().length >= 20;
  const canConfirm = resolution !== null && noteValid;

  const winnerLabel =
    resolution === 'release'
      ? `Freelancer (${freelancerName})`
      : resolution === 'refund'
        ? `İşveren (${employerName})`
        : '—';

  return (
    <div className="space-y-6">
      {/* Selection cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {/* Freelancer wins */}
        <button
          type="button"
          onClick={() => setResolution('release')}
          className={`flex flex-col gap-2 p-5 rounded-2xl border-2 text-left transition-all ${
            resolution === 'release'
              ? 'border-emerald-500 bg-emerald-500/10'
              : 'border-slate-700 bg-slate-800 hover:border-slate-600'
          }`}
        >
          <div className="flex items-center gap-2">
            <span className="text-xl">✅</span>
            <span className="font-bold text-white text-sm">Freelancer Haklı</span>
            {resolution === 'release' && (
              <span className="ml-auto text-emerald-400 text-lg">●</span>
            )}
          </div>
          <p className="text-slate-400 text-xs leading-relaxed">
            Escrow tutarı <strong className="text-emerald-400">{freelancerName}</strong> adına serbest bırakılır.
          </p>
        </button>

        {/* Employer wins */}
        <button
          type="button"
          onClick={() => setResolution('refund')}
          className={`flex flex-col gap-2 p-5 rounded-2xl border-2 text-left transition-all ${
            resolution === 'refund'
              ? 'border-red-500 bg-red-500/10'
              : 'border-slate-700 bg-slate-800 hover:border-slate-600'
          }`}
        >
          <div className="flex items-center gap-2">
            <span className="text-xl">↩️</span>
            <span className="font-bold text-white text-sm">İşveren Haklı</span>
            {resolution === 'refund' && (
              <span className="ml-auto text-red-400 text-lg">●</span>
            )}
          </div>
          <p className="text-slate-400 text-xs leading-relaxed">
            Escrow tutarı <strong className="text-red-400">{employerName}</strong> adına iade edilir.
          </p>
        </button>
      </div>

      {/* Resolution note */}
      <div>
        <label className="block text-sm font-medium text-slate-300 mb-2">
          Karar Açıklaması <span className="text-red-400">*</span>
          <span className="ml-2 text-slate-600 font-normal text-xs">
            (min. 20 karakter — her iki taraf da görecektir)
          </span>
        </label>
        <textarea
          rows={4}
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="Neden bu kararı verdiniz? Konuşma ve teslimatları değerlendirerek açıklayın. Her iki taraf bu metni alacaktır."
          className="w-full rounded-xl bg-white/5 border border-white/10 focus:border-primary-500 focus:ring-1 focus:ring-primary-500/30 text-white text-sm placeholder:text-white/25 px-4 py-3 resize-none outline-none transition"
        />
        <p className={`text-xs mt-1 text-right ${noteValid ? 'text-emerald-500' : 'text-slate-600'}`}>
          {note.trim().length} / 20+ karakter
        </p>
      </div>

      {/* Confirm button */}
      <button
        type="button"
        disabled={!canConfirm}
        onClick={() => setOpen(true)}
        className={`w-full py-3 rounded-xl font-bold text-sm transition-all ${
          canConfirm
            ? resolution === 'release'
              ? 'bg-emerald-600 hover:bg-emerald-500 text-white'
              : 'bg-red-600 hover:bg-red-500 text-white'
            : 'bg-slate-800 text-slate-600 cursor-not-allowed'
        }`}
      >
        {canConfirm
          ? `Kararı Onayla → ${winnerLabel}`
          : !resolution
            ? 'Önce bir taraf seçin'
            : 'Açıklama gerekli (min. 20 karakter)'}
      </button>

      {/* Confirmation modal */}
      <AdminModal
        open={open}
        onOpenChange={(next) => {
          if (!pending) setOpen(next);
        }}
        title="Kararı Onayla"
        description={`Bu işlem geri alınamaz. "${winnerLabel}" lehine karar verilecek.`}
      >
        <div className="space-y-4">
          <div className="bg-slate-800 rounded-xl px-4 py-3 text-slate-300 text-sm">
            <p className="text-xs text-slate-500 mb-1">Açıklama</p>
            {note}
          </div>
          <form
            action={async (fd) => {
              setPending(true);
              try {
                await resolveDispute(fd);
              } finally {
                setPending(false);
                setOpen(false);
                setResolution(null);
                setNote('');
              }
            }}
            className="flex gap-2 justify-end"
          >
            <input type="hidden" name="escrow_id" value={escrowId} />
            <input type="hidden" name="proposal_id" value={proposalId ?? ''} />
            <input type="hidden" name="resolution" value={resolution ?? ''} />
            <input type="hidden" name="resolution_note" value={note} />
            <button
              type="button"
              disabled={pending}
              onClick={() => setOpen(false)}
              className="px-4 py-2 rounded-lg text-slate-400 text-sm hover:text-white disabled:opacity-50"
            >
              İptal
            </button>
            <button
              type="submit"
              disabled={pending}
              className="px-5 py-2 rounded-lg text-white font-bold text-sm disabled:opacity-40 hover:opacity-90 transition-all"
              style={{ background: 'linear-gradient(135deg, #7248FE, #9075FF)' }}
            >
              {pending ? 'Kaydediliyor…' : 'Evet, Onayla'}
            </button>
          </form>
        </div>
      </AdminModal>
    </div>
  );
}
