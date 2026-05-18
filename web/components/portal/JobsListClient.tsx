'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { MagicCard } from '@/components/ui/magic-card';
import { formatBudget, formatRelativeTime, parseSkills } from '@/lib/portal/format';

export type JobListItem = {
  id: string;
  title: string;
  description: string;
  budget_min: number;
  budget_max: number;
  budget_type: string;
  skills: unknown;
  posted_date: string;
  proposal_count: number;
  client_name: string;
  category: string;
  status: string;
};

type JobsListClientProps = {
  jobs: JobListItem[];
  isClient: boolean;
};

export function JobsListClient({ jobs, isClient }: JobsListClientProps) {
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return jobs;
    return jobs.filter(
      (j) =>
        j.title.toLowerCase().includes(q) ||
        j.description.toLowerCase().includes(q) ||
        parseSkills(j.skills).some((s) => s.toLowerCase().includes(q)),
    );
  }, [jobs, query]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-display font-bold text-white">Job Board</h1>
        <p className="text-sm text-slate-500 mt-1">
          {isClient ? 'Manage your listings or post a new job.' : 'Browse open listings and submit proposals.'}
        </p>
      </div>

      <input
        type="search"
        placeholder="Search by title, description or skill…"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder:text-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
      />

      {filtered.length === 0 ? (
        <MagicCard innerClassName="p-8 text-center text-slate-500 text-sm">
          {jobs.length === 0 ? 'No open jobs yet.' : 'No jobs match your search.'}
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {filtered.map((job) => {
            const skills = parseSkills(job.skills).slice(0, 4);
            return (
              <li key={job.id}>
                <Link href={`/portal/jobs/${job.id}`}>
                  <MagicCard className="block hover:shadow-card-hover transition-shadow">
                    <div className="p-5">
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <h2 className="font-bold text-slate-900 truncate">{job.title}</h2>
                          <p className="text-xs text-slate-500 mt-0.5">
                            {job.client_name} · {formatRelativeTime(job.posted_date)}
                          </p>
                        </div>
                        <span className="text-sm font-bold text-brand whitespace-nowrap">
                          {formatBudget(job.budget_min, job.budget_max, job.budget_type)}
                        </span>
                      </div>
                      <p className="text-sm text-slate-400 mt-3 line-clamp-2">{job.description}</p>
                      {skills.length > 0 && (
                        <div className="flex flex-wrap gap-1.5 mt-3">
                          {skills.map((skill) => (
                            <span
                              key={skill}
                              className="text-[11px] font-medium px-2 py-0.5 rounded-md bg-white/8 text-slate-400"
                            >
                              {skill}
                            </span>
                          ))}
                        </div>
                      )}
                      <p className="text-xs text-slate-500 mt-3">
                        {job.proposal_count} {job.proposal_count === 1 ? 'proposal' : 'proposals'} · {job.category}
                      </p>
                    </div>
                  </MagicCard>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
