import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserModel _user = UserModel.dummy();

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
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
              child: _buildProfileHeader(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Stats row
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildStatsRow(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Profile completion
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 150),
              child: _buildProfileCompletion(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // About Me
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: _buildAboutMe(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Skills
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 250),
              child: _buildSkills(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Portfolio
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
              child: _buildPortfolio(),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Reviews
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 350),
              child: _buildReviews(),
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            imageUrl: _user.avatarUrl,
            size: UserAvatarSize.xlarge,
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Text(
            _user.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user.title,
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
                _user.location,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RatingBarIndicator(
            rating: _user.rating,
            itemBuilder: (context, index) => const Icon(
              Iconsax.star1,
              color: AppColors.warning,
            ),
            itemCount: 5,
            itemSize: 20,
            unratedColor: AppColors.grey300,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Iconsax.briefcase,
            value: '${_user.completedJobs}',
            label: 'Jobs Done',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.dollar_circle,
            value: '\$${(_user.totalEarnings / 1000).toStringAsFixed(1)}k',
            label: 'Earnings',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.star1,
            value: _user.rating.toString(),
            label: 'Rating',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletion() {
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
                percent: 0.85,
                progressColor: AppColors.primary,
                backgroundColor: AppColors.grey200,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '85%',
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

  Widget _buildAboutMe() {
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
            _user.bio,
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

  Widget _buildSkills() {
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
            children: _user.skills
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

  Widget _buildPortfolio() {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF00BFA6),
      Color(0xFFFFB74D),
      Color(0xFF2196F3),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
    ];

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
            'Portfolio',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
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
