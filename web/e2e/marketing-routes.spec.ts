import { test, expect } from '@playwright/test';
import { blogPosts } from '../content/blog/posts';

const marketingRoutes = [
  '/',
  '/about',
  '/blog',
  '/contact',
  '/cookies',
  '/privacy',
  '/terms',
] as const;

for (const route of marketingRoutes) {
  test(`GET ${route} returns 200`, async ({ page }) => {
    const response = await page.goto(route);
    expect(response?.ok()).toBeTruthy();
  });
}

for (const post of blogPosts) {
  test(`GET /blog/${post.slug} returns 200`, async ({ page }) => {
    const response = await page.goto(`/blog/${post.slug}`);
    expect(response?.ok()).toBeTruthy();
    await expect(page.locator('h1')).toContainText(post.title);
  });
}

test('footer company link navigates to /about', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'Hakkımızda' }).click();
  await expect(page).toHaveURL(/\/about$/);
});
