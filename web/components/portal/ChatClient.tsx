'use client';

import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { createClient } from '@/lib/supabase/client';

export type ChatMessage = {
  id: string;
  sender_id: string;
  body: string;
  created_at: string;
};

type ChatClientProps = {
  conversationId: string;
  currentUserId: string;
  initialMessages: ChatMessage[];
};

export function ChatClient({
  conversationId,
  currentUserId,
  initialMessages,
}: ChatClientProps) {
  const [messages, setMessages] = useState<ChatMessage[]>(initialMessages);
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    const supabase = createClient();
    const channel = supabase
      .channel(`messages:${conversationId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `conversation_id=eq.${conversationId}`,
        },
        (payload) => {
          const row = payload.new as ChatMessage;
          setMessages((prev) => {
            if (prev.some((m) => m.id === row.id)) return prev;
            return [...prev, row];
          });
        },
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [conversationId]);

  async function handleSend(e: React.FormEvent) {
    e.preventDefault();
    const text = body.trim();
    if (!text || sending) return;

    setSending(true);
    setError(null);
    const supabase = createClient();

    const { error: insertError } = await supabase.from('messages').insert({
      conversation_id: conversationId,
      sender_id: currentUserId,
      body: text,
    });

    if (insertError) {
      setError(insertError.message);
      setSending(false);
      return;
    }

    await supabase
      .from('conversations')
      .update({ last_message_at: new Date().toISOString() })
      .eq('id', conversationId);

    setBody('');
    setSending(false);
  }

  return (
    <div className="flex flex-col h-[min(70vh,560px)]">
      <div className="flex-1 overflow-y-auto space-y-3 pr-1 mb-4">
        {messages.length === 0 ? (
          <p className="text-sm text-slate-500 text-center py-8">Henüz mesaj yok. İlk mesajı siz gönderin.</p>
        ) : (
          messages.map((msg) => {
            const mine = msg.sender_id === currentUserId;
            return (
              <div
                key={msg.id}
                className={`flex ${mine ? 'justify-end' : 'justify-start'}`}
              >
                <motion.div
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  className={`max-w-[85%] rounded-2xl px-4 py-2.5 text-sm ${
                    mine
                      ? 'bg-brand text-white rounded-br-md'
                      : 'bg-slate-100 text-slate-800 rounded-bl-md'
                  }`}
                >
                  <p className="whitespace-pre-wrap break-words">{msg.body}</p>
                  <p
                    className={`text-[10px] mt-1 ${mine ? 'text-white/70' : 'text-slate-400'}`}
                  >
                    {new Date(msg.created_at).toLocaleTimeString('tr-TR', {
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </motion.div>
              </div>
            );
          })
        )}
        <div ref={bottomRef} />
      </div>

      {error && <p className="text-xs text-red-600 mb-2">{error}</p>}

      <form onSubmit={handleSend} className="flex gap-2">
        <input
          type="text"
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder="Mesaj yazın…"
          className="flex-1 rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
          disabled={sending}
        />
        <button
          type="submit"
          disabled={sending || !body.trim()}
          className="shrink-0 bg-brand hover:bg-brand-dark disabled:opacity-50 text-white font-semibold px-5 py-3 rounded-xl text-sm"
        >
          Gönder
        </button>
      </form>
    </div>
  );
}
