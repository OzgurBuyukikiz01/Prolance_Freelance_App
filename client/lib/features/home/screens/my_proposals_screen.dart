import 'dart:async';

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

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  Timer? _ticker;
  String? _busyProposalId;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static bool _canMessageEmployer(SubmittedProposalStatus s) {
    return s == SubmittedProposalStatus.awaitingResponse ||
        s == SubmittedProposalStatus.accepted;
  }

  Future<void> _openEmployerChat(
    BuildContext context,
    SubmittedProposal p,
  ) async {
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
    final repo = context.read<MessageRepository>();
    String cid;
    final clientId = job?.clientId;
    if (clientId != null && clientId.isNotEmpty) {
      final directId = await repo.ensureDirectConversation(
        otherUserId: clientId,
      );
      if (directId.startsWith('local_dm_')) {
        cid = repo.ensureConversationForJob(
          jobId: p.jobId,
          employerName: name,
          employerAvatar: avatar,
        );
      } else {
        cid = directId;
      }
    } else {
      cid = repo.ensureConversationForJob(
        jobId: p.jobId,
        employerName: name,
        employerAvatar: avatar,
      );
    }
    if (!context.mounted) return;
    context.push(
      '/chat/$cid?name=${Uri.encodeComponent(name)}'
      '&avatar=${Uri.encodeComponent(avatar)}'
      '&peer=${Uri.encodeComponent(clientId ?? '')}',
    );
  }

  String _formatLiveCountdown(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) return '0m';
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  Future<void> _acceptClientProposal(
    BuildContext context,
    ClientIncomingProposal proposal,
  ) async {
    setState(() => _busyProposalId = proposal.proposalId);
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    final ok = await repo.acceptProposal(
      proposalId: proposal.proposalId,
      jobId: proposal.jobId,
      freelancerId: proposal.freelancerId,
      bid: proposal.bid,
    );
    if (!mounted) return;
    setState(() => _busyProposalId = null);
    if (ok) {
      await repo.reloadFromRemote();
      await app.refreshProfileFromServer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal accepted. Contract is now live.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not accept proposal.')));
  }

  Future<void> _rejectClientProposal(
    BuildContext context,
    ClientIncomingProposal proposal,
  ) async {
    setState(() => _busyProposalId = proposal.proposalId);
    final repo = context.read<ProposalRepository>();
    final ok = await repo.rejectProposal(proposal.proposalId);
    if (!mounted) return;
    setState(() => _busyProposalId = null);
    if (ok) {
      await repo.reloadFromRemote();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proposal declined.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not decline proposal.')),
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
                  Icon(Iconsax.briefcase, color: AppColors.primary, size: 22),
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

    final canAcceptDelivery =
        p.status == 'accepted' &&
        (p.lifecyclePhase == ProposalLifecycle.awaitingClientReview ||
            p.lifecyclePhase == ProposalLifecycle.delivered);

    final completedDeliveryAsClient =
        p.status == 'accepted' &&
        p.lifecyclePhase != ProposalLifecycle.disputed &&
        (p.lifecyclePhase == ProposalLifecycle.payoutPending ||
            p.lifecyclePhase == ProposalLifecycle.closed);

    final deliveryDeadline = p.deliveryDisputeDeadline;
    final within24hDisputeWindow =
        deliveryDeadline != null &&
        DateTime.now().isBefore(deliveryDeadline) &&
        p.lifecyclePhase == ProposalLifecycle.payoutPending &&
        !p.payoutFinalized;

    final showReportWithPreview =
        completedDeliveryAsClient && within24hDisputeWindow;
    final busy = _busyProposalId == p.proposalId;

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
                        p.freelancerName.isEmpty
                            ? 'Freelancer'
                            : p.freelancerName,
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
            if (p.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => _rejectClientProposal(context, p),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(app.t('Decline', 'Reddet')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: busy
                          ? null
                          : () => _acceptClientProposal(context, p),
                      child: Text(app.t('Accept proposal', 'Teklifi kabul et')),
                    ),
                  ),
                ],
              ),
            ],
            if (canAcceptDelivery) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/review-delivery/${p.proposalId}'),
                  icon: const Icon(Iconsax.tick_square, size: 20),
                  label: Text(app.t('Accept delivery', 'Teslimi kabul et')),
                ),
              ),
            ],
            if (completedDeliveryAsClient) ...[
              const SizedBox(height: 12),
              if (showReportWithPreview) ...[
                Text(
                  app.t(
                    'Dispute window: ${_formatLiveCountdown(deliveryDeadline!)}',
                    'İtiraz süresi: ${_formatLiveCountdown(deliveryDeadline!)}',
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/review-delivery/${p.proposalId}'),
                      child: Text(app.t('Preview', 'Önizle')),
                    ),
                  ),
                  if (showReportWithPreview) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/report-delivery-issue/${p.proposalId}',
                        ),
                        icon: Icon(
                          Iconsax.warning_2,
                          size: 18,
                          color: scheme.error,
                        ),
                        label: Text(
                          app.t('Report an issue', 'Sorun bildir'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
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
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.22,
                        ),
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
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.22,
                        ),
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
                        return _buildClientIncomingCard(
                          context,
                          scheme,
                          app,
                          p,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
