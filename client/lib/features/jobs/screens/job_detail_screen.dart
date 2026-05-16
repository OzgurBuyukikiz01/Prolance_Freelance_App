import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/navigation/main_nav_controller.dart';
import '../../../core/navigation/proposal_route.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../core/widgets/overlays/prolance_bottom_sheet.dart';
import '../widgets/job_detail_bottom_sheet.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job});

  final JobModel job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.job.isSaved;
  }

  String _formatBudget(JobModel job) {
    if (job.listingKind == JobListingKinds.freelancerSeeking) {
      if (job.budgetType == 'hourly') {
        return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr target';
      }
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)} target';
    }
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final currentUser = context.watch<AppState>().currentUser;
    final isOwnJob = job.clientName == currentUser.name;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.share),
                onPressed: () {
                  Share.share(
                    '${job.title}\n${job.category}\nShared from Prolance (demo)',
                    subject: job.title,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Iconsax.heart5 : Iconsax.heart,
                  color: _isSaved ? AppColors.primary : null,
                ),
                onPressed: () {
                  final next = !_isSaved;
                  setState(() => _isSaved = next);
                  context.read<JobsProvider>().toggleFavorite(job.id, next);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title and posted time
                  FadeInUp(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.listingKind ==
                            JobListingKinds.freelancerSeeking)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppConstants.paddingSm),
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              label: const Text('Open to work'),
                              backgroundColor: AppColors.secondary
                                  .withValues(alpha: 0.12),
                            ),
                          ),
                        Text(
                          job.title,
                          style: AppTextStyles.heading3.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSm),
                        Text(
                          'Posted ${timeago.format(job.postedDate)}',
                          style: AppTextStyles.bodySmallSecondary.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Client info section
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildClientSection(job, currentUser, isOwnJob),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Job description
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: _buildDescriptionSection(job),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Details section
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildDetailsSection(job),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Skills required
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: _buildSkillsSection(job),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Activity section
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildActivitySection(job),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: _buildProposalCta(context, job, isOwnJob),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildEscrowEntry(context, job),
                  ),
                  if (job.status == 'completed')
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: _buildReviewCta(context, job, currentUser),
                    ),
                  const SizedBox(height: AppConstants.paddingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCta(
      BuildContext context, JobModel job, UserModel currentUser) {
    // Freelancer reviews the client; client reviews the freelancer.
    // For demo purposes: the current user reviews the job's client
    // (if they are not the client themselves).
    final isClient = job.clientName == currentUser.name;
    final revieweeName = isClient ? 'Freelancer' : job.clientName;
    final revieweeId = isClient ? '' : job.clientName;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FilledButton.icon(
        onPressed: revieweeId.isEmpty
            ? null
            : () {
                context.push(
                  '/review/${job.id}'
                  '?revieweeId=${Uri.encodeComponent(revieweeId)}'
                  '&revieweeName=${Uri.encodeComponent(revieweeName)}'
                  '&revieweeAvatar=${Uri.encodeComponent(job.clientAvatar)}',
                );
              },
        icon: const Icon(Iconsax.star, size: 18),
        label: const Text('Değerlendirme Yaz'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEscrowEntry(BuildContext context, JobModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => showJobDetailBottomSheet(context, job),
          icon: const Icon(Iconsax.eye),
          label: const Text('Detayları Gör'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/escrow/${job.id}'),
          icon: const Icon(Iconsax.wallet_money),
          label: const Text('Escrow & payments (mock)'),
        ),
      ],
    );
  }

  Widget _buildProposalCta(BuildContext context, JobModel job, bool isOwnJob) {
    final isSeeking =
        job.listingKind == JobListingKinds.freelancerSeeking;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isOwnJob) {
              final appState = context.read<AppState>();
              showProlanceBottomSheet<void>(
                context: context,
                title: isSeeking
                    ? appState.t('Your listing', 'İlanınız')
                    : appState.t('Review proposals', 'Teklifleri incele'),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingLg,
                      0,
                      AppConstants.paddingLg,
                      AppConstants.paddingLg,
                    ),
                    child: Text(
                      isSeeking
                          ? appState.t(
                              'This is your open-to-work post. Others can discover it in the job feed.',
                              'Bu sizin açık iş arama ilanınız. Diğerleri iş akışında keşfedebilir.',
                            )
                          : appState.t(
                              'This is your own job. You can only review incoming proposals.\nCurrent proposals: ${job.proposalCount}',
                              'Bu sizin ilanınız. Yalnızca gelen teklifleri inceleyebilirsiniz.\nMevcut teklifler: ${job.proposalCount}',
                            ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
              return;
            }
            if (isSeeking) {
              final nav = context.read<MainNavController>();
              Navigator.pop(context);
              nav.selectTab(2);
              return;
            }
            Navigator.of(context).push(submitProposalRoute(job));
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Center(
              child: Text(
                isOwnJob
                    ? (isSeeking ? 'Your listing' : 'Review Proposals')
                    : (isSeeking ? 'Go to Messages' : 'Submit Proposal'),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientSection(JobModel job, UserModel user, bool isOwnJob) {
    final rating = isOwnJob ? user.rating : 4.75;
    final location = isOwnJob ? user.location : 'Remote';
    final memberYear =
        isOwnJob ? user.joinedDate.year : job.postedDate.year - 1;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: job.clientAvatar,
            size: UserAvatarSize.large,
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.clientName,
                  style: AppTextStyles.heading6.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, _) => const Icon(
                        Iconsax.star1,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      itemCount: 5,
                      itemSize: 16,
                      unratedColor: AppColors.grey300,
                    ),
                    const SizedBox(width: AppConstants.paddingXs),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Row(
                  children: [
                    Icon(Iconsax.location,
                        size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: AppConstants.paddingXs),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTextStyles.bodySmallSecondary.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Text(
                  'Member since $memberYear',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(JobModel job) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          ReadMoreText(
            job.description,
            trimLines: 4,
            trimMode: TrimMode.Line,
            colorClickableText: AppColors.primary,
            trimCollapsedText: ' Show more',
            trimExpandedText: ' Show less',
            moreStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            lessStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(JobModel job) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.paddingMd),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppConstants.paddingMd,
          crossAxisSpacing: AppConstants.paddingMd,
          childAspectRatio: 2.2,
          children: [
            _DetailCard(
              icon: Iconsax.dollar_circle,
              label: 'Budget',
              value: _formatBudget(job),
            ),
            _DetailCard(
              icon: Iconsax.clock,
              label: 'Duration',
              value: job.duration,
            ),
            _DetailCard(
              icon: Iconsax.crown,
              label: 'Experience',
              value: job.experienceLevel,
            ),
            _DetailCard(
              icon: Iconsax.category_2,
              label: 'Category',
              value: job.category,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection(JobModel job) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Required',
          style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.paddingMd),
        Wrap(
          spacing: AppConstants.paddingSm,
          runSpacing: AppConstants.paddingSm,
          children: job.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd,
                vertical: AppConstants.paddingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                skill,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivitySection(JobModel job) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project pulse',
            style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              Expanded(
                child: _ActivityItem(
                  icon: Iconsax.document_text,
                  label: 'Proposals',
                  value: '${job.proposalCount}',
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: Iconsax.clock,
                  label: 'Posted',
                  value: timeago.format(job.postedDate),
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: Iconsax.crown,
                  label: 'Experience',
                  value: job.experienceLevel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppConstants.paddingSm),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
