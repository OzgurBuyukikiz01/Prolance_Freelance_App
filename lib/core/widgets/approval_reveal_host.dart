import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/jobs_provider.dart';

/// Shows a blocking dialog when a user-posted job clears moderation; Home stays hidden until dismissed.
class ApprovalRevealHost extends StatefulWidget {
  const ApprovalRevealHost({super.key, required this.child});

  final Widget child;

  @override
  State<ApprovalRevealHost> createState() => _ApprovalRevealHostState();
}

class _ApprovalRevealHostState extends State<ApprovalRevealHost> {
  bool _dialogScheduled = false;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>();
    final head = jobs.pendingApprovalPopupHead;

    if (head != null && !_dialogScheduled) {
      _dialogScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final jobsNotifier = context.read<JobsProvider>();
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final scheme = Theme.of(dialogContext).colorScheme;
            final appState = dialogContext.read<AppState>();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: scheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appState.t('Listing approved', 'İlanınız onaylandı'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  appState.t(
                    '"${head.title}" passed review and is ready on Home.',
                    '"${head.title}" incelamayı geçti; ana sayfada görüntülenebilir.',
                  ),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(appState.t('Continue', 'Devam')),
                ),
              ],
            );
          },
        );
        if (!mounted) return;
        jobsNotifier.dismissPendingApprovalPopup();
        setState(() => _dialogScheduled = false);
      });
    }

    return widget.child;
  }
}
