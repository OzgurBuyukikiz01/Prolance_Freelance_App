import { redirect } from 'next/navigation';
import { CalendarClient } from '@/components/portal/CalendarClient';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  searchParams: Promise<{ error?: string; saved?: string }>;
};

export default async function PortalCalendarPage({ searchParams }: PageProps) {
  const query = await searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: scheduleRows } = await supabase
    .from('job_schedule_items')
    .select('id, title, due_date, job_id, completed_at, jobs(title)')
    .order('due_date', { ascending: true });

  const items =
    scheduleRows?.map((row) => {
      const job = row.jobs as { title?: string } | { title?: string }[] | null;
      const jobTitle = Array.isArray(job) ? job[0]?.title : job?.title;
      return {
        id: row.id,
        title: row.title,
        due_date: row.due_date,
        job_id: row.job_id,
        job_title: jobTitle ?? '',
        completed_at: row.completed_at,
      };
    }) ?? [];

  const jobIds = [...new Set(items.map((i) => i.job_id))];
  let jobs: { id: string; title: string }[] = [];

  if (jobIds.length) {
    const { data: jobRows } = await supabase.from('jobs').select('id, title').in('id', jobIds);
    jobs = jobRows ?? [];
  }

  const { data: ownedJobs } = await supabase
    .from('jobs')
    .select('id, title')
    .eq('client_id', user.id)
    .limit(20);

  const { data: acceptedProposals } = await supabase
    .from('proposals')
    .select('job_id, jobs(id, title)')
    .eq('freelancer_id', user.id)
    .eq('status', 'accepted');

  const extraJobs =
    acceptedProposals?.map((p) => {
      const j = p.jobs as { id: string; title: string } | { id: string; title: string }[] | null;
      if (Array.isArray(j)) return j[0];
      return j;
    }).filter(Boolean) ?? [];

  const jobMap = new Map<string, { id: string; title: string }>();
  for (const j of [...jobs, ...(ownedJobs ?? []), ...extraJobs]) {
    if (j?.id) jobMap.set(j.id, { id: j.id, title: j.title });
  }
  jobs = [...jobMap.values()];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900">Takvim</h1>
        <p className="text-sm text-slate-500 mt-1">İş kilometre taşları ve teslim tarihleri</p>
      </div>

      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.saved === '1' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Görev eklendi.
        </div>
      )}

      <MagicCard innerClassName="p-6">
        <CalendarClient items={items} jobs={jobs} />
      </MagicCard>
    </div>
  );
}
