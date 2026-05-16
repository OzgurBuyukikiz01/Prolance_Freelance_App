export const VALID_ESCROW_OPS = ['release', 'dispute'] as const;

export type EscrowOp = (typeof VALID_ESCROW_OPS)[number];

export function validateOp(op: unknown): op is EscrowOp {
  return typeof op === 'string' && (VALID_ESCROW_OPS as readonly string[]).includes(op);
}

export function unknownOpResponse(
  cors: Record<string, string>,
): Response {
  return new Response(JSON.stringify({ error: 'unknown op' }), {
    status: 400,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}
