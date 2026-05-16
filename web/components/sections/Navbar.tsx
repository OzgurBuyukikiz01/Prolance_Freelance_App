'use client';

import { Navbar1 } from '@/components/ui/navbar-1';

export default function Navbar({ authSlot }: { authSlot?: React.ReactNode }) {
  return <Navbar1 authSlot={authSlot} />;
}
