import Link from 'next/link';
import { redirect } from 'next/navigation';
import { SupportTicketForm } from '@/components/portal/SupportTicketForm';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  searchParams: Promise<{ error?: string; submitted?: string }>;
};

export default async function PortalSupportPage({ searchParams }: PageProps) {
  const query = await searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  return (
    <div className="space-y-6">
      <div>
        <Link href="/portal" className="text-sm font-medium text-brand hover:text-brand-dark">
          ← Portala dön
        </Link>
        <h1 className="text-2xl font-extrabold text-slate-900 mt-2">Destek</h1>
        <p className="text-sm text-slate-500 mt-1">
          Sorun veya önerileriniz için destek talebi oluşturun.
        </p>
      </div>

      {query.error ? (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      ) : null}

      {query.submitted === '1' ? (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Talebiniz alındı. Destek ekibimiz en kısa sürede size dönüş yapacak.
        </div>
      ) : null}

      <MagicCard innerClassName="p-6">
        {query.submitted === '1' ? (
          <p className="text-sm text-slate-600">
            Yeni bir talep oluşturmak isterseniz{' '}
            <Link href="/portal/support" className="text-brand font-semibold hover:underline">
              bu sayfayı yenileyin
            </Link>
            .
          </p>
        ) : (
          <SupportTicketForm />
        )}
      </MagicCard>
    </div>
  );
}
