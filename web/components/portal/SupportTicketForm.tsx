'use client';

import { useFormStatus } from 'react-dom';
import { createSupportTicket } from '@/app/portal/support/actions';

const PRIORITIES = [
  { value: 'LOW', label: 'Düşük' },
  { value: 'NORMAL', label: 'Normal' },
  { value: 'HIGH', label: 'Yüksek' },
  { value: 'URGENT', label: 'Acil' },
] as const;

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full bg-brand hover:bg-brand-dark disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
    >
      {pending ? 'Gönderiliyor…' : 'Talebi Gönder'}
    </button>
  );
}

export function SupportTicketForm() {
  return (
    <form action={createSupportTicket} className="space-y-4">
      <div className="rounded-xl border border-brand/20 bg-brand/5 px-4 py-3 text-sm text-brand">
        Ekibimiz genellikle 24 saat içinde yanıt verir.
      </div>
      <div>
        <label htmlFor="subject" className="block text-sm font-medium text-slate-700 mb-1">
          Konu
        </label>
        <input
          id="subject"
          name="subject"
          required
          minLength={5}
          placeholder="Konuyu kısaca açıklayın"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <div>
        <label htmlFor="priority" className="block text-sm font-medium text-slate-700 mb-1">
          Öncelik
        </label>
        <select
          id="priority"
          name="priority"
          defaultValue="NORMAL"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        >
          {PRIORITIES.map((p) => (
            <option key={p.value} value={p.value}>
              {p.label}
            </option>
          ))}
        </select>
      </div>
      <div>
        <label htmlFor="body" className="block text-sm font-medium text-slate-700 mb-1">
          Açıklama
        </label>
        <textarea
          id="body"
          name="body"
          rows={6}
          required
          minLength={20}
          placeholder="Sorununuzu veya önerinizi detaylıca açıklayın…"
          className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm resize-y focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
        />
      </div>
      <SubmitButton />
    </form>
  );
}
