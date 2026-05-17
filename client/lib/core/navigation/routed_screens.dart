import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/payment/screens/escrow_screen.dart';
import '../../features/reviews/screens/submit_review_screen.dart';
import '../models/job_model.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../state/jobs_provider.dart';

/// Resolves [JobModel] by id from [JobsProvider] for deep links.
class RoutedJobDetailScreen extends StatelessWidget {
  const RoutedJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>().jobs;
    final job = jobs.cast<JobModel?>().firstWhere(
          (j) => j?.id == jobId,
          orElse: () => null,
        );
    if (job == null) {
      return const Scaffold(
        body: Center(child: Text('Job not found')),
      );
    }
    return JobDetailScreen(job: job);
  }
}

/// Chat route with optional query params; falls back to [MessageRepository].
class RoutedChatScreen extends StatelessWidget {
  const RoutedChatScreen({
    super.key,
    required this.conversationId,
    this.query = const {},
  });

  final String conversationId;
  final Map<String, String> query;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MessageRepository>();
    Conversation? conv;
    for (final c in repo.conversations) {
      if (c.id == conversationId) {
        conv = c;
        break;
      }
    }
    final name = query['name'];
    final avatar = query['avatar'];
    final peer = query['peer'];
    return ChatScreen(
      conversationId: conversationId,
      userName: conv?.userName ??
          (name != null && name.isNotEmpty ? Uri.decodeComponent(name) : 'Chat'),
      userAvatar: conv?.userAvatar ??
          (avatar != null ? Uri.decodeComponent(avatar) : ''),
      isOnline: conv?.isOnline ?? false,
      peerUserId: conv?.otherUserId ??
          (peer != null && peer.isNotEmpty ? Uri.decodeComponent(peer) : null),
    );
  }
}

class RoutedEscrowScreen extends StatelessWidget {
  const RoutedEscrowScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>().jobs;
    final job = jobs.cast<JobModel?>().firstWhere(
          (j) => j?.id == jobId,
          orElse: () => null,
        );
    if (job == null) {
      return const Scaffold(
        body: Center(child: Text('Job not found')),
      );
    }
    return EscrowScreen(job: job);
  }
}

class RoutedSubmitReviewScreen extends StatelessWidget {
  const RoutedSubmitReviewScreen({
    super.key,
    required this.jobId,
    required this.query,
  });

  final String jobId;
  final Map<String, String> query;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>().jobs;
    final job = jobs.cast<JobModel?>().firstWhere(
          (j) => j?.id == jobId,
          orElse: () => null,
        );
    if (job == null) {
      return const Scaffold(
        body: Center(child: Text('Job not found')),
      );
    }
    return SubmitReviewScreen(
      job: job,
      revieweeId: query['revieweeId'] ?? '',
      revieweeName: query['revieweeName'] ?? '',
      revieweeAvatar: query['revieweeAvatar'] ?? job.clientAvatar,
    );
  }
}
