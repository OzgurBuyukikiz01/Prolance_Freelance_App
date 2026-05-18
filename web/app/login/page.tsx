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
    <div className="min-h-screen flex items-center justify-center px-4 py-20">
      <div className="w-full max-w-md">
        {/* Logo */}
        <a href="/" className="flex items-center justify-center gap-2 mb-8">
          <span className="w-9 h-9 rounded-xl bg-brand flex items-center justify-center text-white font-black text-lg shadow-brand">
            P
          </span>
          <span className="text-2xl font-display font-bold text-white">Prolance</span>
        </a>

        {/* Card */}
        <div className="bg-dark-surface rounded-3xl border border-white/10 p-8 shadow-glass">
          {/* Tabs */}
          <div className="flex bg-white/5 rounded-xl p-1 mb-8">
            <a
              href="/login?tab=login"
              className={`flex-1 text-center text-sm font-semibold py-2 rounded-lg transition-all ${
                tab === 'login'
                  ? 'bg-dark-elevated text-white shadow-glass-sm'
                  : 'text-slate-500 hover:text-slate-300'
              }`}
            >
              Sign In
            </a>
            <a
              href="/login?tab=signup"
              className={`flex-1 text-center text-sm font-semibold py-2 rounded-lg transition-all ${
                tab === 'signup'
                  ? 'bg-dark-elevated text-white shadow-glass-sm'
                  : 'text-slate-500 hover:text-slate-300'
              }`}
            >
              Sign Up
            </a>
          </div>

          {/* Error */}
          {errorMsg && (
            <div className="mb-4 bg-red-900/30 border border-red-500/30 text-red-400 text-sm px-4 py-3 rounded-xl">
              {decodeURIComponent(errorMsg)}
            </div>
          )}

          {tab === 'login' ? (
            <form action={login} className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Email</label>
                <input
                  name="email"
                  type="email"
                  required
                  placeholder="you@example.com"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Password</label>
                <input
                  name="password"
                  type="password"
                  required
                  placeholder="••••••••"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                />
              </div>
              <button
                type="submit"
                className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors shadow-brand mt-2"
              >
                Sign In
              </button>
              <p className="text-center text-xs text-slate-500 mt-1">
                Don&apos;t have an account?{' '}
                <a href="/login?tab=signup" className="text-brand font-medium hover:underline">
                  Sign up
                </a>
              </p>
            </form>
          ) : (
            <form action={signup} className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Full Name</label>
                <input
                  name="full_name"
                  type="text"
                  required
                  placeholder="Your full name"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Email</label>
                <input
                  name="email"
                  type="email"
                  required
                  placeholder="you@example.com"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Password</label>
                <input
                  name="password"
                  type="password"
                  required
                  placeholder="Minimum 6 characters"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-slate-300">Account Type</label>
                <select
                  name="role"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand/50 transition"
                >
                  <option value="FREELANCER" className="bg-dark-surface">Freelancer</option>
                  <option value="CLIENT" className="bg-dark-surface">Client</option>
                </select>
              </div>
              <button
                type="submit"
                className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-3 rounded-xl transition-colors shadow-brand mt-2"
              >
                Create Account
              </button>
              <p className="text-center text-xs text-slate-500 mt-1">
                Already have an account?{' '}
                <a href="/login?tab=login" className="text-brand font-medium hover:underline">
                  Sign in
                </a>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
