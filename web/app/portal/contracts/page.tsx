import Link from 'next/link';
import { redirect } from 'next/navigation';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { LIFECYCLE_LABELS, formatCents, formatRelativeTime } from '@/lib/portal/format';

export default async function ContractsPage() {
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

  const role = profile?.role ?? 'FREELANCER';
  const isClient = role === 'CLIENT';

  let contracts: Array<{
    id: string;
    job_id: string;
    bid: number;
    funded_amount_cents: number | null;
    lifecycle_phase: string;
    created_at: string;
    jobTitle: string;
    otherPartyName: string;
  }> = [];

  if (isClient) {
    // Get all jobs owned by this client
    const { data: jobs } = await supabase
      .from('jobs')
      .select('id')
      .eq('client_id', user.id);

    const jobIds = (jobs ?? []).map((j) => j.id);

    if (jobIds.length > 0) {
      const { data: proposals } = await supabase
        .from('proposals')
        .select('id, job_id, bid, funded_amount_cents, lifecycle_phase, created_at, freelancer_id')
        .in('job_id', jobIds)
        .eq('status', 'accepted')
        .order('created_at', { ascending: false });

      contracts = await Promise.all(
        (proposals ?? []).map(async (p) => {
          const [{ data: job }, { data: freelancer }] = await Promise.all([
            supabase.from('jobs').select('title').eq('id', p.job_id).maybeSingle(),
            supabase.from('profiles').select('full_name').eq('id', p.freelancer_id).maybeSingle(),
          ]);
          return {
            ...p,
            jobTitle: job?.title ?? 'İlan',
            otherPartyName: freelancer?.full_name ?? 'Freelancer',
          };
        }),
      );
    }
  } else {
    const { data: proposals } = await supabase
      .from('proposals')
      .select('id, job_id, bid, funded_amount_cents, lifecycle_phase, created_at, job:jobs(title, client_id)')
      .eq('freelancer_id', user.id)
      .eq('status', 'accepted')
      .order('created_at', { ascending: false });

    contracts = await Promise.all(
      (proposals ?? []).map(async (p) => {
        const jobData = Array.isArray(p.job) ? p.job[0] : p.job;
        const clientId = jobData?.client_id;
        const { data: client } = clientId
          ? await supabase.from('profiles').select('full_name').eq('id', clientId).maybeSingle()
          : { data: null };
        return {
          id: p.id,
          job_id: p.job_id,
          bid: p.bid,
          funded_amount_cents: p.funded_amount_cents,
          lifecycle_phase: p.lifecycle_phase,
          created_at: p.created_at,
          jobTitle: jobData?.title ?? 'İlan',
          otherPartyName: client?.full_name ?? 'İşveren',
        };
      }),
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900">Sözleşmelerim</h1>
        <p className="text-sm text-slate-500 mt-1">
          {isClient ? 'Kabul ettiğiniz teklifler ve proje süreçleri' : 'Kabul edilen teklifleriniz ve teslimat süreçleri'}
        </p>
      </div>

      {!contracts.length ? (
        <MagicCard innerClassName="p-10 text-center">
          <p className="text-slate-500 text-sm mb-3">
            {isClient
              ? 'Henüz kabul edilmiş bir teklifiniz yok.'
              : 'Henüz kabul edilmiş bir teklifiniz yok.'}
          </p>
          <Link
            href="/portal/jobs"
            className="text-sm font-semibold text-brand hover:text-brand-dark"
          >
            İş İlanlarına Git →
          </Link>
        </MagicCard>
      ) : (
        <ul className="space-y-4">
          {contracts.map((c) => {
            const phase = LIFECYCLE_LABELS[c.lifecycle_phase] ?? LIFECYCLE_LABELS.escrow_funded;
            return (
              <li key={c.id}>
                <Link href={`/portal/contracts/${c.id}`} className="block group">
                  <MagicCard>
                    <div className="p-5">
                      <div className="flex flex-wrap items-start justify-between gap-2 mb-2">
                        <div className="min-w-0">
                          <p className="font-bold text-slate-900 group-hover:text-brand transition-colors truncate">
                            {c.jobTitle}
                          </p>
                          <p className="text-xs text-slate-400 mt-0.5">
                            {isClient ? 'Freelancer' : 'İşveren'}: {c.otherPartyName} ·{' '}
                            {formatRelativeTime(c.created_at)}
                          </p>
                        </div>
                        <span
                          className={`text-xs font-semibold px-2.5 py-1 rounded-full border shrink-0 ${phase.className}`}
                        >
                          {phase.label}
                        </span>
                      </div>
                      <div className="flex items-center justify-between mt-3">
                        <p className="text-sm font-bold text-brand">
                          {formatCents(c.funded_amount_cents ?? Math.round(c.bid * 100))}
                        </p>
                        <span className="text-xs text-slate-400 group-hover:text-brand transition-colors">
                          Detay →
                        </span>
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
