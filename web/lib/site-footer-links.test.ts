import { describe, expect, it } from 'vitest';
import {
  FOOTER_LINK_GROUPS,
  FOOTER_SOCIAL_PLACEHOLDER_HREFS,
  FOOTER_STATIC_ROUTES,
  getAllFooterNavHrefs,
  getAllFooterNavLinks,
} from './site-footer-links';

describe('site-footer-links', () => {
  it('exports all navigation hrefs without bare # placeholders', () => {
    for (const href of getAllFooterNavHrefs()) {
      expect(href).not.toBe('#');
      expect(FOOTER_SOCIAL_PLACEHOLDER_HREFS).not.toContain(href);
    }
  });

  it('matches known static marketing and legal routes', () => {
    const allowed = new Set<string>(FOOTER_STATIC_ROUTES);
    for (const href of getAllFooterNavHrefs()) {
      expect(allowed.has(href)).toBe(true);
    }
  });

  it('includes company and legal pages as real paths', () => {
    const hrefs = getAllFooterNavHrefs();
    expect(hrefs).toContain('/about');
    expect(hrefs).toContain('/blog');
    expect(hrefs).toContain('/contact');
    expect(hrefs).toContain('/cookies');
    expect(hrefs).toContain('/privacy');
    expect(hrefs).toContain('/terms');
  });

  it('has three link groups with expected labels', () => {
    expect(Object.keys(FOOTER_LINK_GROUPS)).toEqual(['Ürün', 'Şirket', 'Hukuk']);
    expect(getAllFooterNavLinks().length).toBe(9);
  });
});
