import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/overlays/prolance_bottom_sheet.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

/// Rich bottom-sheet modal with 3 tabs: Summary / Client / Proposal
void showJobDetailBottomSheet(BuildContext context, JobModel job) {
  showProlanceBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    showTitleBar: false,
    child: SafeArea(top: false, child: JobDetailBottomSheet(job: job)),
  );
}

class JobDetailBottomSheet extends StatelessWidget {
  const JobDetailBottomSheet({super.key, required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Handle + header
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: job.clientAvatar,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(
                                  Iconsax.user,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick action row
                    _QuickActionsRow(job: job),
                    const SizedBox(height: 8),
                    // Tab bar
                    TabBar(
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: scheme.onSurfaceVariant,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Summary'),
                        Tab(text: 'Client'),
                        Tab(text: 'Proposal'),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _SummaryTab(job: job, scrollController: scrollController),
                    _ClientTab(job: job),
                    _ProposalTab(job: job),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.job});
  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Iconsax.share,
            label: 'Share',
            onTap: () => Share.share(
              '${job.title}\n${job.category}\n— Prolance',
              subject: job.title,
            ),
          ),
          _QuickAction(
            icon: Iconsax.heart,
            label: 'Save',
            onTap: () {
              context.read<JobsProvider>().toggleFavorite(job.id, true);
              ProlanceMessenger.success(
                context,
                context.read<AppState>().t('Job saved', 'İlan kaydedildi'),
              );
            },
          ),
          _QuickAction(
            icon: Iconsax.message_2,
            label: 'Message',
            onTap: () {
              final repo = context.read<MessageRepository>();
              final convId = repo.ensureConversationForJob(
                jobId: job.id,
                employerName: job.clientName,
                employerAvatar: job.clientAvatar,
              );
              context.push(
                '/chat/$convId?name=${Uri.encodeComponent(job.clientName)}'
                '&avatar=${Uri.encodeComponent(job.clientAvatar)}',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Summary
// ---------------------------------------------------------------------------
class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.job, required this.scrollController});
  final JobModel job;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Budget badge
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Iconsax.dollar_circle,
              label: job.budgetType == 'hourly'
                  ? '\$${job.budgetMin.toInt()}–\$${job.budgetMax.toInt()}/hr'
                  : '\$${job.budgetMin.toInt()}–\$${job.budgetMax.toInt()}',
            ),
            _InfoChip(icon: Iconsax.clock, label: job.duration),
            _InfoChip(icon: Iconsax.crown, label: job.experienceLevel),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          job.description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: scheme.onSurface,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        if (job.skills.isNotEmpty) ...[
          Text(
            'Required skills',
            style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.skills
                .map(
                  (s) => Chip(
                    label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Client
// ---------------------------------------------------------------------------
class _ClientTab extends StatelessWidget {
  const _ClientTab({required this.job});
  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: job.clientAvatar,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      color: scheme.surfaceContainerHighest,
                      child: const Icon(Iconsax.user, size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.clientName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: 4.5,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star_rounded, color: Colors.amber),
                        itemSize: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified client',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Message button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final repo = context.read<MessageRepository>();
                final convId = repo.ensureConversationForJob(
                  jobId: job.id,
                  employerName: job.clientName,
                  employerAvatar: job.clientAvatar,
                );
                Navigator.pop(context);
                context.push(
                  '/chat/$convId?name=${Uri.encodeComponent(job.clientName)}'
                  '&avatar=${Uri.encodeComponent(job.clientAvatar)}',
                );
              },
              icon: const Icon(Iconsax.message_2),
              label: const Text('Send message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Proposal
// ---------------------------------------------------------------------------
class _ProposalTab extends StatefulWidget {
  const _ProposalTab({required this.job});
  final JobModel job;

  @override
  State<_ProposalTab> createState() => _ProposalTabState();
}

class _ProposalTabState extends State<_ProposalTab> {
  final _coverController = TextEditingController();
  final _priceController = TextEditingController();
  bool _submitted = false;
  List<JobProposalRow> _incoming = [];
  bool _loadingIncoming = false;
  String? _actingOnProposalId;

  bool get _isJobOwner {
    final user = context.read<AppState>().currentUser;
    return context.read<JobsProvider>().isOwnedByCurrentUser(
      widget.job,
      user.id,
      fallbackUserName: user.name,
    );
  }

  bool _ownerLoadScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ownerLoadScheduled && _isJobOwner) {
      _ownerLoadScheduled = true;
      _loadIncoming();
    }
  }

  Future<void> _loadIncoming() async {
    setState(() => _loadingIncoming = true);
    final rows = await context.read<ProposalRepository>().fetchForJob(
      widget.job.id,
    );
    if (mounted) {
      setState(() {
        _incoming = rows;
        _loadingIncoming = false;
      });
    }
  }

  Future<void> _accept(JobProposalRow row) async {
    setState(() => _actingOnProposalId = row.id);
    final repo = context.read<ProposalRepository>();
    final appState = context.read<AppState>();
    final jobs = context.read<JobsProvider>();
    final ok = await repo.acceptProposal(
      proposalId: row.id,
      jobId: row.jobId,
      freelancerId: row.freelancerId,
      bid: row.bid,
    );
    if (!mounted) return;
    setState(() => _actingOnProposalId = null);
    if (ok) {
      await appState.refreshProfileFromServer();
      if (!mounted) return;
      ProlanceMessenger.success(
        context,
        appState.t(
          'Proposal accepted; demo wallet debited and escrow funded.',
          'Teklif kabul edildi; demo cüzdan kesildi ve escrow oluşturuldu.',
        ),
      );
      await jobs.refresh();
      await _loadIncoming();
    } else {
      final code = repo.lastAcceptErrorCode;
      final msg = code == 'insufficient_demo_balance'
          ? appState.t(
              'Not enough demo wallet balance for this bid amount.',
              'Bu teklif tutarı için demo cüzdan bakiyesi yetersiz.',
            )
          : code == 'job_already_accepted'
          ? appState.t(
              'Another proposal for this job is already accepted.',
              'Bu iş için başka bir teklif zaten kabul edilmiş.',
            )
          : appState.t('Could not accept proposal.', 'Teklif kabul edilemedi.');
      ProlanceMessenger.error(context, msg);
    }
  }

  Future<void> _reject(JobProposalRow row) async {
    setState(() => _actingOnProposalId = row.id);
    final ok = await context.read<ProposalRepository>().rejectProposal(row.id);
    if (!mounted) return;
    setState(() => _actingOnProposalId = null);
    if (ok) {
      ProlanceMessenger.success(
        context,
        context.read<AppState>().t('Proposal declined.', 'Teklif reddedildi.'),
      );
      await _loadIncoming();
    } else {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t(
          'Could not decline proposal.',
          'Teklif reddedilemedi.',
        ),
      );
    }
  }

  String _lifecycleHint(JobProposalRow row) {
    if (row.status != 'accepted') return '';
    switch (row.lifecyclePhase) {
      case ProposalLifecycle.escrowFunded:
        return 'Escrow funded · waiting for freelancer delivery';
      case ProposalLifecycle.awaitingClientReview:
      case ProposalLifecycle.delivered:
        return 'Files ready · download & review';
      case ProposalLifecycle.payoutPending:
        return 'Delivery accepted · 24h dispute window';
      case ProposalLifecycle.closed:
        return 'Completed';
      case ProposalLifecycle.disputed:
        return 'Disputed';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _coverController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_coverController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t(
          'Please fill in all fields.',
          'Lütfen tüm alanları doldurun.',
        ),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_isJobOwner) {
      return _buildOwnerView(context, scheme);
    }

    if (_submitted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.tick_circle, color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            Text(
              'Proposal sent!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The client will get back to you soon.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your proposal',
            style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          // Cover letter
          TextField(
            controller: _coverController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Explain why you are a great fit for this job...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          // Price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Bid amount (USD)',
              prefixIcon: const Icon(Iconsax.dollar_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Iconsax.send_2),
              label: const Text('Submit proposal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerView(BuildContext context, ColorScheme scheme) {
    if (_loadingIncoming) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_incoming.isEmpty) {
      return Center(
        child: Text(
          'No proposals yet.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _incoming.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = _incoming[index];
        final busy = _actingOnProposalId == row.id;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.freelancerName ?? 'Freelancer',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${row.bid.toStringAsFixed(0)} · ${row.deliveryDays} days',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                row.coverLetter,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: scheme.onSurface,
                ),
              ),
              if (!row.isPending) ...[
                const SizedBox(height: 6),
                Text(
                  _lifecycleHint(row),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (row.status == 'accepted' &&
                  (row.lifecyclePhase ==
                          ProposalLifecycle.awaitingClientReview ||
                      row.lifecyclePhase == ProposalLifecycle.delivered ||
                      row.lifecyclePhase ==
                          ProposalLifecycle.payoutPending)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => context.push('/review-delivery/${row.id}'),
                    icon: const Icon(Iconsax.tick_square, size: 18),
                    label: Text(
                      context.read<AppState>().t(
                        'Accept delivery',
                        'Teslimi kabul et',
                      ),
                    ),
                  ),
                ),
              ],
              if (row.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy ? null : () => _reject(row),
                        child: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: busy ? null : () => _accept(row),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    row.status == 'accepted' ? 'Accepted' : 'Declined',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: row.status == 'accepted'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
