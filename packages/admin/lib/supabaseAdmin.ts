import { createClient } from '@supabase/supabase-js';

export function createServiceClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY!;
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/**
 * Write an entry to admin_audit_log.
 * Uses the service client (bypasses RLS).
 *
 * @param adminId  UUID of the admin performing the action
 * @param action   Short action name, e.g. 'ticket_update', 'user_banned'
 * @param entityId UUID / ID of the affected record
 * @param detail   Human-readable description
 * @param entityType Optional: table name of the affected record
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
