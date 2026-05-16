import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { unknownOpResponse, validateOp } from './validate.ts';

Deno.test('validateOp accepts release and dispute', () => {
  assertEquals(validateOp('release'), true);
  assertEquals(validateOp('dispute'), true);
});

Deno.test('validateOp rejects unknown operations', () => {
  assertEquals(validateOp('refund'), false);
  assertEquals(validateOp(''), false);
  assertEquals(validateOp(null), false);
  assertEquals(validateOp(undefined), false);
});

Deno.test('unknownOpResponse returns 400 with error body', async () => {
  const cors = { 'Access-Control-Allow-Origin': '*' };
  const res = unknownOpResponse(cors);
  assertEquals(res.status, 400);
  const body = await res.json();
  assertEquals(body, { error: 'unknown op' });
});
