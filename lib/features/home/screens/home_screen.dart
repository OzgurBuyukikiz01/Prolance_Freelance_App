import 'package:animate_do/animate_do.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/job_model.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/job_card.dart';
import '../../jobs/screens/job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  String _query = '';

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

  List<JobModel> _filteredJobs(List<JobModel> source) {
    final selected = _categories[_selectedCategoryIndex];
    return source.where((job) {
      final categoryOk = selected == 'All' ||
          job.category.toLowerCase().contains(selected.toLowerCase());
      final queryOk = _query.trim().isEmpty ||
          job.title.toLowerCase().contains(_query.toLowerCase()) ||
          job.skills.join(' ').toLowerCase().contains(_query.toLowerCase());
      return categoryOk && queryOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allJobs = appState.jobs;
    final filtered = _filteredJobs(allJobs);
    final recommendedJobs = filtered.take(4).toList();
    final recentJobs = filtered.skip(4).take(6).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Iconsax.heart, color: AppColors.textPrimary, size: 22),
          ),
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
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
                  'Hello, ${appState.currentUser.name.split(' ').first} 👋',
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  icon: const Icon(Iconsax.search_normal_1),
                  hintText: 'Search jobs, skills, or clients...',
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  border: InputBorder.none,
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
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedJobs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return FadeInRight(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 250 + (index * 80)),
                  child: SizedBox(
                    width: 300,
                    child: JobCard(
                      job: recommendedJobs[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailScreen(job: recommendedJobs[index]),
                          ),
                        );
                      },
                      onSaveToggle: (saved) {
                        appState.toggleFavorite(recommendedJobs[index].id, saved);
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
          ...List.generate(recentJobs.length, (index) {
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 350 + (index * 60)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobCard(
                  job: recentJobs[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: recentJobs[index])),
                    );
                  },
                  onSaveToggle: (saved) {
                    appState.toggleFavorite(recentJobs[index].id, saved);
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
