import type { ReactNode } from 'react';

export type LegalSection = {
  id: string;
  title: string;
  body: string[];
};

type LegalSectionsProps = {
  sections: LegalSection[];
  intro?: ReactNode;
  highlight?: ReactNode;
  footer?: ReactNode;
};

export default function LegalSections({
  sections,
  intro,
  highlight,
  footer,
}: LegalSectionsProps) {
  return (
    <div className="prose prose-slate max-w-none">
      {intro}

      {highlight}

      <nav className="mb-12 p-6 bg-slate-50 rounded-2xl border border-slate-100">
        <p className="font-semibold text-slate-700 mb-3 text-sm uppercase tracking-wide">
          İçindekiler
        </p>
        <ul className="space-y-2">
          {sections.map((s) => (
            <li key={s.id}>
              <a
                href={`#${s.id}`}
                className="text-indigo-600 hover:text-indigo-800 text-sm font-medium transition-colors"
              >
                {s.title}
              </a>
            </li>
          ))}
        </ul>
      </nav>

      {sections.map((s) => (
        <section key={s.id} id={s.id} className="mb-12 scroll-mt-8">
          <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
            {s.title}
          </h2>
          <div className="space-y-4">
            {s.body.map((para, i) => (
              <p key={i} className="text-slate-600 leading-relaxed text-[15px]">
                {para}
              </p>
            ))}
          </div>
        </section>
      ))}

      {footer}
    </div>
  );
}
