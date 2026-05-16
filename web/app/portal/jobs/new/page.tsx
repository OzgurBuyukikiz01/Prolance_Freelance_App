import Link from 'next/link';
import { redirect } from 'next/navigation';
import { PostJobForm } from '@/components/portal/PostJobForm';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  searchParams: Promise<{ error?: string }>;
};

export default async function PortalNewJobPage({ searchParams }: PageProps) {
  const query = await searchParams;
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

  if (profile?.role !== 'CLIENT') {
    redirect('/portal?error=' + encodeURIComponent('Yalnızca işveren hesapları ilan yayınlayabilir.'));
  }

  return (
    <div className="space-y-6">
      <div>
        <Link href="/portal/jobs" className="text-sm font-medium text-brand hover:text-brand-dark">
          ← İlanlara dön
        </Link>
        <h1 className="text-2xl font-extrabold text-slate-900 mt-2">Yeni İş İlanı</h1>
        <p className="text-sm text-slate-500 mt-1">İlanınız onay sonrası yayına alınır.</p>
      </div>
      {query.error ? (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      ) : null}
      <MagicCard innerClassName="p-6">
        <PostJobForm />
      </MagicCard>
    </div>
  );
}
