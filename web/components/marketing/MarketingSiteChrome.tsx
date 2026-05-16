import Footer from '@/components/sections/Footer';
import Navbar from '@/components/sections/Navbar';

type MarketingSiteChromeProps = {
  children: React.ReactNode;
};

export default function MarketingSiteChrome({ children }: MarketingSiteChromeProps) {
  return (
    <>
      <Navbar />
      {children}
      <Footer />
    </>
  );
}
