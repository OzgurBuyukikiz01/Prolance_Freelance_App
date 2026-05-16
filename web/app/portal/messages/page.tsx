import Link from 'next/link';
import { redirect } from 'next/navigation';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';
import { formatRelativeTime } from '@/lib/portal/format';

type ConversationRow = {
  id: string;
  participant_ids: string[];
  last_message_at: string | null;
  created_at: string;
};

export default async function PortalMessagesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: conversations, error } = await supabase
    .from('conversations')
    .select('id, participant_ids, last_message_at, created_at')
    .contains('participant_ids', [user.id])
    .order('last_message_at', { ascending: false, nullsFirst: false });

  if (error) {
    return (
      <MagicCard innerClassName="p-6 text-sm text-red-600">
        Mesajlar yüklenemedi: {error.message}
      </MagicCard>
    );
  }

  const rows = (conversations ?? []) as ConversationRow[];
  const enriched = await Promise.all(
    rows.map(async (conv) => {
      const otherId =
        conv.participant_ids.find((id) => id !== user.id) ?? conv.participant_ids[0];

      const [{ data: profile }, { data: lastMsg }] = await Promise.all([
        supabase.from('profiles').select('full_name, avatar_url').eq('id', otherId).maybeSingle(),
        supabase
          .from('messages')
          .select('body, created_at')
          .eq('conversation_id', conv.id)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle(),
      ]);

      return {
        id: conv.id,
        otherName: profile?.full_name || 'Kullanıcı',
        lastMessage: lastMsg?.body ?? 'Sohbet başlatın',
        lastAt: conv.last_message_at ?? lastMsg?.created_at ?? conv.created_at,
      };
    }),
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900">Mesajlar</h1>
        <p className="text-sm text-slate-500 mt-1">Sohbetleriniz</p>
      </div>

      {enriched.length === 0 ? (
        <MagicCard innerClassName="p-8 text-center text-sm text-slate-500">
          Henüz sohbet yok. Bir iş ilanı veya teklif üzerinden mesajlaşma başlatabilirsiniz.
        </MagicCard>
      ) : (
        <ul className="space-y-3">
          {enriched.map((conv) => (
            <li key={conv.id}>
              <Link href={`/portal/messages/${conv.id}`}>
                <MagicCard className="block hover:shadow-card-hover transition-shadow">
                  <div className="p-4 flex items-center gap-4">
                    <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-brand to-indigo-500 flex items-center justify-center text-white font-bold shrink-0">
                      {conv.otherName.charAt(0).toUpperCase()}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="font-semibold text-slate-900 truncate">{conv.otherName}</p>
                      <p className="text-sm text-slate-500 line-clamp-1">{conv.lastMessage}</p>
                    </div>
                    <span className="text-xs text-slate-400 shrink-0">
                      {formatRelativeTime(conv.lastAt)}
                    </span>
                  </div>
                </MagicCard>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
