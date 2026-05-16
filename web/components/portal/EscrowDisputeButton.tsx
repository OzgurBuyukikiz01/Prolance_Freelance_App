'use client';

import { useFormStatus } from 'react-dom';
import { openEscrowDispute } from '@/app/portal/jobs/[id]/actions';

type EscrowDisputeButtonProps = {
  escrowId: string;
  jobId: string;
};

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="text-sm font-semibold px-4 py-2 rounded-xl bg-red-600 hover:bg-red-700 disabled:opacity-60 text-white"
    >
      {pending ? 'Gönderiliyor…' : 'Anlaşmazlık aç'}
    </button>
  );
}

export function EscrowDisputeButton({ escrowId, jobId }: EscrowDisputeButtonProps) {
  return (
    <form action={openEscrowDispute} className="space-y-3 mt-3">
      <input type="hidden" name="escrow_id" value={escrowId} />
      <input type="hidden" name="job_id" value={jobId} />
      <div>
        <label htmlFor="dispute_reason" className="block text-sm font-medium text-slate-700 mb-1">
          Anlaşmazlık nedeni
        </label>
        <textarea
          id="dispute_reason"
          name="reason"
          rows={3}
          required
          minLength={10}
          placeholder="Sorunu kısaca açıklayın…"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm resize-y focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <SubmitButton />
    </form>
  );
}
