import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../jobs/screens/job_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<PlatformFile> _portfolioFiles = [];

  // Dummy review data
  final List<Map<String, dynamic>> _reviews = [
    {
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'name': 'John Mitchell',
      'rating': 5.0,
      'comment': 'Sarah delivered excellent work on time. Highly recommended!',
      'date': '2 weeks ago',
    },
    {
      'avatar': 'https://i.pravatar.cc/150?img=33',
      'name': 'Emma Davis',
      'rating': 5.0,
      'comment': 'Professional and communicative. Will hire again.',
      'date': '1 month ago',
    },
    {
      'avatar': 'https://i.pravatar.cc/150?img=45',
      'name': 'Michael Chen',
      'rating': 4.5,
      'comment': 'Great Flutter developer. Clean code and fast delivery.',
      'date': '2 months ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final activeJobs = state.activeMyJobs;
    final hasHistory = user.completedJobs > 0 || user.totalEarnings > 0 || user.rating > 0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: _buildProfileHeader(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Stats row
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildStatsRow(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Profile completion
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 150),
              child: _buildProfileCompletion(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // About Me
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: _buildAboutMe(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Skills
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 250),
              child: _buildSkills(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 280),
              child: _buildActiveJobs(activeJobs),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Portfolio
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
              child: _buildPortfolio(context),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Reviews
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 350),
              child: _buildReviews(hasHistory),
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          UserAvatar(
            imageUrl: user.avatarUrl,
            size: UserAvatarSize.xlarge,
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.location,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                user.location,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user.rating > 0)
            RatingBarIndicator(
              rating: user.rating,
              itemBuilder: (context, index) => const Icon(
                Iconsax.star1,
                color: AppColors.warning,
              ),
              itemCount: 5,
              itemSize: 20,
              unratedColor: AppColors.grey300,
            )
          else
            Text(
              'No rating yet',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Iconsax.briefcase,
            value: '${user.completedJobs}',
            label: 'Jobs Done',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.dollar_circle,
            value: '\$${(user.totalEarnings / 1000).toStringAsFixed(1)}k',
            label: 'Earnings',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.star1,
            value: user.rating.toString(),
            label: 'Rating',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletion(UserModel user) {
    final double completion = () {
      double v = 0.2;
      if (user.location != 'Not set') v += 0.2;
      if (user.skills.isNotEmpty) v += 0.25;
      if (user.bio.trim().isNotEmpty) v += 0.2;
      if (user.completedJobs > 0) v += 0.15;
      return v.clamp(0.15, 1.0);
    }();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Completion',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 8,
                percent: completion,
                progressColor: AppColors.primary,
                backgroundColor: AppColors.grey200,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(completion * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your profile to get more jobs',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Add portfolio items',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '• Verify your identity',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMe(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            user.bio,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills
                .map((skill) => SkillChip(
                      label: skill,
                      variant: SkillChipVariant.primary,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobs(List<dynamic> jobs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Jobs',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (jobs.isEmpty)
            Text(
              'No active jobs yet.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            )
          else
            ...jobs.take(5).map(
                  (job) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(job.title),
                    subtitle: Text(job.category),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _pickPortfolioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;
    setState(() {
      _portfolioFiles.addAll(result.files);
    });
  }

  Future<void> _downloadPortfolioFile(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) return;
    await FileSaver.instance.saveFile(
      name: file.name.split('.').first,
      bytes: bytes,
      ext: file.extension ?? 'bin',
      mimeType: MimeType.other,
    );
  }

  Widget _buildPortfolio(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickPortfolioFiles,
            icon: const Icon(Iconsax.add),
            label: const Text('Add from device (jpg/png/pdf)'),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          if (_portfolioFiles.isEmpty)
            Text(
              'No portfolio files yet.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: _portfolioFiles.length,
              itemBuilder: (context, index) {
                final file = _portfolioFiles[index];
                final isPdf = (file.extension ?? '').toLowerCase() == 'pdf';
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Icon(
                            isPdf ? Icons.picture_as_pdf : Icons.image,
                            size: 42,
                            color: isPdf ? Colors.red : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _downloadPortfolioFile(file),
                              child: const Text('Download'),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _portfolioFiles.removeAt(index)),
                            icon: const Icon(Iconsax.trash, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviews(bool hasHistory) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          if (!hasHistory)
            Text(
              'No reviews yet. Complete jobs to receive reviews.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            ...List.generate(_reviews.length, (index) {
              final review = _reviews[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _reviews.length - 1 ? AppConstants.paddingMd : 0,
                ),
                child: _buildReviewCard(review),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: review['avatar'] as String,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey300,
                    child: Icon(Icons.person, color: AppColors.grey600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: review['rating'] as double,
                      itemBuilder: (context, index) => const Icon(
                        Iconsax.star1,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      itemCount: 5,
                      itemSize: 14,
                      unratedColor: AppColors.grey300,
                    ),
                  ],
                ),
              ),
              Text(
                review['date'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'] as String,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
