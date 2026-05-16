/** Local Supabase CLI defaults (matches Flutter `SupabaseConfig` and `supabase start`). */
const LOCAL_URL = 'http://127.0.0.1:54321';
const LOCAL_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const LOCAL_SERVICE_ROLE_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const LOCAL_SITE_URL = 'http://localhost:3000';

function isPlaceholder(value: string | undefined): boolean {
  if (!value?.trim()) return true;
  const v = value.trim();
  return v.includes('YOUR_PROJECT') || v.includes('YOUR_SUPABASE') || v.includes('your_');
}

export function getSupabaseUrl(): string {
  const fromEnv = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim();
  if (fromEnv && !isPlaceholder(fromEnv)) return fromEnv;
  return LOCAL_URL;
}

export function getSupabaseAnonKey(): string {
  const fromEnv = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim();
  if (fromEnv && !isPlaceholder(fromEnv)) return fromEnv;
  return LOCAL_ANON_KEY;
}

export function getSupabaseServiceRoleKey(): string {
  const fromEnv = process.env.SUPABASE_SERVICE_ROLE_KEY?.trim();
  if (fromEnv && !isPlaceholder(fromEnv)) return fromEnv;
  return LOCAL_SERVICE_ROLE_KEY;
}

/** Canonical app origin for OAuth, emails, and absolute links (no trailing slash). */
export function getSiteUrl(): string {
  const fromEnv = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (fromEnv && !isPlaceholder(fromEnv)) return fromEnv.replace(/\/$/, '');
  return LOCAL_SITE_URL;
}