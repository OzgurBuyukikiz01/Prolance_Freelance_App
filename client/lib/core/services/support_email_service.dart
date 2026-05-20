import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Calls Edge Function `send-support-email` (Resend). API key stays on the server.
class SupportEmailService {
  SupportEmailService._();

  /// Returns `true` if email was sent or intentionally skipped (misconfigured).
  /// Returns `false` on transport / Resend errors (ticket may still be in DB).
  static Future<bool> sendSupportEmail({
    required String subject,
    required String body,
    required String priority,
    required String contactEmail,
    String source = 'support_ticket',
  }) async {
    if (!SupabaseConfig.isEnabled) return true;
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'send-support-email',
        body: {
          'subject': subject,
          'body': body,
          'priority': priority,
          'source': source,
          'contactEmail': contactEmail,
        },
      );
      final data = res.data;
      if (data is Map) {
        if (data['ok'] == true || data['skipped'] == true) return true;
        if (data['error'] != null) {
          debugPrint('[SupportEmailService] error payload: $data');
          return false;
        }
      }
      return true;
    } catch (e, st) {
      debugPrint('[SupportEmailService] $e\n$st');
      return false;
    }
  }
}
