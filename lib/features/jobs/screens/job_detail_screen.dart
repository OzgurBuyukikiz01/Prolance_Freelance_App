import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/widgets/user_avatar.dart';
import 'submit_proposal_screen.dart';

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
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.share),
                onPressed: () {
                  // Share functionality
                },
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Iconsax.heart5 : Iconsax.heart,
                  color: _isSaved ? AppColors.primary : null,
                ),
                onPressed: () {
                  setState(() => _isSaved = !_isSaved);
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
                        Text(
                          job.title,
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppConstants.paddingSm),
                        Text(
                          'Posted ${timeago.format(job.postedDate)}',
                          style: AppTextStyles.bodySmallSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLg),

                  // Client info section
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildClientSection(job),
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
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FadeInUp(
        delay: const Duration(milliseconds: 350),
        child: Container(
          padding: EdgeInsets.only(
            left: AppConstants.paddingMd,
            right: AppConstants.paddingMd,
            top: AppConstants.paddingMd,
            bottom: MediaQuery.of(context).padding.bottom + AppConstants.paddingMd,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey300.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitProposalScreen(job: job),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMd),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Submit Proposal',
                  style: AppTextStyles.buttonMedium.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientSection(JobModel job) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.2),
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
                  style: AppTextStyles.heading6,
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: 4.8,
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
                      '4.8',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Row(
                  children: [
                    Icon(Iconsax.location, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppConstants.paddingXs),
                    Text(
                      'San Francisco, CA',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Text(
                  'Member since 2022',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(JobModel job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.2),
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
            style: AppTextStyles.heading6,
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
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(JobModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: AppTextStyles.heading6,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Required',
          style: AppTextStyles.heading6,
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
    final lastViewed = job.postedDate.subtract(const Duration(hours: 2));
    final interviewingCount = (job.proposalCount * 0.2).round().clamp(0, job.proposalCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity on this job',
            style: AppTextStyles.heading6,
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
                  icon: Iconsax.eye,
                  label: 'Last viewed',
                  value: timeago.format(lastViewed),
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: Iconsax.people,
                  label: 'Interviewing',
                  value: '$interviewingCount',
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.2),
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
                style: AppTextStyles.caption,
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
                color: AppColors.textPrimary,
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
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
