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
import '../../../core/state/app_state.dart';
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
    final avatar = job?.clientAvatar ?? 'https://i.pravatar.cc/150?img=12';
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

  Widget _buildFreelancerCard(
    BuildContext context,
    ColorScheme scheme,
    SubmittedProposal p,
  ) {
    final submitted = DateFormat.yMMMd().add_jm().format(p.submittedAt);
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
                      onPressed: () => _openEmployerChat(context, p),
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
                        p.workflowLabel,
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
  }

  Widget _buildClientIncomingCard(
    BuildContext context,
    ColorScheme scheme,
    AppState app,
    ClientIncomingProposal p,
  ) {
    final submitted = DateFormat.yMMMd().add_jm().format(p.createdAt);
    final preview = p.coverLetter.trim().isEmpty
        ? 'No cover letter'
        : p.coverLetter.trim().replaceAll(RegExp(r'\s+'), ' ');
    final snippet = preview.length > 120
        ? '${preview.substring(0, 120)}…'
        : preview;

    final canReview = p.status == 'accepted' &&
        (p.lifecyclePhase == ProposalLifecycle.awaitingClientReview ||
            p.lifecyclePhase == ProposalLifecycle.delivered ||
            p.lifecyclePhase == ProposalLifecycle.payoutPending);

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.user, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.freelancerName.isEmpty ? 'Freelancer' : p.freelancerName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.jobTitle,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
                      p.workflowLabel,
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
              '${p.deliveryDays} days · $submitted',
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              snippet,
              style: AppTextStyles.bodyMediumSecondary.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (canReview) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/review-delivery/${p.proposalId}'),
                  icon: const Icon(Iconsax.tick_square, size: 20),
                  label: Text(
                    app.t('Accept delivery', 'Teslimi kabul et'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();
    final proposals = context.watch<ProposalRepository>().myProposals;
    final incoming = context.watch<ProposalRepository>().clientIncoming;
    final repo = context.read<ProposalRepository>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My proposals'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My submissions'),
              Tab(text: 'As client'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () => repo.reloadFromRemote(),
              child: proposals.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
                        ProlanceEmptyState.proposals(),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: proposals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = proposals[index];
                        final card = _buildFreelancerCard(context, scheme, p);
                        if (!repo.canSwipeDismiss(p.status)) {
                          return card;
                        }
                        return Dismissible(
                          key: ValueKey('proposal_swipe_${p.id}'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            await repo.dismissFromMyList(p.id);
                            return true;
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Iconsax.trash,
                              color: scheme.onErrorContainer,
                              size: 26,
                            ),
                          ),
                          child: card,
                        );
                      },
                    ),
            ),
            RefreshIndicator(
              onRefresh: () => repo.reloadFromRemote(),
              child: incoming.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'When freelancers submit proposals on your jobs, they appear here.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMediumSecondary.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: incoming.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = incoming[index];
                        return _buildClientIncomingCard(context, scheme, app, p);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
