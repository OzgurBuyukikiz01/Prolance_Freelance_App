'use client';

import { useEffect, useMemo, useState } from 'react';

type LiveCountdownProps = {
  deadline: string | null | undefined;
  expiredText?: string;
  prefix?: string;
  className?: string;
};

function formatDeadline(deadline: string) {
  const diff = new Date(deadline).getTime() - Date.now();
  if (diff <= 0) return null;
  const hours = Math.floor(diff / 3_600_000);
  const minutes = Math.floor((diff % 3_600_000) / 60_000);
  const seconds = Math.floor((diff % 60_000) / 1000);
  if (hours > 0) return `${hours}h ${minutes}m ${seconds}s`;
  if (minutes > 0) return `${minutes}m ${seconds}s`;
  return `${seconds}s`;
}

export function LiveCountdown({
  deadline,
  expiredText = 'Expired',
  prefix,
  className,
}: LiveCountdownProps) {
  const [, setTick] = useState(0);

  useEffect(() => {
    if (!deadline) return;
    const timer = setInterval(() => {
      setTick((value) => value + 1);
    }, 1000);
    return () => clearInterval(timer);
  }, [deadline]);

  const text = useMemo(() => {
    if (!deadline) return expiredText;
    const next = formatDeadline(deadline);
    if (!next) return expiredText;
    return prefix ? `${prefix}${next}` : next;
  }, [deadline, expiredText, prefix]);

  return <span className={className}>{text}</span>;
}
