import Link from 'next/link';

export const metadata = {
  title: 'Privacy Policy | Prolance',
  description: 'Learn how Prolance handles your personal data.',
};

const sections = [
  {
    id: 'collected',
    title: '1. Data We Collect',
    body: [
      'Prolance processes the following personal data to provide its services and ensure security:',
      '• Identity information: First name, last name, email address, profile photo',
      '• Account information: Encrypted password, session tokens (JWT)',
      '• Messaging data: Conversations and shared files (encrypted via TLS + AES-256)',
      '• Usage data: IP address, device type, page view statistics',
      '• Payment data: Escrow transaction history (card details are not stored by Prolance; processed by PSP)',
    ],
  },
  {
    id: 'usage',
    title: '2. How We Use Your Data',
    body: [
      'Collected data is used for the following purposes:',
      '• Account creation and authentication',
      '• Management of job listings and proposals',
      '• Processing escrow and payment transactions',
      '• Handling your support requests',
      '• Ensuring platform security and preventing fraud',
      '• Fulfilling legal obligations',
      'Your data is never sold to third parties. Data may only be shared with service infrastructure providers (Supabase/AWS) under a data processing agreement.',
    ],
  },
  {
    id: 'storage',
    title: '3. Data Retention',
    body: [
      'Your personal data is retained for as long as your account is active and as required by legal retention obligations.',
      'When you close your account, your personal data is deleted within 30 days; however, certain records (invoices, escrow history) may be archived for mandatory retention periods as required by law.',
      'Messaging content and files are automatically anonymized within 12 months of the last communication.',
    ],
  },
  {
    id: 'rights',
    title: '4. Your Rights',
    body: [
      'Under GDPR you have the following rights:',
      '• Right of access: You may request access to the personal data we process about you.',
      '• Right of rectification: You may request correction of inaccurate or incomplete data.',
      '• Right to erasure ("right to be forgotten"): Under certain conditions, you may request deletion of your data.',
      '• Right to object: You may object to processing carried out on the basis of legitimate interests.',
      '• Right to data portability: You may request that your data be transferred in a machine-readable format.',
      'To exercise these rights, please write to privacy@prolance.app.',
    ],
  },
  {
    id: 'cookies',
    title: '5. Cookies',
    body: [
      'The Prolance website uses cookies for session management and to improve user experience.',
      '• Essential cookies: Authentication and security (cannot be removed without signing out)',
      '• Analytics cookies: Anonymous traffic statistics (optional; can be disabled from your browser)',
      '• Marketing cookies: Not used',
    ],
  },
  {
    id: 'contact',
    title: '6. Contact',
    body: [
      'For privacy-related inquiries: privacy@prolance.app',
      'For legal notices: legal@prolance.app',
      'Last updated: May 16, 2026',
    ],
  },
];

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-dark-base">
      {/* Header */}
      <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-indigo-400 font-semibold text-sm tracking-widest uppercase mb-3">
            Legal
          </p>
          <h1 className="text-4xl font-extrabold text-white mb-4">
            Privacy Policy
          </h1>
          <p className="text-slate-300 text-lg">
            Last updated:{' '}
            <span className="text-indigo-300 font-medium">May 16, 2026</span>
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-4 py-14">
        <div className="prose prose-invert max-w-none">
          <p className="text-slate-400 mb-10 text-base leading-relaxed">
            At Prolance, we take your privacy seriously. This policy explains what
            data we collect, how we use it, and your rights.
          </p>

          {/* Security highlight */}
          <div className="mb-10 p-5 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex gap-4">
            <span className="text-2xl">🔒</span>
            <div>
              <p className="font-semibold text-emerald-400 mb-1">
                Your data is secure
              </p>
              <p className="text-emerald-300/80 text-sm leading-relaxed">
                All communications are encrypted over TLS 1.3. Database data is
                protected with AES-256. Access control is enforced via Supabase
                Row Level Security (RLS).
              </p>
            </div>
          </div>

          <nav className="mb-12 p-6 bg-white/5 rounded-2xl border border-white/8">
            <p className="font-semibold text-slate-300 mb-3 text-sm uppercase tracking-wide">
              Table of Contents
            </p>
            <ul className="space-y-2">
              {sections.map((s) => (
                <li key={s.id}>
                  <a
                    href={`#${s.id}`}
                    className="text-brand hover:text-violet-400 text-sm font-medium transition-colors"
                  >
                    {s.title}
                  </a>
                </li>
              ))}
            </ul>
          </nav>

          {sections.map((s) => (
            <section key={s.id} id={s.id} className="mb-12 scroll-mt-8">
              <h2 className="text-xl font-bold text-white mb-4 pb-2 border-b border-white/8">
                {s.title}
              </h2>
              <div className="space-y-4">
                {s.body.map((para, i) => (
                  <p key={i} className="text-slate-400 leading-relaxed text-[15px]">
                    {para}
                  </p>
                ))}
              </div>
            </section>
          ))}

          <div className="mt-16 p-6 bg-brand/10 rounded-2xl border border-brand/20 text-center">
            <p className="text-brand font-medium mb-2">
              Have privacy-related questions?
            </p>
            <p className="text-slate-400 text-sm">
              Reach us at{' '}
              <a
                href="mailto:privacy@prolance.app"
                className="text-brand underline hover:text-violet-400"
              >
                privacy@prolance.app
              </a>
            </p>
          </div>
        </div>

        <div className="mt-12 flex items-center justify-between text-sm text-slate-400 border-t border-white/8 pt-8">
          <Link href="/" className="hover:text-brand transition-colors">
            ← Back to Home
          </Link>
          <Link href="/terms" className="hover:text-brand transition-colors">
            Terms of Service →
          </Link>
        </div>
      </div>
    </main>
  );
}
