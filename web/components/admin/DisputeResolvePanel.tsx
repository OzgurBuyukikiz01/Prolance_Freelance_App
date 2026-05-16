'use client';

import { useState } from 'react';
import { resolveDispute } from '@/app/(admin)/disputes/[id]/actions';
import { AdminModal } from '@/components/admin/ui/AdminModal';

type DisputeResolvePanelProps = {
  escrowId: string;
};

export function DisputeResolvePanel({ escrowId }: DisputeResolvePanelProps) {
  const [open, setOpen] = useState(false);
  const [resolution, setResolution] = useState<'release' | 'refund' | null>(null);

  const title =
    resolution === 'release'
      ? 'Freelancer\'a serbest bırak'
      : resolution === 'refund'
        ? 'İşverene iade et'
        : 'Karar onayı';

  return (
    <>
      <div className="flex gap-3">
        <button
          type="button"
          onClick={() => {
            setResolution('release');
            setOpen(true);
          }}
          className="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-bold py-3 rounded-xl transition-colors"
        >
          Freelancer&apos;a Serbest Bırak
        </button>
        <button
          type="button"
          onClick={() => {
            setResolution('refund');
            setOpen(true);
          }}
          className="flex-1 bg-red-600 hover:bg-red-500 text-white font-bold py-3 rounded-xl transition-colors"
        >
          İşverene İade Et
        </button>
      </div>

      <AdminModal
        open={open}
        onOpenChange={(next) => {
          setOpen(next);
          if (!next) setResolution(null);
        }}
        title={title}
        description="Bu işlem geri alınamaz. Onaylıyor musunuz?"
      >
        {resolution ? (
          <form
            action={async (fd) => {
              await resolveDispute(fd);
              setOpen(false);
              setResolution(null);
            }}
            className="flex flex-col gap-3"
          >
            <input type="hidden" name="escrow_id" value={escrowId} />
            <input type="hidden" name="resolution" value={resolution} />
            <div className="flex gap-2 justify-end">
              <button
                type="button"
                onClick={() => {
                  setOpen(false);
                  setResolution(null);
                }}
                className="px-4 py-2 rounded-lg text-slate-400 text-sm hover:text-white"
              >
                İptal
              </button>
              <button
                type="submit"
                className="px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-400 text-slate-900 font-bold text-sm"
              >
                Onayla
              </button>
            </div>
          </form>
        ) : null}
      </AdminModal>
    </>
  );
}
