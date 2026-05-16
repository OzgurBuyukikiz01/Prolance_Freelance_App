import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import Sidebar from '@/components/Sidebar';
import { createClient } from '@/lib/supabase/server';

const inter = Inter({ subsets: ['latin'], variable: '--font-inter', display: 'swap' });

export const metadata: Metadata = {
  title: 'Prolance Admin',
  description: 'Operations, tickets, escrow disputes',
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const isLoginPage = !user;

  return (
    <html lang="tr" className={inter.variable}>
      <body className="bg-slate-950 text-slate-100 font-sans antialiased">
        {isLoginPage ? (
          children
        ) : (
          <div className="flex min-h-screen">
            <Sidebar />
            <main className="flex-1 overflow-auto">{children}</main>
          </div>
        )}
      </body>
    </html>
  );
}
