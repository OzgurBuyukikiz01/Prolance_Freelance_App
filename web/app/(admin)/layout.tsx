import { redirect } from 'next/navigation';

import Sidebar from '@/components/admin/Sidebar';
import { createClient } from '@/lib/supabase/server';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/admin/login');
  }

  return (
    <div className="flex min-h-screen bg-slate-950 text-slate-100 font-sans antialiased">
      <Sidebar />
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
