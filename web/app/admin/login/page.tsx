import { adminLogin } from './actions';

export default async function AdminLoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const errorMsg = params.error;

  return (
    <div className="min-h-screen bg-[#0A0F1E] flex items-center justify-center px-4 relative overflow-hidden">
      {/* Ambient blobs */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="blob-coral absolute top-0 left-1/4 w-96 h-96 rounded-full" />
        <div className="blob-violet absolute bottom-1/4 right-1/4 w-80 h-80 rounded-full" />
      </div>

      <div className="w-full max-w-sm relative z-10">
        {/* Logo */}
        <div className="flex items-center justify-center gap-3 mb-8">
          <span
            className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-black text-lg"
            style={{ background: 'linear-gradient(135deg, #7248FE, #9075FF)' }}
          >
            P
          </span>
          <div>
            <div className="text-white font-extrabold text-xl leading-none">Prolance</div>
            <div className="text-primary-400 text-xs font-semibold tracking-widest uppercase mt-0.5">Admin</div>
          </div>
        </div>

        {/* Card */}
        <div className="glass-card p-8">
          <h1 className="text-white text-xl font-bold mb-1">Admin Girişi</h1>
          <p className="text-white/40 text-sm mb-6">Yalnızca yetkili admin hesapları girebilir.</p>

          {errorMsg && (
            <div className="mb-4 bg-red-500/10 border border-red-500/30 text-red-400 text-sm px-4 py-3 rounded-xl">
              {decodeURIComponent(errorMsg)}
            </div>
          )}

          <form action={adminLogin} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <label className="text-white/60 text-sm font-medium">E-posta</label>
              <input
                name="email"
                type="email"
                required
                placeholder="admin@prolance.com"
                className="bg-white/5 border border-white/10 text-white rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500/40 focus:border-primary-500 transition placeholder:text-white/25"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-white/60 text-sm font-medium">Şifre</label>
              <input
                name="password"
                type="password"
                required
                placeholder="••••••••"
                className="bg-white/5 border border-white/10 text-white rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500/40 focus:border-primary-500 transition placeholder:text-white/25"
              />
            </div>
            <button
              type="submit"
              className="mt-2 w-full font-bold py-3 rounded-xl transition-all text-white hover:opacity-90"
              style={{ background: 'linear-gradient(135deg, #7248FE, #9075FF)' }}
            >
              Giriş Yap
            </button>
          </form>
        </div>

        <p className="text-center text-white/20 text-xs mt-6">
          Prolance Admin Panel — Yetkisiz erişim yasaktır.
        </p>
      </div>
    </div>
  );
}
