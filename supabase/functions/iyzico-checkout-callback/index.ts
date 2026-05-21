// @ts-nocheck
/**
 * iyzico Checkout Form callback - POST with `token` (no JWT).
 * Retrieves payment; on success credits profiles.demo_balance_cents.
 */
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import Iyzipay from 'npm:iyzipay@2.0.67';

function htmlRedirect(outcome: string): Response {
  const encodedOutcome = JSON.stringify(outcome);
  const deepLink = `io.prolance.app://iyzico-result?outcome=${encodeURIComponent(outcome)}`;
  const body = `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Completing payment</title>
    <style>
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background: #0f172a;
        color: #e2e8f0;
        font: 14px/1.5 system-ui, sans-serif;
      }
      .card {
        max-width: 420px;
        padding: 24px;
        border-radius: 18px;
        border: 1px solid rgba(148, 163, 184, 0.18);
        background: rgba(15, 23, 42, 0.88);
        box-shadow: 0 18px 48px rgba(2, 6, 23, 0.32);
        text-align: center;
      }
      .title {
        margin-bottom: 8px;
        font-size: 16px;
        font-weight: 700;
      }
      .copy {
        color: #94a3b8;
      }
    </style>
    <script>
      (() => {
        const outcome = ${encodedOutcome};
        const payload = JSON.stringify({ type: 'prolance-iyzico-result', outcome });

        try {
          if (window.opener && !window.opener.closed) {
            window.opener.postMessage(payload, '*');
          }
        } catch (_) {}

        setTimeout(() => {
          try {
            window.close();
          } catch (_) {}
        }, 80);

        setTimeout(() => {
          location.replace(${JSON.stringify(deepLink)});
        }, 240);
      })();
    </script>
  </head>
  <body>
    <div class="card">
      <div class="title">Completing payment</div>
      <div class="copy">You can return to Prolance. This window will close automatically when possible.</div>
    </div>
  </body>
</html>`;
  return new Response(body, {
    status: 200,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

async function readToken(req: Request): Promise<string | null> {
  const ct = (req.headers.get('content-type') ?? '').toLowerCase();
  if (ct.includes('application/json')) {
    try {
      const j = (await req.json()) as Record<string, unknown>;
      const t = j?.token;
      return typeof t === 'string' && t.length > 0 ? t : null;
    } catch {
      return null;
    }
  }
  const raw = await req.text();
  if (!raw) return null;
  if (raw.trim().startsWith('{')) {
    try {
      const j = JSON.parse(raw) as Record<string, unknown>;
      const t = j?.token;
      return typeof t === 'string' ? t : null;
    } catch {
      /* fall through */
    }
  }
  const sp = new URLSearchParams(raw);
  const t = sp.get('token');
  return t && t.length > 0 ? t : null;
}

function paidPriceToCents(paid: string | undefined): number {
  if (!paid) return 0;
  const n = Number(String(paid).replace(',', '.'));
  if (!Number.isFinite(n)) return 0;
  return Math.round(n * 100);
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'content-type',
      },
    });
  }

  const apiKey = Deno.env.get('IYZICO_API_KEY') ?? '';
  const secretKey = Deno.env.get('IYZICO_SECRET_KEY') ?? '';
  const baseUri = Deno.env.get('IYZICO_URI') ?? 'https://sandbox-api.iyzipay.com';
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';

  if (!apiKey || !secretKey || !serviceRole || !supabaseUrl) {
    return htmlRedirect('config');
  }

  let token: string | null = null;
  if (req.method === 'GET') {
    const u = new URL(req.url);
    token = u.searchParams.get('token');
  } else if (req.method === 'POST') {
    token = await readToken(req);
  } else {
    return new Response('Method Not Allowed', { status: 405 });
  }

  if (!token) {
    return htmlRedirect('missing_token');
  }

  const admin = createClient(supabaseUrl, serviceRole);
  const { data: row, error: selErr } = await admin
    .from('iyzico_demo_checkouts')
    .select('id, profile_id, amount_cents, status, conversation_id')
    .eq('checkout_token', token)
    .maybeSingle();

  if (selErr || !row) {
    console.warn('[iyzico-checkout-callback] unknown token');
    return htmlRedirect('unknown');
  }

  if (row.status === 'completed') {
    return htmlRedirect('success');
  }

  const iyzipay = new Iyzipay({
    apiKey,
    secretKey,
    uri: baseUri,
  });

  const retrieve: Record<string, unknown> = await new Promise((resolve, reject) => {
    try {
      iyzipay.checkoutForm.retrieve(
        {
          locale: Iyzipay.LOCALE.TR,
          conversationId: row.conversation_id as string,
          token,
        },
        (err: Error | null, res: Record<string, unknown>) => {
          if (err) reject(err);
          else resolve(res ?? {});
        },
      );
    } catch (e) {
      reject(e);
    }
  });

  if (retrieve.status !== 'success') {
    console.error('[iyzico-checkout-callback] retrieve', retrieve);
    await admin
      .from('iyzico_demo_checkouts')
      .update({
        status: 'failed',
        iyzico_payment_status: String(
          retrieve.errorMessage ?? retrieve.errorCode ?? 'retrieve_fail',
        ),
      })
      .eq('id', row.id);
    return htmlRedirect('failed');
  }

  const payStatus = String(retrieve.paymentStatus ?? '');
  const paidCents = paidPriceToCents(String(retrieve.paidPrice ?? ''));

  if (payStatus.toUpperCase() !== 'SUCCESS') {
    await admin
      .from('iyzico_demo_checkouts')
      .update({
        status: 'failed',
        iyzico_payment_status: payStatus,
      })
      .eq('id', row.id);
    return htmlRedirect('not_paid');
  }

  if (paidCents > 0 && paidCents !== Number(row.amount_cents)) {
    console.error('[iyzico-checkout-callback] amount mismatch', paidCents, row.amount_cents);
    await admin
      .from('iyzico_demo_checkouts')
      .update({
        status: 'failed',
        iyzico_payment_status: 'amount_mismatch',
      })
      .eq('id', row.id);
    return htmlRedirect('amount_mismatch');
  }

  const { data: prof, error: pErr } = await admin
    .from('profiles')
    .select('demo_balance_cents')
    .eq('id', row.profile_id)
    .maybeSingle();
  if (pErr || !prof) {
    return htmlRedirect('profile');
  }

  const add = Number(row.amount_cents);
  const next = (Number(prof.demo_balance_cents) || 0) + add;
  const { error: upErr } = await admin
    .from('profiles')
    .update({ demo_balance_cents: next })
    .eq('id', row.profile_id);
  if (upErr) {
    console.error('[iyzico-checkout-callback] credit', upErr);
    return htmlRedirect('credit_error');
  }

  await admin
    .from('iyzico_demo_checkouts')
    .update({
      status: 'completed',
      iyzico_payment_status: payStatus,
      completed_at: new Date().toISOString(),
    })
    .eq('id', row.id);

  return htmlRedirect('success');
});
