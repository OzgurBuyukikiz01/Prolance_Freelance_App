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
import type { LandingStats } from '@/lib/landing-stats';

export const dynamic = 'force-dynamic';

const ESCROW_STATUSES = ['FUNDED', 'HELD', 'RELEASED'] as const;

async function fetchLandingStats(): Promise<LandingStats> {
  const fallback: LandingStats = {
    userCount: 0,
    jobCount: 0,
    escrowVolumeTry: 0,
    avgRating: 4.9,
    reviewCount: 0,
  };

  try {
    const sb = createServiceClient();
    const [
      { count: userCount },
      { count: jobCount },
      { data: escrowRows },
      { data: reviewRows },
    ] = await Promise.all([
      sb.from('profiles').select('*', { count: 'exact', head: true }),
      sb.from('jobs').select('*', { count: 'exact', head: true }).eq('status', 'open'),
      sb
        .from('escrow_transactions')
        .select('amount_cents')
        .in('status', [...ESCROW_STATUSES]),
      sb.from('reviews').select('rating'),
    ]);

    const escrowVolumeTry =
      (escrowRows ?? []).reduce((sum, row) => sum + Number(row.amount_cents ?? 0), 0) / 100;

    const ratings = (reviewRows ?? []).map((r) => Number(r.rating)).filter((n) => Number.isFinite(n));
    const reviewCount = ratings.length;
    const avgRating =
      reviewCount > 0 ? ratings.reduce((a, b) => a + b, 0) / reviewCount : 4.9;

    return {
      userCount: userCount ?? 0,
      jobCount: jobCount ?? 0,
      escrowVolumeTry,
      avgRating,
      reviewCount,
    };
  } catch {
    return fallback;
  }
}

export default async function Home() {
  const stats = await fetchLandingStats();

  return (
    <>
      <Navbar authSlot={<AuthNav />} />
      <main>
        <HeroSection stats={stats} />
        <FeaturesSection />
        <HowItWorks />
        <Stats stats={stats} />
        <Pricing />
        <Testimonials />
        <DownloadCTA />
      </main>
      <Footer />
    </>
  );
}
