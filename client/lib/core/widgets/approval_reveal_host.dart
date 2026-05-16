import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/jobs_provider.dart';
import 'overlays/prolance_dialog.dart';

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
        final appState = context.read<AppState>();
        await showProlanceSuccessDialog(
          context,
          barrierDismissible: false,
          title: appState.t('Listing approved', 'İlanınız onaylandı'),
          message: appState.t(
            '"${head.title}" passed review and is ready on Home.',
            '"${head.title}" incelamayı geçti; ana sayfada görüntülenebilir.',
          ),
          buttonLabel: appState.t('Continue', 'Devam'),
        );
        if (!mounted) return;
        jobsNotifier.dismissPendingApprovalPopup();
        setState(() => _dialogScheduled = false);
      });
    }

    return widget.child;
  }
}
