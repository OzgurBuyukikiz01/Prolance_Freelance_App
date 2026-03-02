import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/widgets/user_avatar.dart';
import 'job_detail_screen.dart';

enum JobSortOption {
  newest,
  budgetHighLow,
  budgetLowHigh,
  mostProposals,
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  List<JobModel> _jobs = [];
  JobSortOption _sortOption = JobSortOption.newest;
  String? _selectedCategory;
  String? _selectedBudgetRange;
  String? _selectedExperienceLevel;
  String? _selectedDuration;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    setState(() {
      _jobs = JobModel.dummyList();
      _applySort();
    });
  }

  void _applySort() {
    switch (_sortOption) {
      case JobSortOption.newest:
        _jobs.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        break;
      case JobSortOption.budgetHighLow:
        _jobs.sort((a, b) => b.budgetMax.compareTo(a.budgetMax));
        break;
      case JobSortOption.budgetLowHigh:
        _jobs.sort((a, b) => a.budgetMin.compareTo(b.budgetMin));
        break;
      case JobSortOption.mostProposals:
        _jobs.sort((a, b) => b.proposalCount.compareTo(a.proposalCount));
        break;
    }
  }

  void _onSortSelected(JobSortOption option) {
    setState(() {
      _sortOption = option;
      _applySort();
    });
    Navigator.pop(context);
  }

  void _showFilterBottomSheet(String filterType) {
    List<String> options;
    String title;

    switch (filterType) {
      case 'Category':
        options = AppConstants.jobCategories;
        title = 'Select Category';
        break;
      case 'Budget Range':
        options = [
          'Under \$500',
          '\$500 - \$1,000',
          '\$1,000 - \$5,000',
          '\$5,000 - \$10,000',
          'Over \$10,000',
        ];
        title = 'Select Budget Range';
        break;
      case 'Experience Level':
        options = ['Entry', 'Intermediate', 'Expert'];
        title = 'Select Experience Level';
        break;
      case 'Duration':
        options = [
          'Less than 1 month',
          '1-3 months',
          '3-6 months',
          'More than 6 months',
        ];
        title = 'Select Duration';
        break;
      default:
        options = [];
        title = 'Select Option';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.heading5,
            ),
            const SizedBox(height: AppConstants.paddingMd),
            ...options.map((option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    setState(() {
                      switch (filterType) {
                        case 'Category':
                          _selectedCategory = option;
                          break;
                        case 'Budget Range':
                          _selectedBudgetRange = option;
                          break;
                        case 'Experience Level':
                          _selectedExperienceLevel = option;
                          break;
                        case 'Duration':
                          _selectedDuration = option;
                          break;
                      }
                    });
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: AppConstants.paddingMd),
          ],
        ),
      ),
    );
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.sort),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Sort by', style: AppTextStyles.heading5),
                      const SizedBox(height: AppConstants.paddingMd),
                      _buildSortOption('Newest', JobSortOption.newest),
                      _buildSortOption('Budget High-Low', JobSortOption.budgetHighLow),
                      _buildSortOption('Budget Low-High', JobSortOption.budgetLowHigh),
                      _buildSortOption('Most Proposals', JobSortOption.mostProposals),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadJobs(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    FadeInDown(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey300.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingMd,
                              vertical: AppConstants.paddingMd,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMd),
                    // Filter chips
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'Category',
                              value: _selectedCategory,
                              onTap: () => _showFilterBottomSheet('Category'),
                            ),
                            const SizedBox(width: AppConstants.paddingSm),
                            _FilterChip(
                              label: 'Budget Range',
                              value: _selectedBudgetRange,
                              onTap: () => _showFilterBottomSheet('Budget Range'),
                            ),
                            const SizedBox(width: AppConstants.paddingSm),
                            _FilterChip(
                              label: 'Experience Level',
                              value: _selectedExperienceLevel,
                              onTap: () => _showFilterBottomSheet('Experience Level'),
                            ),
                            const SizedBox(width: AppConstants.paddingSm),
                            _FilterChip(
                              label: 'Duration',
                              value: _selectedDuration,
                              onTap: () => _showFilterBottomSheet('Duration'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      '${_jobs.length} jobs found',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = _jobs[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                        vertical: AppConstants.paddingSm,
                      ),
                      child: _JobCard(
                        job: job,
                        formatBudget: _formatBudget,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: job),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                childCount: _jobs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, JobSortOption option) {
    final isSelected = _sortOption == option;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Iconsax.tick_circle5, color: AppColors.primary) : null,
      onTap: () => _onSortSelected(option),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: AppConstants.paddingSm,
        ),
        decoration: BoxDecoration(
          color: hasValue ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.grey300,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? label,
              style: AppTextStyles.bodySmall.copyWith(
                color: hasValue ? AppColors.primary : AppColors.textSecondary,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: AppConstants.paddingXs),
            Icon(
              Iconsax.arrow_down_1,
              size: 14,
              color: hasValue ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.formatBudget,
    required this.onTap,
  });

  final JobModel job;
  final String Function(JobModel) formatBudget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: AppTextStyles.heading6,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingSm),
                      Row(
                        children: [
                          UserAvatar(
                            imageUrl: job.clientAvatar,
                            size: UserAvatarSize.small,
                          ),
                          const SizedBox(width: AppConstants.paddingSm),
                          Expanded(
                            child: Text(
                              job.clientName,
                              style: AppTextStyles.bodySmallSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatBudget(job),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Text(
                      timeago.format(job.postedDate),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Wrap(
              spacing: AppConstants.paddingSm,
              runSpacing: AppConstants.paddingXs,
              children: job.skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSm,
                    vertical: AppConstants.paddingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    skill,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.paddingSm),
            Row(
              children: [
                Icon(Iconsax.document_text, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppConstants.paddingXs),
                Text(
                  '${job.proposalCount} proposals',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
