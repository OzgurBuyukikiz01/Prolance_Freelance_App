import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import 'schedule_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.jobId, this.jobTitle});

  final String jobId;
  final String? jobTitle;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<ScheduleItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = ScheduleRepository.fetchForJob(widget.jobId);
  }

  Future<void> _reload() async {
    setState(() {
      _itemsFuture = ScheduleRepository.fetchForJob(widget.jobId);
    });
    await _itemsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = widget.jobTitle?.trim();
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje takvimi'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<ScheduleItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                children: [
                  if (title != null && title.isNotEmpty) ...[
                    Text(title, style: AppTextStyles.heading6),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 48),
                  Icon(Iconsax.calendar, size: 48, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz takvim öğesi yok.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İşveren veya freelancer web portalından kilometre taşları ekleyebilir.',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              itemCount: items.length + (title != null && title.isNotEmpty ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (title != null && title.isNotEmpty && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(title, style: AppTextStyles.heading6),
                  );
                }
                final item = items[index - (title != null && title.isNotEmpty ? 1 : 0)];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.isCompleted ? Iconsax.tick_circle5 : Iconsax.calendar,
                      color: item.isCompleted ? Colors.green : scheme.primary,
                    ),
                    title: Text(
                      item.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        decoration:
                            item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(dateFmt.format(item.dueDate)),
                    trailing: item.isCompleted
                        ? const Text('Tamam', style: TextStyle(fontSize: 12))
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Deep link wrapper with optional job title from query.
class RoutedScheduleScreen extends StatelessWidget {
  const RoutedScheduleScreen({
    super.key,
    required this.jobId,
    this.jobTitle,
  });

  final String jobId;
  final String? jobTitle;

  @override
  Widget build(BuildContext context) {
    return ScheduleScreen(jobId: jobId, jobTitle: jobTitle);
  }
}
