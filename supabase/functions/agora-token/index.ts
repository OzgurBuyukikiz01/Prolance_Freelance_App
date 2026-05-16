// Agora RTC token minting for conversation calls.
// Requires AGORA_APP_ID and AGORA_APP_CERTIFICATE in Edge Function secrets.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { RtcRole, RtcTokenBuilder } from 'npm:agora-access-token@2.0.4';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function uidFromUuid(uuid: string): number {
  let h = 0;
  for (let i = 0; i < uuid.length; i++) {
    h = (h * 31 + uuid.charCodeAt(i)) >>> 0;
  }
  return (h % 2147483646) + 1;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }

  const appId = Deno.env.get('AGORA_APP_ID') ?? '';
  const appCertificate = Deno.env.get('AGORA_APP_CERTIFICATE') ?? '';
  if (!appId || !appCertificate) {
    return new Response(
      JSON.stringify({
        error:
          'Agora is not configured. Set AGORA_APP_ID and AGORA_APP_CERTIFICATE.',
      }),
      {
        status: 503,
        headers: { ...cors, 'Content-Type': 'application/json' },
      },
    );
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } },
  );

  try {
    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const body = await req.json();
    const conversationId = body.conversationId as string;
    if (!conversationId) {
      return new Response(JSON.stringify({ error: 'conversationId required' }), {
        status: 400,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const { data: conv, error: convError } = await supabase
      .from('conversations')
      .select('participant_ids')
      .eq('id', conversationId)
      .maybeSingle();

    if (convError || !conv) {
      return new Response(JSON.stringify({ error: 'Conversation not found' }), {
        status: 404,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const participants = (conv.participant_ids as string[]) ?? [];
    if (!participants.includes(userData.user.id)) {
      return new Response(JSON.stringify({ error: 'Forbidden' }), {
        status: 403,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const channel = conversationId;
    const uid = uidFromUuid(userData.user.id);
    const now = Math.floor(Date.now() / 1000);
    const expire = now + 3600;
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channel,
      uid,
      RtcRole.PUBLISHER,
      expire,
      expire,
    );

    return new Response(
      JSON.stringify({ token, appId, channel, uid }),
      { headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: `${e}` }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
