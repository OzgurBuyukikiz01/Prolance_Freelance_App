'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { JobCardPortal } from '@/components/portal/JobCardPortal';
import type { JobListItem } from '@/components/portal/JobsListClient';
import { parseSkills } from '@/lib/portal/format';

const SKILL_CHIPS = ['React', 'TypeScript', 'Node.js', 'UI/UX', 'Flutter', 'Python'];

type PortalHomeClientProps = {
  jobs: JobListItem[];
};

export function PortalHomeClient({ jobs }: PortalHomeClientProps) {
  const [query, setQuery] = useState('');
  const [skill, setSkill] = useState<string | null>(null);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return jobs.filter((j) => {
      const skills = parseSkills(j.skills);
      const matchesSkill = !skill || skills.some((s) => s.toLowerCase().includes(skill.toLowerCase()));
      if (!q) return matchesSkill;
      return (
        matchesSkill &&
        (j.title.toLowerCase().includes(q) ||
          j.description.toLowerCase().includes(q) ||
          skills.some((s) => s.toLowerCase().includes(q)))
      );
    });
  }, [jobs, query, skill]);

  const recommended = filtered.slice(0, 4);
  const recent = filtered.slice(0, 6);

  return (
    <div className="space-y-8">
      <div className="space-y-3">
        <input
          type="search"
          placeholder="İlan, beceri veya anahtar kelime ara…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 placeholder:text-slate-400 focus:border-brand focus:outline-none focus:ring-2 focus:ring-brand/25"
        />
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setSkill(null)}
            className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
              skill === null
                ? 'bg-brand text-white'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            Tümü
          </button>
          {SKILL_CHIPS.map((chip) => (
            <button
              key={chip}
              type="button"
              onClick={() => setSkill(chip === skill ? null : chip)}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
                skill === chip
                  ? 'bg-brand text-white'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              {chip}
            </button>
          ))}
        </div>
      </div>

      <section>
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-extrabold text-slate-900">Önerilen İlanlar</h2>
          <Link href="/portal/jobs" className="text-sm font-medium text-brand hover:underline">
            Tümünü gör
          </Link>
        </div>
        {recommended.length === 0 ? (
          <p className="text-sm text-slate-500">Eşleşen önerilen ilan yok.</p>
        ) : (
          <div className="-mx-1 flex gap-4 overflow-x-auto pb-2 snap-x snap-mandatory px-1">
            {recommended.map((job) => (
              <JobCardPortal key={job.id} job={job} variant="horizontal" />
            ))}
          </div>
        )}
      </section>

      <section>
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-extrabold text-slate-900">Son İlanlar</h2>
          <Link href="/portal/jobs" className="text-sm font-medium text-brand hover:underline">
            Tümünü gör
          </Link>
        </div>
        {recent.length === 0 ? (
          <p className="text-sm text-slate-500">Henüz açık ilan bulunmuyor.</p>
        ) : (
          <ul className="space-y-4">
            {recent.map((job) => (
              <li key={job.id}>
                <JobCardPortal job={job} variant="vertical" />
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
