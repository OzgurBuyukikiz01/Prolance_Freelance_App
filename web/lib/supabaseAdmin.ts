import { createClient } from '@supabase/supabase-js';

import {
  getSupabaseServiceRoleKey,
  getSupabaseUrl,
} from '@/lib/supabase/env';

export function createServiceClient() {
  return createClient(getSupabaseUrl(), getSupabaseServiceRoleKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/**
 * Write an entry to admin_audit_log.
 * Uses the service client (bypasses RLS).
 */
export async function logAudit(
  adminId: string,
  action: string,
  entityId: string,
  detail: string,
  entityType = action,
) {
  const sb = createServiceClient();
  const { error } = await sb.from('admin_audit_log').insert({
    admin_id: adminId,
    action,
    entity_type: entityType,
    entity_id: entityId,
    details: { detail },
  });
  if (error) {
    console.error('[logAudit] failed:', error.message);
  }
}
