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

export default function Home() {
  return (
    <>
      <Navbar authSlot={<AuthNav />} />
      <main>
        <HeroSection />
        <FeaturesSection />
        <HowItWorks />
        <Stats />
        <Pricing />
        <Testimonials />
        <DownloadCTA />
      </main>
      <Footer />
    </>
  );
}
