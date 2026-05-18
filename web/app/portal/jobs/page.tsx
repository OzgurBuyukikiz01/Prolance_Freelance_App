import { redirect } from 'next/navigation';
import { JobsListClient } from '@/components/portal/JobsListClient';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

export default async function PortalJobsPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  const isClient = profile?.role === 'CLIENT';

  const { data: jobs, error } = await supabase
    .from('jobs')
    .select(
      'id, title, description, budget_min, budget_max, budget_type, skills, posted_date, proposal_count, client_name, category, status',
    )
    .eq('status', 'open')
    .order('posted_date', { ascending: false });

  if (error) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-600">
        Failed to load jobs: {error.message}
      </MagicCard>
    );
  }

  return <JobsListClient jobs={jobs ?? []} isClient={isClient} />;
}
