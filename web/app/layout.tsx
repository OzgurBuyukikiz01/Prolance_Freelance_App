import type { Metadata } from 'next';

import { fontSans } from '@/lib/fonts';
import './globals.css';

export const metadata: Metadata = {
  title: 'Prolance — Freelance Güvenle',
  description:
    'İşveren ile freelancer arasında escrow koruması. Ödeme serbest bırakılana kadar güvende.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="tr" className={fontSans.variable}>
      <body className={`${fontSans.className} font-sans antialiased`}>{children}</body>
    </html>
  );
}
