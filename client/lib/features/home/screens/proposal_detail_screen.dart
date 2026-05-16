import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/utils/project_duration_ymd.dart';

class ProposalDetailScreen extends StatelessWidget {
  const ProposalDetailScreen({super.key, required this.proposal});

  final SubmittedProposal proposal;

  JobModel? _resolveJob(JobsProvider jobs) {
    for (final j in jobs.jobs) {
      if (j.id == proposal.jobId) return j;
    }
    return null;
  }

  String _deliveryLabel(SubmittedProposal p) {
    final d = ProjectDurationYmd(
      p.deliveryYears,
      p.deliveryMonths,
      p.deliveryDays,
    );
    return d.formatVerbose();
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} – \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} – \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProposalRepository>();
    var current = proposal;
    for (final x in repo.myProposals) {
      if (x.id == proposal.id) {
        current = x;
        break;
      }
    }
    final job = _resolveJob(context.watch<JobsProvider>());
    final submitted =
        DateFormat.yMMMd().add_jm().format(current.submittedAt);

    final active = current.status == SubmittedProposalStatus.awaitingResponse;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        children: [
          Text(
            'Job',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: job == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.jobTitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This job is no longer in your local job list. Title is kept from when you applied.',
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.category,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Budget: ${_formatBudget(job)}',
                          style: AppTextStyles.bodySmallSecondary.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: AppTextStyles.bodyMediumSecondary.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Your proposal',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${current.bid.toStringAsFixed(0)}',
                        style: AppTextStyles.heading6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        submitted,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.calendar,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery: ${_deliveryLabel(current)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMd),
                  Text(
                    'Cover letter',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    current.coverLetter.trim().isEmpty
                        ? '—'
                        : current.coverLetter,
                    style: AppTextStyles.bodyMediumSecondary.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (current.attachmentNames.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      'Attachments',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...current.attachmentNames.map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Iconsax.document,
                                size: 16, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(child: Text(n)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Progress',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 12),
          _ProgressTimeline(status: current.status),
          const SizedBox(height: AppConstants.paddingXl),
          if (active)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final appState = context.read<AppState>();
                  final ok = await showProlanceDestructiveDialog(
                        context,
                        title: appState.t('Cancel proposal', 'Teklifi iptal et'),
                        message: appState.t(
                          'Withdraw this proposal? The client will no longer see it.',
                          'Bu teklifi geri çekmek istiyor musunuz? İşveren artık göremeyecek.',
                        ),
                        destructiveLabel: appState.t('Withdraw', 'Geri çek'),
                        cancelLabel: appState.t('Keep', 'Vazgeç'),
                        icon: Iconsax.close_circle,
                      ) ??
                      false;
                  if (!ok || !context.mounted) return;
                  await repo.cancelProposal(current.id);
                },
                icon: Icon(Iconsax.close_circle, color: AppColors.error),
                label: Text(
                  'Cancel proposal',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingMd,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({required this.status});

  final SubmittedProposalStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case SubmittedProposalStatus.awaitingResponse:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Waiting for client',
              subtitle: 'The client has not accepted or declined yet.',
              opacity: 1,
              tone: _StepTone.active,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Decision',
              subtitle: 'Pending response',
              opacity: 0.5,
              tone: _StepTone.upcoming,
            ),
          ],
        );
      case SubmittedProposalStatus.accepted:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Client reviewed',
              subtitle: 'The client viewed your proposal.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Accepted',
              subtitle: 'Congratulations — this proposal was accepted.',
              opacity: 1,
              tone: _StepTone.successEnd,
            ),
          ],
        );
      case SubmittedProposalStatus.declined:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Client reviewed',
              subtitle: 'The client viewed your proposal.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Declined',
              subtitle: 'The client declined this proposal.',
              opacity: 1,
              tone: _StepTone.failedEnd,
            ),
          ],
        );
      case SubmittedProposalStatus.cancelled:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Withdrawn',
              subtitle: 'You cancelled this proposal before a decision.',
              opacity: 1,
              tone: _StepTone.neutral,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Closed',
              subtitle: 'No further action from the client.',
              opacity: 0.5,
              tone: _StepTone.upcoming,
            ),
          ],
        );
    }
  }
}

enum _StepTone { passed, active, upcoming, successEnd, failedEnd, neutral }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.scheme,
    required this.title,
    required this.subtitle,
    required this.opacity,
    required this.tone,
  });

  final ColorScheme scheme;
  final String title;
  final String subtitle;
  final double opacity;
  final _StepTone tone;

  Color _leadingColor() {
    switch (tone) {
      case _StepTone.passed:
      case _StepTone.successEnd:
        return AppColors.success;
      case _StepTone.failedEnd:
        return AppColors.error;
      case _StepTone.active:
        return AppColors.primary;
      case _StepTone.upcoming:
        return scheme.outline;
      case _StepTone.neutral:
        return scheme.onSurfaceVariant;
    }
  }

  IconData _leadingIcon() {
    switch (tone) {
      case _StepTone.passed:
      case _StepTone.successEnd:
        return Iconsax.tick_circle;
      case _StepTone.failedEnd:
        return Iconsax.close_circle;
      case _StepTone.active:
        return Iconsax.clock;
      case _StepTone.upcoming:
        return Icons.more_horiz;
      case _StepTone.neutral:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _leadingColor();
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_leadingIcon(), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tone == _StepTone.upcoming
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
