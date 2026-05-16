'use client';

import { useFormStatus } from 'react-dom';
import { submitReview } from '@/app/portal/reviews/new/actions';

type SubmitReviewFormProps = {
  jobId: string;
  revieweeId: string;
  revieweeName: string;
};

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full bg-brand hover:bg-brand-dark disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
    >
      {pending ? 'Gönderiliyor…' : 'Değerlendirmeyi Gönder'}
    </button>
  );
}

export function SubmitReviewForm({ jobId, revieweeId, revieweeName }: SubmitReviewFormProps) {
  return (
    <form action={submitReview} className="space-y-4">
      <input type="hidden" name="job_id" value={jobId} />
      <input type="hidden" name="reviewee_id" value={revieweeId} />
      <p className="text-sm text-slate-600">
        <span className="font-semibold text-slate-900">{revieweeName}</span> için değerlendirme
        yazıyorsunuz.
      </p>
      <div>
        <label htmlFor="rating" className="block text-sm font-medium text-slate-700 mb-1">
          Puan (1–5)
        </label>
        <select
          id="rating"
          name="rating"
          required
          defaultValue="5"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        >
          {[5, 4, 3, 2, 1].map((n) => (
            <option key={n} value={n}>
              {n} yıldız
            </option>
          ))}
        </select>
      </div>
      <div>
        <label htmlFor="comment" className="block text-sm font-medium text-slate-700 mb-1">
          Yorum
        </label>
        <textarea
          id="comment"
          name="comment"
          rows={5}
          required
          minLength={10}
          placeholder="Deneyiminizi paylaşın…"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm resize-y focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <SubmitButton />
    </form>
  );
}
