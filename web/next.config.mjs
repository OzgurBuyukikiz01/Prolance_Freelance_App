import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const monorepoRoot = path.join(__dirname, '..');
// Only when building from web/ inside a full monorepo checkout (local/CI).
// Vercel Root Directory = web has no parent package-lock; tracing root must stay web/.
const useMonorepoTracingRoot = fs.existsSync(
  path.join(monorepoRoot, 'package-lock.json'),
);

/** @type {import('next').NextConfig} */
const nextConfig = {
  ...(useMonorepoTracingRoot
    ? { outputFileTracingRoot: monorepoRoot }
    : {}),
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
  },
};

export default nextConfig;
