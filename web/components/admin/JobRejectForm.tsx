'use client';

import { useState } from 'react';
import { rejectJob } from '@/app/(admin)/jobs/[id]/actions';
import { AdminModal } from '@/components/admin/ui/AdminModal';

export function JobRejectForm({ jobId }: { jobId: string }) {
  const [open, setOpen] = useState(false);
  const [reason, setReason] = useState('');

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="text-red-400 hover:text-red-300 text-xs font-semibold transition-colors"
      >
        Reject
      </button>

      <AdminModal
        open={open}
        onOpenChange={setOpen}
        title="Reject Job"
        description="Provide a reason. The client will be notified."
      >
        <form
          action={async (fd) => {
            await rejectJob(fd);
            setOpen(false);
            setReason('');
          }}
          className="flex flex-col gap-3"
        >
          <input type="hidden" name="job_id" value={jobId} />
          <textarea
            name="rejection_reason"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Rejection reason (required)"
            required
            rows={3}
            className="w-full rounded-lg bg-slate-800 border border-slate-700 text-white text-sm px-3 py-2 resize-none"
          />
          <div className="flex gap-2 justify-end">
            <button
              type="button"
              onClick={() => {
                setOpen(false);
                setReason('');
              }}
              className="px-4 py-2 rounded-lg text-slate-400 text-sm hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-lg bg-red-500/20 text-red-400 border border-red-500/30 text-sm font-semibold hover:bg-red-500/30"
            >
              Reject
            </button>
          </div>
        </form>
      </AdminModal>
    </>
  );
}
