import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_browse_filters.dart';
import '../../../core/models/job_model.dart';
import '../../../core/widgets/job_browse_filter_sheet.dart';
import '../../../core/navigation/main_nav_controller.dart';
import '../../../core/state/app_state.dart';
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
  JobBrowseFilters _browseFilters = JobBrowseFilters();

  MainNavController? _nav;
  AppState? _app;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nav ??= context.read<MainNavController>()..addListener(_onRepoOrNavChanged);
    _app ??= context.read<AppState>()..addListener(_onRepoOrNavChanged);
    _refreshFromSource();
  }

  void _onRepoOrNavChanged() {
    setState(_refreshFromSource);
  }

  @override
  void dispose() {
    _nav?.removeListener(_onRepoOrNavChanged);
    _app?.removeListener(_onRepoOrNavChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _refreshFromSource() {
    final appState = _app ?? context.read<AppState>();
    final source = appState.jobs.where((j) {
      if (j.status == 'pending_review') return false;
      if (j.isUserPosted &&
          j.clientName == appState.currentUser.name &&
          appState.shouldHideApprovedJobFromOwnerHome(j.id)) {
        return false;
      }
      return true;
    }).toList();
    final mode = _nav?.jobsSeeAllMode ?? context.read<MainNavController>().jobsSeeAllMode;
    final query = _searchController.text;
    _jobs = source.where((job) {
      return _browseFilters.matchesJob(job, query: query, useBroadSearch: false);
    }).toList();

    if (mode == JobsSeeAllMode.recommended) {
      _jobs = _jobs.where((j) => !j.isUserPosted).toList()
        ..sort((a, b) => b.proposalCount.compareTo(a.proposalCount));
    } else if (mode == JobsSeeAllMode.recent) {
      _jobs.sort((a, b) {
        if (a.isUserPosted != b.isUserPosted) {
          return a.isUserPosted ? -1 : 1;
        }
        return b.postedDate.compareTo(a.postedDate);
      });
    } else {
      _applySort();
    }
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

  Future<void> _openFilters() async {
    final next =
        await showJobBrowseFiltersSheet(context, initial: _browseFilters);
    if (!mounted || next == null) return;
    setState(() {
      _browseFilters = next;
      _refreshFromSource();
    });
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    final seeAll = context.watch<MainNavController>().jobsSeeAllMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.sort),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) {
                  final sheetScheme = Theme.of(sheetContext).colorScheme;
                  return Container(
                  decoration: BoxDecoration(
                    color: sheetScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sort by',
                        style: AppTextStyles.heading5.copyWith(
                          color: sheetScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMd),
                      _buildSortOption('Newest', JobSortOption.newest),
                      _buildSortOption('Budget High-Low', JobSortOption.budgetHighLow),
                      _buildSortOption('Budget Low-High', JobSortOption.budgetLowHigh),
                      _buildSortOption('Most Proposals', JobSortOption.mostProposals),
                    ],
                  ),
                );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_refreshFromSource),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            if (seeAll != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingMd,
                    AppConstants.paddingMd,
                    AppConstants.paddingMd,
                    AppConstants.paddingSm,
                  ),
                  child: Material(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                        vertical: AppConstants.paddingSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              seeAll == JobsSeeAllMode.recommended
                                  ? 'Recommended picks (from Home)'
                                  : 'Recent jobs (from Home)',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<MainNavController>().clearJobsSeeAllMode();
                              setState(_refreshFromSource);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    FadeInDown(
                      child: Builder(
                        builder: (ctx) {
                          final sc = Theme.of(ctx).colorScheme;
                          return Container(
                        decoration: BoxDecoration(
                          color: sc.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                            color: sc.outlineVariant.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: sc.shadow.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: sc.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(color: sc.onSurfaceVariant),
                            prefixIcon: Icon(Iconsax.search_normal_1,
                                color: sc.onSurfaceVariant),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingMd,
                              vertical: AppConstants.paddingMd,
                            ),
                          ),
                          onChanged: (_) => setState(_refreshFromSource),
                        ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMd),
                    // Filters
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _FilterChip(
                          label: 'Filters',
                          value: _browseFilters.hasAnyCriteria
                              ? 'Active${_activeFilterSuffix()}'
                              : null,
                          onTap: _openFilters,
                          leadingIcon: Iconsax.filter_search,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      '${_jobs.length} jobs found',
                      style: AppTextStyles.bodySmallSecondary.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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

  String _activeFilterSuffix() {
    final n = _browseFilters.selectedSkills.length;
    int c = 0;
    if (_browseFilters.category != null &&
        _browseFilters.category!.isNotEmpty) {
      c++;
    }
    if (_browseFilters.budgetRange != null &&
        _browseFilters.budgetRange!.isNotEmpty) {
      c++;
    }
    if (_browseFilters.experienceLevel != null &&
        _browseFilters.experienceLevel!.isNotEmpty) {
      c++;
    }
    if (_browseFilters.duration != null &&
        _browseFilters.duration!.isNotEmpty) {
      c++;
    }
    final total = c + n;
    return total > 0 ? ' ($total)' : '';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.value,
    required this.onTap,
    this.leadingIcon,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: AppConstants.paddingSm,
        ),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withValues(alpha: 0.15)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: hasValue ? AppColors.primary : scheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 16,
                color: hasValue ? AppColors.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.paddingXs),
            ],
            Text(
              value ?? label,
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    hasValue ? AppColors.primary : scheme.onSurfaceVariant,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: AppConstants.paddingXs),
            Icon(
              Iconsax.arrow_down_1,
              size: 14,
              color: hasValue ? AppColors.primary : scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: AppTextStyles.heading6.copyWith(
                          color: scheme.onSurface,
                        ),
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
                              style: AppTextStyles.bodySmallSecondary.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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
                Icon(Iconsax.document_text, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: AppConstants.paddingXs),
                Text(
                  '${job.proposalCount} proposals',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
