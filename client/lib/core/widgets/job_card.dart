import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../constants/app_colors.dart';
import '../models/job_model.dart';
import 'skill_chip.dart';
import 'user_avatar.dart';

/// A modern card displaying job details for the Prolance freelancing platform.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onSaveToggle,
    this.matchPercent,
  });

  final JobModel job;
  final VoidCallback? onTap;
  final void Function(bool)? onSaveToggle;

  /// Skill overlap score vs profile (home demo).
  final int? matchPercent;

  String _formatBudget(JobModel job) {
    if (job.listingKind == JobListingKinds.freelancerSeeking) {
      if (job.budgetType == 'hourly') {
        return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()}/hr target';
      }
      return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()} target';
    }
    if (job.budgetType == 'hourly') {
      return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()}/hr';
    }
    return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.listingKind ==
                            JobListingKinds.freelancerSeeking)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Open to work',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          job.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (matchPercent != null && matchPercent! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$matchPercent% match',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => onSaveToggle?.call(!job.isSaved),
                    icon: Icon(
                      job.isSaved ? Iconsax.heart5 : Iconsax.heart,
                      color: job.isSaved
                          ? AppColors.error
                          : scheme.onSurfaceVariant,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  UserAvatar(
                    imageUrl: job.clientAvatar,
                    size: UserAvatarSize.small,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.clientName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatBudget(job),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: job.skills
                      .take(3)
                      .map((skill) => SkillChip(label: skill))
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Iconsax.clock,
                    size: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeago.format(job.postedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.document_text,
                    size: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.listingKind == JobListingKinds.freelancerSeeking
                        ? 'Seeking role'
                        : '${job.proposalCount} proposals',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
