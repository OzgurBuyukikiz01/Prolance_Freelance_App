import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/utils/project_duration_ymd.dart';
import '../../../core/widgets/prolance_empty_state.dart';
import 'proposal_detail_screen.dart';

class MyProposalsScreen extends StatelessWidget {
  const MyProposalsScreen({super.key});

  static bool _canMessageEmployer(SubmittedProposalStatus s) {
    return s == SubmittedProposalStatus.awaitingResponse ||
        s == SubmittedProposalStatus.accepted;
  }

  static void _openEmployerChat(BuildContext context, SubmittedProposal p) {
    final jobs = context.read<JobsProvider>().jobs;
    JobModel? job;
    for (final j in jobs) {
      if (j.id == p.jobId) {
        job = j;
        break;
      }
    }
    final name = job?.clientName ?? 'Employer';
    final avatar =
        job?.clientAvatar ?? 'https://i.pravatar.cc/150?img=12';
    final cid = context.read<MessageRepository>().ensureConversationForJob(
          jobId: p.jobId,
          employerName: name,
          employerAvatar: avatar,
        );
    context.push(
      '/chat/$cid?name=${Uri.encodeComponent(name)}'
      '&avatar=${Uri.encodeComponent(avatar)}',
    );
  }

  static String _statusChipLabel(SubmittedProposalStatus s) {
    switch (s) {
      case SubmittedProposalStatus.awaitingResponse:
        return 'Waiting';
      case SubmittedProposalStatus.accepted:
        return 'Accepted';
      case SubmittedProposalStatus.declined:
        return 'Declined';
      case SubmittedProposalStatus.cancelled:
        return 'Withdrawn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final proposals = context.watch<ProposalRepository>().myProposals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My proposals'),
      ),
      body: proposals.isEmpty
          ? ProlanceEmptyState.proposals()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: proposals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = proposals[index];
                final submitted =
                    DateFormat.yMMMd().add_jm().format(p.submittedAt);
                final preview = p.coverLetter.trim().isEmpty
                    ? 'No cover letter'
                    : p.coverLetter.trim().replaceAll(RegExp(r'\s+'), ' ');
                final snippet = preview.length > 120
                    ? '${preview.substring(0, 120)}…'
                    : preview;

                final delivery = ProjectDurationYmd(
                  p.deliveryYears,
                  p.deliveryMonths,
                  p.deliveryDays,
                ).formatVerbose();

                return Material(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProposalDetailScreen(proposal: p),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Iconsax.briefcase,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.jobTitle,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              if (_canMessageEmployer(p.status))
                                IconButton(
                                  tooltip: 'Message employer',
                                  onPressed: () =>
                                      _openEmployerChat(context, p),
                                  icon: Icon(
                                    Iconsax.message,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${p.bid.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _statusChipLabel(p.status),
                                    style: AppTextStyles.caption.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$delivery · $submitted',
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (p.attachmentNames.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${p.attachmentNames.length} attachment(s)',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            snippet,
                            style: AppTextStyles.bodyMediumSecondary.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
