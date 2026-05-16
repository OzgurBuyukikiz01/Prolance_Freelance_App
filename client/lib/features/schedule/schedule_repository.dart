import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.completedAt,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}

/// Reads `job_schedule_items` for a job (portal calendar parity).
class ScheduleRepository {
  ScheduleRepository._();

  static Future<List<ScheduleItem>> fetchForJob(String jobId) async {
    if (!SupabaseConfig.isEnabled) return [];

    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('job_schedule_items')
          .select('id, title, due_date, completed_at')
          .eq('job_id', jobId)
          .order('due_date', ascending: true);

      return (rows as List<dynamic>).map((raw) {
        final row = raw as Map<String, dynamic>;
        return ScheduleItem(
          id: '${row['id']}',
          title: row['title'] as String,
          dueDate: DateTime.parse('${row['due_date']}'),
          completedAt: row['completed_at'] != null
              ? DateTime.parse('${row['completed_at']}')
              : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
