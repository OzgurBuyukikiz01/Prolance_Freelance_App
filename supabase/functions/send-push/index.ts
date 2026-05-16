// Supabase Edge Function: deliver FCM v1 push for a notifications row.
// Secret: FIREBASE_SERVICE_ACCOUNT_JSON (full service account JSON string).

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

async function getGoogleAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');

  const unsigned = `${enc(header)}.${enc(claim)}`;
  const pem = sa.private_key.replace(/\\n/g, '\n');
  const keyData = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const binary = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binary,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(unsigned),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');

  const jwt = `${unsigned}.${sigB64}`;
  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok) {
    throw new Error(`Google token error: ${JSON.stringify(tokenJson)}`);
  }
  return tokenJson.access_token as string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }

  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountRaw) {
    return new Response(
      JSON.stringify({ error: 'FIREBASE_SERVICE_ACCOUNT_JSON not configured' }),
      {
        status: 503,
        headers: { ...cors, 'Content-Type': 'application/json' },
      },
    );
  }

  let serviceAccount: ServiceAccount;
  try {
    serviceAccount = JSON.parse(serviceAccountRaw) as ServiceAccount;
  } catch {
    return new Response(
      JSON.stringify({ error: 'Invalid FIREBASE_SERVICE_ACCOUNT_JSON' }),
      {
        status: 500,
        headers: { ...cors, 'Content-Type': 'application/json' },
      },
    );
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    const body = await req.json();
    const notificationId = body.notificationId as string;
    if (!notificationId) {
      return new Response(JSON.stringify({ error: 'notificationId required' }), {
        status: 400,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const { data: row, error } = await supabase
      .from('notifications')
      .select('id, profile_id, title, body, type')
      .eq('id', notificationId)
      .single();

    if (error || !row) {
      return new Response(JSON.stringify({ error: 'notification not found' }), {
        status: 404,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', row.profile_id)
      .single();

    const fcmToken = profile?.fcm_token as string | null;
    if (!fcmToken) {
      return new Response(JSON.stringify({ ok: true, skipped: 'no fcm_token' }), {
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const accessToken = await getGoogleAccessToken(serviceAccount);
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title: row.title,
              body: row.body,
            },
            data: {
              notification_id: row.id,
              type: row.type ?? 'generic',
            },
          },
        }),
      },
    );

    const fcmJson = await fcmRes.json();
    if (!fcmRes.ok) {
      return new Response(JSON.stringify({ error: fcmJson }), {
        status: 502,
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ ok: true, fcm: fcmJson }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: `${e}` }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
