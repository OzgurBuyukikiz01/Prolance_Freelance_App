import { describe, expect, it } from 'vitest';
import { blogPosts, getPostBySlug, getRelatedPosts } from './posts';

describe('blog posts', () => {
  it('has unique slugs', () => {
    const slugs = blogPosts.map((p) => p.slug);
    expect(new Set(slugs).size).toBe(slugs.length);
    expect(slugs.length).toBeGreaterThanOrEqual(3);
  });

  it('getPostBySlug returns the matching post', () => {
    const slug = blogPosts[0].slug;
    expect(getPostBySlug(slug)?.slug).toBe(slug);
    expect(getPostBySlug('nonexistent-slug')).toBeUndefined();
  });

  it('getRelatedPosts excludes current post and respects limit', () => {
    const post = blogPosts[0];
    const related = getRelatedPosts(post, 2);
    expect(related.length).toBeLessThanOrEqual(2);
    expect(related.every((p) => p.slug !== post.slug)).toBe(true);
  });

  it('falls back to publish date when no shared tags', () => {
    const escrowPost = blogPosts.find((p) => p.slug === 'escrow-ile-guvenli-odeme');
    expect(escrowPost).toBeDefined();
    const related = getRelatedPosts(escrowPost!, 1);
    expect(related).toHaveLength(1);
    expect(related[0].slug).toBe('freelancer-verimlilik-ipuclari');
  });
});
