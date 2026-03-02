import 'package:animate_do/animate_do.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/job_model.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/job_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  static const List<String> _categories = [
    'All',
    'Mobile Dev',
    'Web Dev',
    'UI/UX',
    'Data Science',
    'Design',
    'Writing',
    'Marketing',
  ];

  late final List<JobModel> _allJobs;
  List<JobModel> get _recommendedJobs => _allJobs.take(4).toList();
  List<JobModel> get _recentJobs => _allJobs.skip(4).take(6).toList();

  @override
  void initState() {
    super.initState();
    _allJobs = JobModel.dummyList();
  }

  void _onSearchTap() {
    // TODO: Navigate to search screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Text(
          'Prolance',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          badges.Badge(
            badgeContent: const SizedBox(
              width: 6,
              height: 6,
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: AppColors.error,
              padding: const EdgeInsets.all(4),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Iconsax.notification,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Özgür 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your next project',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: GestureDetector(
              onTap: _onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey400.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.search_normal_1,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search jobs, skills, or clients...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 150),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: _categories[index],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: _SectionHeader(
              title: 'Recommended Jobs',
              onSeeAll: () {},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendedJobs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return FadeInRight(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 250 + (index * 80)),
                  child: SizedBox(
                    width: 300,
                    child: JobCard(
                      job: _recommendedJobs[index],
                      onTap: () {},
                      onSaveToggle: (saved) {
                        setState(() {
                          final job = _recommendedJobs[index];
                          final idx = _allJobs.indexWhere((j) => j.id == job.id);
                          if (idx >= 0) {
                            _allJobs[idx] = job.copyWith(isSaved: saved);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 300),
            child: _SectionHeader(
              title: 'Recent Jobs',
              onSeeAll: () {},
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_recentJobs.length, (index) {
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 350 + (index * 60)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobCard(
                  job: _recentJobs[index],
                  onTap: () {},
                  onSaveToggle: (saved) {
                    setState(() {
                      final job = _recentJobs[index];
                      final idx = _allJobs.indexWhere((j) => j.id == job.id);
                      if (idx >= 0) {
                        _allJobs[idx] = job.copyWith(isSaved: saved);
                      }
                    });
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
