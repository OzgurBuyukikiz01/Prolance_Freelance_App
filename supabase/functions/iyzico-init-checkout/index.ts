// @ts-nocheck
/**
 * iyzico Checkout Form — initialize (sandbox). Keys only in Edge secrets.
 * npm:iyzipay builds auth + JSON like official SDK.
 */
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import Iyzipay from 'npm:iyzipay@2.0.67';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function tryLira(cents: number): string {
  return (cents / 100).toFixed(2);
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

  const apiKey = Deno.env.get('IYZICO_API_KEY') ?? '';
  const secretKey = Deno.env.get('IYZICO_SECRET_KEY') ?? '';
  const baseUri =
    Deno.env.get('IYZICO_URI') ?? 'https://sandbox-api.iyzipay.com';
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnon = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

  if (!apiKey || !secretKey || !serviceRole || !supabaseUrl || !supabaseAnon) {
    return new Response(
      JSON.stringify({
        error: 'iyzico_not_configured',
        hint:
          'Set IYZICO_API_KEY, IYZICO_SECRET_KEY, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_URL, SUPABASE_ANON_KEY.',
      }),
      { status: 503, headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const userClient = createClient(supabaseUrl, supabaseAnon, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: userErr,
  } = await userClient.auth.getUser();
  if (userErr || !user) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), {
      status: 401,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  let body: { amount_cents?: number };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: 'invalid_json' }), {
      status: 400,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const raw = Number(body.amount_cents);
  if (!Number.isFinite(raw) || raw < 100 || raw > 10_000_000) {
    return new Response(
      JSON.stringify({ error: 'invalid_amount' }),
      { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  }
  const amountCents = Math.floor(raw);
  const priceStr = tryLira(amountCents);

  const conversationId = `pl${user.id.replace(/-/g, '').slice(0, 12)}_${Date.now()}`.slice(
    0,
    64,
  );
  const basketId = `basket_${conversationId}`.slice(0, 64);

  const admin = createClient(supabaseUrl, serviceRole);
  const { error: insErr } = await admin.from('iyzico_demo_checkouts').insert({
    profile_id: user.id,
    conversation_id: conversationId,
    amount_cents: amountCents,
    status: 'pending',
  });
  if (insErr) {
    console.error('[iyzico-init-checkout] insert', insErr);
    return new Response(JSON.stringify({ error: 'db_insert_failed' }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const { data: prof } = await userClient
    .from('profiles')
    .select('full_name')
    .eq('id', user.id)
    .maybeSingle();
  const full = ((prof?.full_name as string) ?? 'Prolance User').trim();
  const [namePart, ...rest] = full.split(/\s+/);
  const name = namePart || 'User';
  const surname = rest.join(' ') || 'Demo';
  const email = user.email ?? `${user.id}@users.invalid`;

  const callbackUrl = `${supabaseUrl.replace(/\/+$/, '')}/functions/v1/iyzico-checkout-callback`;

  const iyzipay = new Iyzipay({
    apiKey,
    secretKey,
    uri: baseUri,
  });

  const request = {
    locale: Iyzipay.LOCALE.TR,
    conversationId,
    price: priceStr,
    paidPrice: priceStr,
    currency: Iyzipay.CURRENCY.TRY,
    basketId,
    paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
    callbackUrl,
    enabledInstallments: [2, 3, 6, 9],
    buyer: {
      id: user.id,
      name,
      surname,
      gsmNumber: '+905551234567',
      email,
      identityNumber: '11111111111',
      lastLoginDate: '2020-05-01 12:00:00',
      registrationDate: '2020-05-01 12:00:00',
      registrationAddress: 'Demo address Istanbul',
      ip: '85.34.78.112',
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000',
    },
    shippingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Demo shipping address',
      zipCode: '34000',
    },
    billingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Demo billing address',
      zipCode: '34000',
    },
    basketItems: [
      {
        id: 'DEMO1',
        name: 'Prolance demo bakiye',
        category1: 'Wallet',
        category2: 'Demo',
        itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
        price: priceStr,
      },
    ],
  };

  const result: Record<string, unknown> = await new Promise((resolve, reject) => {
    try {
      iyzipay.checkoutFormInitialize.create(
        request,
        (err: Error | null, res: Record<string, unknown>) => {
          if (err) reject(err);
          else resolve(res ?? {});
        },
      );
    } catch (e) {
      reject(e);
    }
  });

  if (result.status !== 'success') {
    await admin.from('iyzico_demo_checkouts').delete().eq('conversation_id', conversationId);
    console.error('[iyzico-init-checkout] iyzico', result);
    return new Response(
      JSON.stringify({
        error: 'iyzico_init_failed',
        details: result.errorMessage ?? result.errorCode ?? result,
      }),
      { status: 502, headers: { ...cors, 'Content-Type': 'application/json' } },
    );
  }

  const checkoutToken = String(result.token ?? '');
  if (!checkoutToken) {
    await admin.from('iyzico_demo_checkouts').delete().eq('conversation_id', conversationId);
    return new Response(JSON.stringify({ error: 'no_checkout_token' }), {
      status: 502,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  await admin
    .from('iyzico_demo_checkouts')
    .update({ checkout_token: checkoutToken })
    .eq('conversation_id', conversationId);

  const paymentPageUrl = String(result.paymentPageUrl ?? '');
  return new Response(
    JSON.stringify({
      paymentPageUrl,
      conversationId,
      token: checkoutToken,
    }),
    { headers: { ...cors, 'Content-Type': 'application/json' } },
  );
});
