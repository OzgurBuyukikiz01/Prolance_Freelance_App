'use client';

import { useFormStatus } from 'react-dom';
import { submitProposal } from '@/app/portal/jobs/[id]/actions';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full bg-brand hover:bg-brand-dark disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
    >
      {pending ? 'Submitting…' : 'Submit Proposal'}
    </button>
  );
}

type ProposalFormProps = {
  jobId: string;
  defaultBid?: number;
};

export function ProposalForm({ jobId, defaultBid }: ProposalFormProps) {
  return (
    <form action={submitProposal} className="space-y-4">
      <input type="hidden" name="job_id" value={jobId} />
      <div>
        <label htmlFor="bid" className="block text-sm font-medium text-slate-300 mb-1">
          Bid Amount ($)
        </label>
        <input
          id="bid"
          name="bid"
          type="number"
          min={1}
          step={1}
          required
          defaultValue={defaultBid}
          className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <div>
        <label htmlFor="delivery_days" className="block text-sm font-medium text-slate-300 mb-1">
          Delivery Time (days)
        </label>
        <input
          id="delivery_days"
          name="delivery_days"
          type="number"
          min={1}
          required
          defaultValue={14}
          className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <div>
        <label htmlFor="cover_letter" className="block text-sm font-medium text-slate-300 mb-1">
          Cover Letter
        </label>
        <textarea
          id="cover_letter"
          name="cover_letter"
          rows={5}
          required
          minLength={10}
          placeholder="Tell us why you're the best fit for this job…"
          className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm resize-y focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <SubmitButton />
    </form>
  );
}
