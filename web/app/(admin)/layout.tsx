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
    <div className="min-h-screen bg-[#0A0F1E] text-white font-sans antialiased relative overflow-hidden">
      {/* Ambient gradient blobs */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="blob-coral absolute top-0 left-1/4 w-[500px] h-[500px] rounded-full" />
        <div className="blob-violet absolute bottom-1/4 right-1/4 w-[400px] h-[400px] rounded-full" />
        <div className="blob-mint absolute top-1/2 left-0 w-[350px] h-[350px] rounded-full" />
      </div>
      {/* Content */}
      <div className="flex relative z-10 min-h-screen">
        <Sidebar />
        <main className="flex-1 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
