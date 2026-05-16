import { redirect } from 'next/navigation';
import { ProfileForm } from '@/components/portal/ProfileForm';
import { MagicCard } from '@/components/ui/magic-card';
import { ModalPricing } from '@/components/ui/modal-pricing';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  searchParams: Promise<{ error?: string; saved?: string }>;
};

export default async function PortalProfilePage({ searchParams }: PageProps) {
  const query = await searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select(
      'full_name, title, bio, location, website, hourly_rate, role, skills, avatar_url, email',
    )
    .eq('id', user.id)
    .single();

  if (!profile) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-600">Profil bulunamadı.</MagicCard>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Profil</h1>
          <p className="text-sm text-slate-500 mt-1">Bilgilerinizi güncelleyin</p>
        </div>
        <ModalPricing triggerClassName="shrink-0" />
      </div>

      {query.error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.saved === '1' && (
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Profil kaydedildi.
        </div>
      )}

      <MagicCard innerClassName="p-6">
        <ProfileForm
          profile={{
            ...profile,
            email: profile.email ?? user.email ?? null,
          }}
        />
      </MagicCard>
    </div>
  );
}
