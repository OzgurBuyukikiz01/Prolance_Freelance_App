import { describe, expect, it } from 'vitest';
import { formatCount, formatEscrowBand, formatRating } from './landing-stats';

describe('formatCount', () => {
  it('formats millions', () => {
    expect(formatCount(1_500_000)).toBe('1.5M+');
    expect(formatCount(2_000_000)).toBe('2M+');
  });

  it('formats thousands', () => {
    expect(formatCount(12_500)).toBe('12K+');
    expect(formatCount(1_200)).toBe('1.2K+');
  });

  it('formats small positive counts', () => {
    expect(formatCount(42)).toBe('42+');
  });

  it('returns em dash for zero', () => {
    expect(formatCount(0)).toBe('—');
  });
});

describe('formatEscrowBand', () => {
  it('clamps below 10M to ₺10M+', () => {
    expect(formatEscrowBand(5_000_000)).toBe('₺10M+');
    expect(formatEscrowBand(0)).toBe('₺10M+');
  });

  it('clamps above 20M to ₺20M+', () => {
    expect(formatEscrowBand(25_000_000)).toBe('₺20M+');
  });

  it('formats values within 10M–20M band', () => {
    expect(formatEscrowBand(10_000_000)).toBe('₺10M+');
    expect(formatEscrowBand(15_000_000)).toBe('₺15M+');
    expect(formatEscrowBand(20_000_000)).toBe('₺20M+');
  });
});

describe('formatRating', () => {
  it('uses 4.9 when review count is below 10', () => {
    expect(formatRating(4.2, 9)).toBe('4.9★');
    expect(formatRating(5, 0)).toBe('4.9★');
  });

  it('uses actual average when review count is 10 or more', () => {
    expect(formatRating(4.7, 10)).toBe('4.7★');
    expect(formatRating(4.76, 100)).toBe('4.8★');
  });
});
