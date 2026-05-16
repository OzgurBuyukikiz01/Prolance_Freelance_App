import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../features/jobs/screens/submit_proposal_screen.dart';
import '../models/job_model.dart';

/// Shared-axis transition into submit proposal (Material motion).
Route<void> submitProposalRoute(JobModel job) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SubmitProposalScreen(job: job);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}
