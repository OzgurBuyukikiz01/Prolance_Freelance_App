import { test, expect } from '@playwright/test';

const protectedPortalRoutes = ['/portal', '/portal/support', '/portal/jobs/new'] as const;

test('GET /login returns 200 and shows auth form', async ({ page }) => {
  const response = await page.goto('/login');
  expect(response?.ok()).toBeTruthy();
  await expect(page.getByRole('button', { name: 'Giriş Yap' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Kayıt Ol' })).toBeVisible();
});

test('GET /login?tab=signup returns 200', async ({ page }) => {
  const response = await page.goto('/login?tab=signup');
  expect(response?.ok()).toBeTruthy();
  await expect(page.getByRole('button', { name: 'Kayıt Ol' })).toBeVisible();
});

for (const route of protectedPortalRoutes) {
  test(`unauthenticated GET ${route} redirects to /login`, async ({ page }) => {
    await page.goto(route);
    await expect(page).toHaveURL(/\/login/);
  });
}

test('GET /admin/login returns 200', async ({ page }) => {
  const response = await page.goto('/admin/login');
  expect(response?.ok()).toBeTruthy();
});

test('unauthenticated GET /dashboard redirects to /admin/login', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveURL(/\/admin\/login/);
});
