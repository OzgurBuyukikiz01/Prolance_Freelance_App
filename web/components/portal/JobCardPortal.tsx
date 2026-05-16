import Link from 'next/link';
import { MagicCard } from '@/components/ui/magic-card';
import { formatBudget, formatRelativeTime, parseSkills } from '@/lib/portal/format';
import type { JobListItem } from '@/components/portal/JobsListClient';

type JobCardPortalProps = {
  job: JobListItem;
  variant?: 'horizontal' | 'vertical';
};

function JobCardBody({ job, compact }: { job: JobListItem; compact?: boolean }) {
  const skills = parseSkills(job.skills).slice(0, compact ? 2 : 4);

  return (
    <div className={compact ? 'p-4' : 'p-5'}>
      <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
          <h3 className={`font-bold text-slate-900 truncate ${compact ? 'text-sm' : 'text-base'}`}>
            {job.title}
          </h3>
          <p className="text-xs text-slate-500 mt-0.5">
            {job.client_name} · {formatRelativeTime(job.posted_date)}
          </p>
        </div>
        <span className="text-sm font-bold text-brand whitespace-nowrap">
          {formatBudget(job.budget_min, job.budget_max, job.budget_type)}
        </span>
      </div>
      {!compact && (
        <p className="text-sm text-slate-600 mt-3 line-clamp-2">{job.description}</p>
      )}
      {skills.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mt-3">
          {skills.map((skill) => (
            <span
              key={skill}
              className="text-[11px] font-medium px-2 py-0.5 rounded-md bg-slate-100 text-slate-600"
            >
              {skill}
            </span>
          ))}
        </div>
      )}
      <p className="text-xs text-slate-400 mt-3">
        {job.proposal_count} teklif · {job.category}
      </p>
    </div>
  );
}

export function JobCardPortal({ job, variant = 'vertical' }: JobCardPortalProps) {
  const compact = variant === 'horizontal';
  const body = <JobCardBody job={job} compact={compact} />;

  if (variant === 'horizontal') {
    return (
      <Link href={`/portal/jobs/${job.id}`} className="block shrink-0 w-[280px] snap-start">
        <MagicCard className="h-full hover:shadow-card-hover transition-shadow">{body}</MagicCard>
      </Link>
    );
  }

  return (
    <Link href={`/portal/jobs/${job.id}`} className="block">
      <MagicCard className="hover:shadow-card-hover transition-shadow">{body}</MagicCard>
    </Link>
  );
}
