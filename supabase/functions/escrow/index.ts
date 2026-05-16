// Supabase Edge Function: escrow state transitions (mock PSP).
// deno run --allow-all (local) or deploy via `supabase functions deploy escrow`

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { unknownOpResponse, validateOp } from './validate.ts';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } },
  );

  try {
    const body = await req.json();
    const op = body.op as string;
    const escrowId = body.escrowId as string;
    const reason = (body.reason as string) ?? '';

    if (!validateOp(op)) {
      return unknownOpResponse(cors);
    }

    if (op === 'release') {
      await supabase
        .from('escrow_transactions')
        .update({ status: 'RELEASED' })
        .eq('id', escrowId);
    } else {
      await supabase
        .from('escrow_transactions')
        .update({ status: 'DISPUTED', dispute_reason: reason })
        .eq('id', escrowId);
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: `${e}` }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
