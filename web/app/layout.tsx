import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

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
    <html lang="tr" className={`${inter.variable} font-sans`}>
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
