import { login, signup } from './actions';

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; tab?: string }>;
}) {
  const params = await searchParams;
  const errorMsg = params.error;
  const tab = params.tab ?? 'login';

  return (
    <div className="min-h-screen bg-hero-gradient flex items-center justify-center px-4 py-20">
      {/* Background blobs */}
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full bg-brand/10 blur-3xl" />
        <div className="absolute bottom-0 right-0 w-[360px] h-[360px] rounded-full bg-indigo-100/60 blur-3xl" />
      </div>

      <div className="w-full max-w-md">
        {/* Logo */}
        <a href="/" className="flex items-center justify-center gap-2 mb-8">
          <span className="w-9 h-9 rounded-xl bg-brand flex items-center justify-center text-white font-black text-lg shadow-brand">
            P
          </span>
          <span className="text-2xl font-extrabold text-slate-900">Prolance</span>
        </a>

        {/* Card */}
        <div className="bg-white rounded-3xl shadow-card border border-slate-100 p-8">
          {/* Tabs */}
          <div className="flex bg-slate-100 rounded-xl p-1 mb-8">
            <a
              href="/login?tab=login"
              className={`flex-1 text-center text-sm font-semibold py-2 rounded-lg transition-all ${
                tab === 'login'
                  ? 'bg-white text-slate-900 shadow-card'
                  : 'text-slate-500 hover:text-slate-700'
              }`}
            >
              Giriş Yap
            </a>
            <a
              href="/login?tab=signup"
              className={`flex-1 text-center text-sm font-semibold py-2 rounded-lg transition-all ${
                tab === 'signup'
                  ? 'bg-white text-slate-900 shadow-card'
                  : 'text-slate-500 hover:text-slate-700'
              }`}
            >
              Kayıt Ol
            </a>
          </div>

          {/* Error */}
          {errorMsg && (
            <div className="mb-4 bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl">
              {decodeURIComponent(errorMsg)}
            </div>
          )}

          {tab === 'login' ? (
            <form action={login} className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">E-posta</label>
                <input
                  name="email"
                  type="email"
                  required
                  placeholder="ornek@email.com"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">Şifre</label>
                <input
                  name="password"
                  type="password"
                  required
                  placeholder="••••••••"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand transition"
                />
              </div>
              <button
                type="submit"
                className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors shadow-brand mt-2"
              >
                Giriş Yap
              </button>
              <p className="text-center text-xs text-slate-400 mt-1">
                Hesabın yok mu?{' '}
                <a href="/login?tab=signup" className="text-brand font-medium hover:underline">
                  Kayıt ol
                </a>
              </p>
            </form>
          ) : (
            <form action={signup} className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">Ad Soyad</label>
                <input
                  name="full_name"
                  type="text"
                  required
                  placeholder="Adınız Soyadınız"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">E-posta</label>
                <input
                  name="email"
                  type="email"
                  required
                  placeholder="ornek@email.com"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">Şifre</label>
                <input
                  name="password"
                  type="password"
                  required
                  placeholder="En az 6 karakter"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-700">Hesap Türü</label>
                <select
                  name="role"
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand/40 focus:border-brand bg-white transition"
                >
                  <option value="FREELANCER">Freelancer</option>
                  <option value="CLIENT">İşveren</option>
                </select>
              </div>
              <button
                type="submit"
                className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors shadow-brand mt-2"
              >
                Kayıt Ol
              </button>
              <p className="text-center text-xs text-slate-400 mt-1">
                Zaten hesabın var mı?{' '}
                <a href="/login?tab=login" className="text-brand font-medium hover:underline">
                  Giriş yap
                </a>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
