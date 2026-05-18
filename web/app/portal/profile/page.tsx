import { redirect } from 'next/navigation';
import { ProfileForm } from '@/components/portal/ProfileForm';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { formatRelativeTime } from '@/lib/portal/format';

const STAR_VALUES = [1, 2, 3, 4, 5];

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
      'full_name, title, bio, location, website, hourly_rate, role, skills, avatar_url, email, rating, completed_jobs, earnings_available_cents',
    )
    .eq('id', user.id)
    .single();

  const isFreelancer = profile?.role === 'FREELANCER';

  // Fetch reviews received by this user
  const { data: reviews } = isFreelancer
    ? await supabase
        .from('reviews')
        .select('id, rating, comment, created_at, reviewer_id')
        .eq('reviewee_id', user.id)
        .order('created_at', { ascending: false })
        .limit(20)
    : { data: [] };

  // Fetch reviewer names
  const enrichedReviews = await Promise.all(
    (reviews ?? []).map(async (r) => {
      const { data: reviewer } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', r.reviewer_id)
        .maybeSingle();
      return { ...r, reviewerName: reviewer?.full_name ?? 'Anonymous' };
    }),
  );

  if (!profile) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-400">Profile not found.</MagicCard>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">Profile</h1>
        <p className="text-sm text-slate-400 mt-1">Update your information</p>
      </div>

      {query.error && (
        <div className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-400">
          {decodeURIComponent(query.error)}
        </div>
      )}
      {query.saved === '1' && (
        <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
          Profile saved.
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

      {/* Freelancer stats + reviews */}
      {isFreelancer && (
        <>
          <div>
            <h2 className="text-lg font-extrabold text-white">Reviews</h2>
            {profile?.rating != null && (
              <p className="text-sm text-slate-400 mt-0.5">
                Average:{' '}
                <span className="font-bold text-amber-400">
                  {Number(profile.rating).toFixed(1)} ★
                </span>
                {' '}· {profile.completed_jobs ?? 0} completed jobs
              </p>
            )}
          </div>

          {!enrichedReviews.length ? (
            <MagicCard innerClassName="p-8 text-center">
              <p className="text-sm text-slate-400">No reviews yet.</p>
            </MagicCard>
          ) : (
            <ul className="space-y-3">
              {enrichedReviews.map((r) => (
                <li key={r.id}>
                  <MagicCard>
                    <div className="p-4">
                      <div className="flex items-center justify-between gap-2 mb-1.5">
                        <p className="text-sm font-semibold text-white">{r.reviewerName}</p>
                        <p className="text-xs text-slate-400">{formatRelativeTime(r.created_at)}</p>
                      </div>
                      <div className="flex items-center gap-0.5 mb-2">
                        {STAR_VALUES.map((v) => (
                          <span
                            key={v}
                            className={v <= r.rating ? 'text-amber-400' : 'text-slate-200'}
                          >
                            ★
                          </span>
                        ))}
                      </div>
                      {r.comment && (
                        <p className="text-sm text-slate-400">{r.comment}</p>
                      )}
                    </div>
                  </MagicCard>
                </li>
              ))}
            </ul>
          )}
        </>
      )}
    </div>
  );
}
