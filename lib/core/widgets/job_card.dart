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
  });

  final JobModel job;
  final VoidCallback? onTap;
  final void Function(bool)? onSaveToggle;

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'hourly') {
      return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()}/hr';
    }
    return '\$${job.budgetMin.toInt()}-\$${job.budgetMax.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.grey400.withValues(alpha: 0.08),
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
                    child: Text(
                      job.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onSaveToggle?.call(!job.isSaved),
                    icon: Icon(
                      job.isSaved ? Iconsax.heart5 : Iconsax.heart,
                      color: job.isSaved
                          ? AppColors.error
                          : AppColors.textSecondary,
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
                        color: AppColors.textSecondary,
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
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeago.format(job.postedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.document_text,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${job.proposalCount} proposals',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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
