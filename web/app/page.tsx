import Navbar from '@/components/sections/Navbar';
import HeroSection from '@/components/sections/HeroSection';
import FeaturesSection from '@/components/sections/FeaturesSection';
import HowItWorks from '@/components/sections/HowItWorks';
import Stats from '@/components/sections/Stats';
import Pricing from '@/components/sections/Pricing';
import Testimonials from '@/components/sections/Testimonials';
import DownloadCTA from '@/components/sections/DownloadCTA';
import Footer from '@/components/sections/Footer';
import AuthNav from '@/components/AuthNav';
import { createServiceClient } from '@/lib/supabaseAdmin';

export const dynamic = 'force-dynamic';

async function fetchLandingStats(): Promise<{ userCount: number; jobCount: number }> {
  try {
    const sb = createServiceClient();
    const [{ count: userCount }, { count: jobCount }] = await Promise.all([
      sb.from('profiles').select('*', { count: 'exact', head: true }),
      sb.from('jobs').select('*', { count: 'exact', head: true }).eq('status', 'open'),
    ]);
    return {
      userCount: userCount ?? 0,
      jobCount: jobCount ?? 0,
    };
  } catch {
    return { userCount: 0, jobCount: 0 };
  }
}

export default async function Home() {
  const { userCount, jobCount } = await fetchLandingStats();

  return (
    <>
      <Navbar authSlot={<AuthNav />} />
      <main>
        <HeroSection />
        <FeaturesSection />
        <HowItWorks />
        <Stats userCount={userCount} jobCount={jobCount} />
        <Pricing />
        <Testimonials />
        <DownloadCTA />
      </main>
      <Footer />
    </>
  );
}
