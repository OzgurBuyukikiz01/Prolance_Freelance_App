import Link from 'next/link';

export const metadata = {
  title: 'Terms of Service | Prolance',
  description: 'Please read our Terms of Service before using the Prolance platform.',
};

const sections = [
  {
    id: 'general',
    title: '1. General Terms',
    body: [
      'These Terms of Service ("Terms") govern the services provided through the Prolance application and website ("Platform"). By using the Platform, you agree to these Terms.',
      'Prolance is an intermediary platform connecting clients with freelancers. Prolance is not a party to the working relationship between them.',
      'Individuals under the age of 18 may not use the Platform. If you register on behalf of an organization, you represent that you are authorized to act on its behalf.',
    ],
  },
  {
    id: 'account',
    title: '2. Account & Security',
    body: [
      'You must provide accurate and up-to-date information during registration. Prolance is not liable for damages arising from inaccurate information.',
      'You are responsible for the security of your account. Do not share your password with anyone. If you become aware of unauthorized use of your account, you must notify us immediately.',
      'You may not transfer or sell your account, or impersonate another user.',
    ],
  },
  {
    id: 'escrow',
    title: '3. Escrow & Payments',
    body: [
      'Prolance provides an escrow mechanism to reduce disputes between clients and freelancers. The client deposits the agreed fee into the Prolance escrow account; funds are released when the work is completed or both parties approve.',
      'Escrow payments are in mock (simulation) mode. In production, they will be processed through licensed payment service providers (PSP).',
      'In the event of a dispute, the Prolance admin team may review the situation and issue a binding decision. This process allows both parties to present information.',
      'Platform fees may vary depending on the active subscription plan. Current fee rates are listed on the Pricing page.',
    ],
  },
  {
    id: 'prohibited',
    title: '4. Prohibited Content & Conduct',
    body: [
      'The following actions are strictly prohibited and may result in permanent account termination:',
      '• Arranging to make or receive payments outside the platform',
      '• Creating fake reviews or ratings',
      '• Sending unsolicited commercial messages (spam)',
      '• Sharing illegal, obscene, or hate-based content',
      '• Collecting or using another user\'s personal data without consent',
    ],
  },
  {
    id: 'ip',
    title: '5. Intellectual Property',
    body: [
      'All content you upload to the Platform (portfolio, project outputs, messages) remains your property. Prolance uses this content solely to provide its services.',
      'Transfer of copyright over delivered work is subject to the agreement between the client and the freelancer. Prolance is not a party to this transfer.',
      'The Prolance brand, logo, and designs are the property of Prolance and may not be used without permission.',
    ],
  },
  {
    id: 'liability',
    title: '6. Limitation of Liability',
    body: [
      'Prolance is not liable for transactions between users, the quality of delivered work, or damages caused by third-party service providers.',
      'Uninterrupted or error-free operation of the Platform is not guaranteed. Service may be temporarily interrupted due to maintenance, security patches, or force majeure.',
      'To the maximum extent permitted by law, Prolance\'s total liability to any user is limited to the platform fees paid by that user in the last 12 months.',
    ],
  },
  {
    id: 'changes',
    title: '7. Changes',
    body: [
      'We may update these Terms from time to time. Significant changes will be announced via email or platform notification.',
      'Continued use of the Platform after a change constitutes acceptance of the updated Terms.',
      'Last updated: May 16, 2026',
    ],
  },
];

export default function TermsPage() {
  return (
    <main className="min-h-screen bg-dark-base">
      {/* Header */}
      <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-indigo-400 font-semibold text-sm tracking-widest uppercase mb-3">
            Legal
          </p>
          <h1 className="text-4xl font-extrabold text-white mb-4">
            Terms of Service
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
            Please read the following terms carefully before using the Prolance
            platform. By accessing or creating an account, you agree to these terms.
          </p>

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
              Have questions?
            </p>
            <p className="text-slate-400 text-sm">
              Reach us at{' '}
              <a
                href="mailto:legal@prolance.app"
                className="text-brand underline hover:text-violet-400"
              >
                legal@prolance.app
              </a>
            </p>
          </div>
        </div>

        <div className="mt-12 flex items-center justify-between text-sm text-slate-400 border-t border-white/8 pt-8">
          <Link href="/" className="hover:text-brand transition-colors">
            ← Back to Home
          </Link>
          <Link href="/privacy" className="hover:text-brand transition-colors">
            Privacy Policy →
          </Link>
        </div>
      </div>
    </main>
  );
}
