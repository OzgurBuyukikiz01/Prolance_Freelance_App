import Link from 'next/link';
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
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(59,130,246,0.10),_transparent_32%),linear-gradient(180deg,_#020617_0%,_#0f172a_48%,_#111827_100%)] px-4 py-10 lg:px-8">
      <div className="mx-auto grid min-h-[calc(100vh-5rem)] max-w-6xl items-center gap-8 lg:grid-cols-[1.05fr_0.95fr]">
        <div className="hidden lg:block">
          <Link href="/" className="inline-flex items-center gap-3">
            <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-brand text-lg font-black text-white shadow-brand">
              P
            </span>
            <div>
              <p className="font-display text-2xl font-bold text-white">Prolance</p>
              <p className="text-sm text-slate-400">Freelance delivery workspace</p>
            </div>
          </Link>

          <div className="mt-12 max-w-xl">
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-brand/80">
              Portal Access
            </p>
            <h1 className="mt-4 text-5xl font-display font-bold tracking-tight text-white">
              Manage jobs, proposals, contracts, and payout flow in one place.
            </h1>
            <p className="mt-6 max-w-lg text-base leading-7 text-slate-300">
              Built for active client and freelancer work, not a marketing shell. Keep listings live,
              review proposals fast, and follow delivery status without leaving the workspace.
            </p>

            <div className="mt-10 grid gap-4 sm:grid-cols-3">
              {[
                ['Realtime updates', 'Jobs, proposals, and contract states stay in sync.'],
                ['Clear workflow', 'Move from listing to delivery review with less friction.'],
                ['Escrow tracking', 'Watch balances, payout states, and delivery windows.'],
              ].map(([title, body]) => (
                <div
                  key={title}
                  className="rounded-3xl border border-white/10 bg-white/[0.04] p-5 shadow-[0_16px_50px_rgba(2,6,23,0.18)]"
                >
                  <p className="text-sm font-semibold text-white">{title}</p>
                  <p className="mt-2 text-sm leading-6 text-slate-400">{body}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="w-full">
          <div className="rounded-[32px] border border-white/10 bg-slate-950/70 p-6 shadow-[0_30px_90px_rgba(2,6,23,0.35)] backdrop-blur-2xl sm:p-8">
            <div className="mb-8 flex items-center justify-between gap-4 lg:hidden">
              <Link href="/" className="flex items-center gap-3">
                <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-brand text-sm font-black text-white shadow-brand">
                  P
                </span>
                <span className="font-display text-xl font-bold text-white">Prolance</span>
              </Link>
            </div>

            <div className="mb-8">
              <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-500">
                {tab === 'login' ? 'Welcome back' : 'Create your account'}
              </p>
              <h2 className="mt-3 text-3xl font-display font-bold tracking-tight text-white">
                {tab === 'login' ? 'Sign in to your workspace' : 'Start working on Prolance'}
              </h2>
              <p className="mt-2 text-sm leading-6 text-slate-400">
                {tab === 'login'
                  ? 'Use your email and password to continue to the portal.'
                  : 'Choose a role and create an account that is ready for client or freelancer work.'}
              </p>
            </div>

            <div className="mb-8 grid grid-cols-2 rounded-2xl border border-white/10 bg-white/[0.04] p-1">
              <a
                href="/login?tab=login"
                className={`rounded-2xl px-4 py-3 text-center text-sm font-semibold transition-all ${
                  tab === 'login'
                    ? 'bg-white text-slate-950 shadow-[0_10px_24px_rgba(255,255,255,0.16)]'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Sign In
              </a>
              <a
                href="/login?tab=signup"
                className={`rounded-2xl px-4 py-3 text-center text-sm font-semibold transition-all ${
                  tab === 'signup'
                    ? 'bg-white text-slate-950 shadow-[0_10px_24px_rgba(255,255,255,0.16)]'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Sign Up
              </a>
            </div>

            {errorMsg && (
              <div className="mb-5 rounded-2xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">
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
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white placeholder-slate-500 transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-slate-300">Password</label>
                  <input
                    name="password"
                    type="password"
                    required
                    placeholder="Enter your password"
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white placeholder-slate-500 transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  />
                </div>
                <button
                  type="submit"
                  className="mt-2 w-full rounded-2xl bg-brand py-3 text-sm font-semibold text-white transition-colors hover:bg-brand-dark"
                >
                  Sign In
                </button>
                <p className="text-center text-xs text-slate-500">
                  Don&apos;t have an account?{' '}
                  <a href="/login?tab=signup" className="font-medium text-brand hover:underline">
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
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white placeholder-slate-500 transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-slate-300">Email</label>
                  <input
                    name="email"
                    type="email"
                    required
                    placeholder="you@example.com"
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white placeholder-slate-500 transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-slate-300">Password</label>
                  <input
                    name="password"
                    type="password"
                    required
                    placeholder="Minimum 6 characters"
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white placeholder-slate-500 transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-slate-300">Account Type</label>
                  <select
                    name="role"
                    className="w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white transition focus:border-brand/50 focus:outline-none focus:ring-2 focus:ring-brand/30"
                  >
                    <option value="FREELANCER" className="bg-slate-900">
                      Freelancer
                    </option>
                    <option value="CLIENT" className="bg-slate-900">
                      Client
                    </option>
                  </select>
                </div>
                <button
                  type="submit"
                  className="mt-2 w-full rounded-2xl bg-brand py-3 text-sm font-semibold text-white transition-colors hover:bg-brand-dark"
                >
                  Create Account
                </button>
                <p className="text-center text-xs text-slate-500">
                  Already have an account?{' '}
                  <a href="/login?tab=login" className="font-medium text-brand hover:underline">
                    Sign in
                  </a>
                </p>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
