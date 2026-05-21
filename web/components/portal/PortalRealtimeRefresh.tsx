'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

type RealtimeTarget = {
  table: string;
  filter?: string;
};

type PortalRealtimeRefreshProps = {
  channelKey: string;
  targets: RealtimeTarget[];
};

export function PortalRealtimeRefresh({
  channelKey,
  targets,
}: PortalRealtimeRefreshProps) {
  const router = useRouter();

  useEffect(() => {
    const supabase = createClient();
    let refreshTimer: ReturnType<typeof setTimeout> | null = null;
    const channel = supabase.channel(`portal-refresh:${channelKey}`);

    const scheduleRefresh = () => {
      if (refreshTimer) clearTimeout(refreshTimer);
      refreshTimer = setTimeout(() => {
        router.refresh();
      }, 220);
    };

    for (const target of targets) {
      channel.on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: target.table,
          ...(target.filter ? { filter: target.filter } : {}),
        },
        scheduleRefresh,
      );
    }

    channel.subscribe();

    return () => {
      if (refreshTimer) clearTimeout(refreshTimer);
      supabase.removeChannel(channel);
    };
  }, [channelKey, router, targets]);

  return null;
}
