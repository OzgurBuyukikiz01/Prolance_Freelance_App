'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { MessageCircle } from 'lucide-react';
import { createClient } from '@/lib/supabase/client';

type QuickMessageButtonProps = {
  currentUserId: string;
  otherUserId: string;
  className?: string;
  label?: string;
};

export function QuickMessageButton({
  currentUserId,
  otherUserId,
  className,
  label = 'Message',
}: QuickMessageButtonProps) {
  const router = useRouter();
  const [pending, setPending] = useState(false);

  const openConversation = async () => {
    if (pending) return;
    setPending(true);
    const supabase = createClient();

    try {
      const { data: rows } = await supabase
        .from('conversations')
        .select('id, participant_ids')
        .contains('participant_ids', [currentUserId, otherUserId]);

      const existing = (rows ?? []).find((row) => {
        const ids = (row.participant_ids ?? []) as string[];
        return ids.length === 2 && ids.includes(currentUserId) && ids.includes(otherUserId);
      });

      let id = existing?.id as string | undefined;
      if (!id) {
        const { data: inserted, error } = await supabase
          .from('conversations')
          .insert({
            participant_ids: [currentUserId, otherUserId],
            last_message_at: new Date().toISOString(),
          })
          .select('id')
          .single();
        if (error) throw error;
        id = inserted.id as string;
      }

      router.push(`/portal/messages/${id}`);
    } finally {
      setPending(false);
    }
  };

  return (
    <button
      type="button"
      onClick={openConversation}
      disabled={pending}
      className={className}
    >
      <MessageCircle className="h-4 w-4" />
      {pending ? 'Opening…' : label}
    </button>
  );
}
