import type { Metadata } from 'next';
import { Poppins, Space_Grotesk } from 'next/font/google';
import './globals.css';
import { AuroraBackground } from '@/components/ui/AuroraBackground';

const poppins = Poppins({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700', '800'],
  variable: '--font-poppins',
  display: 'swap',
});

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-space',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Prolance — Freelance with Confidence',
  description:
    'Escrow-protected payments between clients and freelancers. Funds stay locked until work is approved.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${poppins.variable} ${spaceGrotesk.variable}`}>
      <body>
        <AuroraBackground />
        {children}
      </body>
    </html>
  );
}
