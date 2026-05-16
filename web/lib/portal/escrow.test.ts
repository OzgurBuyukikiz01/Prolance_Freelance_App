import { describe, expect, it } from 'vitest';
import { getEscrowStatusMeta } from './escrow';

describe('getEscrowStatusMeta', () => {
  it('labels HELD and allows dispute', () => {
    const meta = getEscrowStatusMeta('HELD');
    expect(meta.label).toBe('Escrow’da');
    expect(meta.canDispute).toBe(true);
  });

  it('disallows dispute after release', () => {
    expect(getEscrowStatusMeta('RELEASED').canDispute).toBe(false);
    expect(getEscrowStatusMeta('DISPUTED').canDispute).toBe(false);
  });
});
