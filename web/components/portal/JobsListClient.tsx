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
      (job) =>
        job.title.toLowerCase().includes(q) ||
        job.description.toLowerCase().includes(q) ||
        parseSkills(job.skills).some((skill) => skill.toLowerCase().includes(q)),
    );
  }, [jobs, query]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-display font-bold tracking-tight text-white">Job Board</h1>
        <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-400">
          {isClient
            ? 'Track your live listings, review incoming demand, and keep posted roles current.'
            : 'Browse active listings, compare budgets, and send proposals without leaving the portal.'}
        </p>
      </div>

      <div className="rounded-3xl border border-white/10 bg-white/[0.04] p-4 shadow-[0_18px_60px_rgba(15,23,42,0.22)]">
        <input
          type="search"
          placeholder="Search by title, description, or skill"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          className="w-full rounded-2xl border border-white/10 bg-slate-950/40 px-4 py-3 text-sm text-white placeholder:text-slate-500 focus:border-brand focus:outline-none focus:ring-2 focus:ring-brand/30"
        />
      </div>

      {filtered.length === 0 ? (
        <MagicCard innerClassName="p-8 text-center text-sm text-slate-400">
          {jobs.length === 0 ? 'No open jobs yet.' : 'No jobs match your search.'}
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {filtered.map((job) => {
            const skills = parseSkills(job.skills).slice(0, 4);
            return (
              <li key={job.id}>
                <Link href={`/portal/jobs/${job.id}`}>
                  <MagicCard className="block transition-transform duration-200 hover:-translate-y-0.5 hover:shadow-card-hover">
                    <div className="p-5">
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <h2 className="truncate text-lg font-bold text-white">{job.title}</h2>
                          <p className="mt-1 text-xs text-slate-400">
                            {job.client_name} · {formatRelativeTime(job.posted_date)}
                          </p>
                        </div>
                        <span className="whitespace-nowrap text-sm font-bold text-brand">
                          {formatBudget(job.budget_min, job.budget_max, job.budget_type)}
                        </span>
                      </div>
                      <p className="mt-3 line-clamp-2 text-sm leading-6 text-slate-300">
                        {job.description}
                      </p>
                      {skills.length > 0 && (
                        <div className="mt-3 flex flex-wrap gap-1.5">
                          {skills.map((skill) => (
                            <span
                              key={skill}
                              className="rounded-full border border-white/10 bg-white/[0.06] px-2.5 py-1 text-[11px] font-medium text-slate-300"
                            >
                              {skill}
                            </span>
                          ))}
                        </div>
                      )}
                      <div className="mt-4 flex items-center justify-between gap-3 text-xs text-slate-400">
                        <p>
                          {job.proposal_count} {job.proposal_count === 1 ? 'proposal' : 'proposals'} ·{' '}
                          {job.category}
                        </p>
                        <span className="font-medium text-slate-500">Open</span>
                      </div>
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
