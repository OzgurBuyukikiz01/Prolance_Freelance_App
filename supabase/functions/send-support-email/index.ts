// Sends support / ticket notifications through Resend (API key never exposed to the client).
// Required secret: RESEND_API_KEY (unchanged). Optional: RESEND_FROM_EMAIL.
// Tickets are always delivered to ozgurbuyukikiz@gmail.com; reply_to comes from the client (user-entered email).

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/** Extract addr from "Name <addr>" or plain addr. */
function extractEmail(fromHeader: string): string {
  const m = fromHeader.match(/<([^>]+)>/);
  if (m) return m[1]!.trim();
  return fromHeader.trim();
}

/**
 * Resend only allows verified domains as "from". Consumer webmail in env
 * would cause 422 — fall back to Resend's sandbox sender.
 */
function resendSafeFrom(raw: string): string {
  const trimmed = raw.trim();
  if (!trimmed) return 'Prolance <onboarding@resend.dev>';
  const addr = extractEmail(trimmed).toLowerCase();
  if (
    /@(gmail|googlemail|yahoo|hotmail|outlook|live|icloud)\./i.test(addr)
  ) {
    return 'Prolance <onboarding@resend.dev>';
  }
  return trimmed;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method_not_allowed' }), {
      status: 405,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnon = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  if (!supabaseUrl || !supabaseAnon) {
    return new Response(JSON.stringify({ error: 'server_misconfigured' }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const supabase = createClient(supabaseUrl, supabaseAnon, {
    global: { headers: { Authorization: authHeader } },
  });

  const {
    data: { user },
    error: userErr,
  } = await supabase.auth.getUser();
  if (userErr || !user) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), {
      status: 401,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: 'invalid_json' }), {
      status: 400,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const subject = String(body.subject ?? '').trim().slice(0, 200);
  const textBody = String(body.body ?? '').trim().slice(0, 12000);
  const priority = String(body.priority ?? 'NORMAL').trim().slice(0, 20);
  const source = String(body.source ?? 'app').trim().slice(0, 120);
  const contactEmail = String(body.contactEmail ?? '').trim().slice(0, 254);

  const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contactEmail);
  if (subject.length < 3 || textBody.length < 5 || !emailOk) {
    return new Response(JSON.stringify({ error: 'validation' }), {
      status: 400,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const apiKey = Deno.env.get('RESEND_API_KEY')?.trim();
  const fromRaw =
    Deno.env.get('RESEND_FROM_EMAIL')?.trim() ??
    'Prolance <onboarding@resend.dev>';
  const from = resendSafeFrom(fromRaw);

  /** Product support inbox (fixed; tickets always land here). */
  const supportInbox = 'ozgurbuyukikiz@gmail.com';

  if (!apiKey) {
    return new Response(
      JSON.stringify({
        skipped: true,
        reason: 'RESEND_API_KEY not set',
      }),
      { status: 200, headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  }

  const authEmail =
    typeof user.email === 'string' && user.email.includes('@')
      ? user.email
      : null;

  const html = `
    <h2>Prolance support</h2>
    ${
      from !== fromRaw.trim()
        ? `<p><em>Note: "from" was adjusted to Resend&apos;s onboarding sender because <code>${escapeHtml(
            extractEmail(fromRaw),
          )}</code> is not a verified domain sender.</em></p>`
        : ''
    }
    <p><strong>Reply-to (user entered):</strong> ${escapeHtml(contactEmail)}</p>
    <p><strong>User ID:</strong> ${escapeHtml(user.id)}</p>
    ${
      authEmail
        ? `<p><strong>Auth email:</strong> ${escapeHtml(authEmail)}</p>`
        : ''
    }
    <p><strong>Priority:</strong> ${escapeHtml(priority)}</p>
    <p><strong>Source:</strong> ${escapeHtml(source)}</p>
    <p><strong>Subject:</strong> ${escapeHtml(subject)}</p>
    <hr/>
    <pre style="white-space:pre-wrap;font-family:system-ui,sans-serif">${escapeHtml(
      textBody,
    )}</pre>
  `;

  const payload: Record<string, unknown> = {
    from,
    to: [supportInbox],
    reply_to: contactEmail,
    subject: `[Prolance][${priority}] ${subject}`,
    html,
    text: [
      `Reply-to (user): ${contactEmail}`,
      `User ID: ${user.id}`,
      `Priority: ${priority}`,
      `Source: ${source}`,
      `Subject: ${subject}`,
      '',
      textBody,
    ].join('\n'),
  };

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const js = (await res.json().catch(() => ({}))) as Record<string, unknown>;
  if (!res.ok) {
    return new Response(
      JSON.stringify({ error: 'resend_failed', detail: js }),
      { status: 502, headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  }

  return new Response(JSON.stringify({ ok: true, id: js.id }), {
    status: 200,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
});
