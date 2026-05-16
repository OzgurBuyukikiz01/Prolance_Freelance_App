'use client';

import { useFormStatus } from 'react-dom';
import { createJobListing } from '@/app/portal/jobs/new/actions';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full bg-brand hover:bg-brand-dark disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
    >
      {pending ? 'Yayınlanıyor…' : 'İlanı Gönder'}
    </button>
  );
}

const fieldClass =
  'w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand';

export function PostJobForm() {
  return (
    <form action={createJobListing} className="space-y-4">
      <TitleField />
      <CategoryField />
      <DescriptionField />
      <BudgetFields />
      <input type="hidden" name="budget_type" value="fixed" />
      <input type="hidden" name="duration" value="1-3 months" />
      <input type="hidden" name="experience_level" value="Intermediate" />
      <SkillsField />
      <p className="text-xs text-slate-500">
        İlanınız moderasyon kuyruğuna alınır; onaylandığında yayına girer.
      </p>
      <SubmitButton />
    </form>
  );
}

function TitleField() {
  return (
    <div>
      <label htmlFor="title" className="block text-sm font-medium text-slate-700 mb-1">
        Başlık
      </label>
      <input id="title" name="title" required minLength={5} className={fieldClass} />
    </div>
  );
}

function CategoryField() {
  return (
    <div>
      <label htmlFor="category" className="block text-sm font-medium text-slate-700 mb-1">
        Kategori
      </label>
      <input id="category" name="category" defaultValue="Genel" className={fieldClass} />
    </div>
  );
}

function DescriptionField() {
  return (
    <div>
      <label htmlFor="description" className="block text-sm font-medium text-slate-700 mb-1">
        Açıklama
      </label>
      <textarea
        id="description"
        name="description"
        rows={6}
        required
        minLength={20}
        className={`${fieldClass} resize-y`}
      />
    </div>
  );
}

function BudgetFields() {
  return (
    <div className="grid grid-cols-2 gap-3">
      <div>
        <label htmlFor="budget_min" className="block text-sm font-medium text-slate-700 mb-1">
          Min bütçe (₺)
        </label>
        <input
          id="budget_min"
          name="budget_min"
          type="number"
          min={1}
          required
          defaultValue={5000}
          className={fieldClass}
        />
      </div>
      <div>
        <label htmlFor="budget_max" className="block text-sm font-medium text-slate-700 mb-1">
          Max bütçe (₺)
        </label>
        <input
          id="budget_max"
          name="budget_max"
          type="number"
          min={1}
          required
          defaultValue={15000}
          className={fieldClass}
        />
      </div>
    </div>
  );
}

function SkillsField() {
  return (
    <div>
      <label htmlFor="skills" className="block text-sm font-medium text-slate-700 mb-1">
        Beceriler (virgülle ayırın)
      </label>
      <input
        id="skills"
        name="skills"
        placeholder="React, TypeScript, UI"
        className={fieldClass}
      />
    </div>
  );
}
