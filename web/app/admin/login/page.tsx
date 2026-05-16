import { adminLogin } from './actions';

export default async function AdminLoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const errorMsg = params.error;

  return (
    <div className="min-h-screen bg-slate-950 flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="flex items-center justify-center gap-2 mb-8">
          <span className="w-10 h-10 rounded-xl bg-amber-500 flex items-center justify-center text-white font-black text-lg">
            P
          </span>
          <div>
            <div className="text-white font-extrabold text-xl leading-none">Prolance</div>
            <div className="text-amber-400 text-xs font-semibold tracking-widest uppercase">Admin</div>
          </div>
        </div>

        {/* Card */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8">
          <h1 className="text-white text-xl font-bold mb-1">Admin Girişi</h1>
          <p className="text-slate-400 text-sm mb-6">Yalnızca yetkili admin hesapları girebilir.</p>

          {errorMsg && (
            <div className="mb-4 bg-red-500/10 border border-red-500/30 text-red-400 text-sm px-4 py-3 rounded-xl">
              {decodeURIComponent(errorMsg)}
            </div>
          )}

          <form action={adminLogin} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <label className="text-slate-300 text-sm font-medium">E-posta</label>
              <input
                name="email"
                type="email"
                required
                placeholder="admin@prolance.com"
                className="bg-slate-800 border border-slate-700 text-white rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/40 focus:border-amber-500 transition placeholder:text-slate-500"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-slate-300 text-sm font-medium">Şifre</label>
              <input
                name="password"
                type="password"
                required
                placeholder="••••••••"
                className="bg-slate-800 border border-slate-700 text-white rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/40 focus:border-amber-500 transition placeholder:text-slate-500"
              />
            </div>
            <button
              type="submit"
              className="mt-2 w-full bg-amber-500 hover:bg-amber-400 text-slate-900 font-bold py-3 rounded-xl transition-colors"
            >
              Giriş Yap
            </button>
          </form>
        </div>

        <p className="text-center text-slate-600 text-xs mt-6">
          Prolance Admin Panel — Yetkisiz erişim yasaktır.
        </p>
      </div>
    </div>
  );
}
