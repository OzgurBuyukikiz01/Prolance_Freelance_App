import { redirect } from 'next/navigation';
import { logout } from '@/app/login/actions';
import { createClient } from '@/lib/supabase/server';

const ROLE_LABELS: Record<string, string> = {
  FREELANCER: 'Freelancer',
  CLIENT: 'İşveren',
};

const ROLE_COLORS: Record<string, string> = {
  FREELANCER: 'bg-indigo-50 text-indigo-700 border-indigo-100',
  CLIENT: 'bg-emerald-50 text-emerald-700 border-emerald-100',
};

export default async function PortalPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, role, is_admin, avatar_url, completed_jobs, rating, total_earnings')
    .eq('id', user.id)
    .single();

  const name = profile?.full_name || user.email?.split('@')[0] || 'Kullanıcı';
  const role = profile?.role ?? 'FREELANCER';
  const isAdmin = profile?.is_admin ?? false;

  return (
    <div className="min-h-screen bg-hero-gradient pt-20 px-4 pb-16">
      {/* Background blobs */}
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full bg-brand/10 blur-3xl" />
        <div className="absolute top-1/2 right-0 w-[360px] h-[360px] rounded-full bg-indigo-100/60 blur-3xl" />
      </div>

      <div className="max-w-2xl mx-auto">
        {/* Welcome card */}
        <div className="bg-white rounded-3xl shadow-card border border-slate-100 p-8 mb-6">
          <div className="flex items-center gap-5 mb-6">
            {/* Avatar */}
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-brand to-indigo-500 flex items-center justify-center text-white text-2xl font-extrabold shadow-brand flex-shrink-0">
              {name.charAt(0).toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="text-xl font-extrabold text-slate-900 truncate">
                  Hoş geldin, {name}!
                </h1>
                {isAdmin && (
                  <span className="bg-amber-50 text-amber-700 border border-amber-200 text-xs font-bold px-2.5 py-1 rounded-full">
                    Admin
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2 mt-1.5">
                <span
                  className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${
                    ROLE_COLORS[role] ?? 'bg-slate-50 text-slate-600 border-slate-100'
                  }`}
                >
                  {ROLE_LABELS[role] ?? role}
                </span>
                <span className="text-xs text-slate-400">{user.email}</span>
              </div>
            </div>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-4 py-4 border-t border-b border-slate-100 mb-6">
            {[
              { label: 'Tamamlanan İş', value: profile?.completed_jobs ?? 0 },
              { label: 'Puan', value: profile?.rating ? (profile.rating as number).toFixed(1) + '★' : '—' },
              {
                label: 'Toplam Kazanç',
                value: profile?.total_earnings
                  ? '₺' + (profile.total_earnings as number).toLocaleString()
                  : '₺0',
              },
            ].map((s) => (
              <div key={s.label} className="text-center">
                <div className="text-xl font-extrabold text-slate-900">{s.value}</div>
                <div className="text-xs text-slate-400 mt-0.5">{s.label}</div>
              </div>
            ))}
          </div>

          {/* Actions */}
          <div className="flex flex-col gap-3">
            {isAdmin && (
              <a
                href="http://localhost:3002"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-bold py-3.5 rounded-xl transition-all shadow-lg"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                Admin Panele Geç
              </a>
            )}
            <a
              href="/#features"
              className="flex items-center justify-center gap-2 bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              İş İlanlarına Göz At
            </a>
            <form action={logout}>
              <button
                type="submit"
                className="w-full flex items-center justify-center gap-2 border border-slate-200 hover:border-red-200 hover:bg-red-50 hover:text-red-600 text-slate-600 font-medium py-3 rounded-xl transition-colors text-sm"
              >
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                Çıkış Yap
              </button>
            </form>
          </div>
        </div>

        {/* Quick info for normal users */}
        {!isAdmin && (
          <div className="bg-brand-light border border-brand/20 rounded-2xl p-5 text-sm text-brand">
            <strong>Mobil uygulamayı indirmeyi unutma!</strong> Tüm iş ilanları, escrow ödemeleri ve
            mesajlaşma özelliklerine mobil uygulamadan ulaşabilirsin.
          </div>
        )}
      </div>
    </div>
  );
}
