import type { ReactNode } from 'react';

type MarketingPageShellProps = {
  eyebrow: string;
  title: string;
  subtitle?: ReactNode;
  children: ReactNode;
  footerNav?: ReactNode;
};

export default function MarketingPageShell({
  eyebrow,
  title,
  subtitle,
  children,
  footerNav,
}: MarketingPageShellProps) {
  return (
    <main className="min-h-screen bg-white">
      <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-indigo-400 font-semibold text-sm tracking-widest uppercase mb-3">
            {eyebrow}
          </p>
          <h1 className="text-4xl font-extrabold text-white mb-4">{title}</h1>
          {subtitle ? (
            <p className="text-slate-300 text-lg">{subtitle}</p>
          ) : null}
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 py-14">
        {children}
        {footerNav}
      </div>
    </main>
  );
}
