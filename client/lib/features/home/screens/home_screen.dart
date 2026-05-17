import 'package:animate_do/animate_do.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/job_browse_filters.dart';
import '../../../core/models/job_model.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/services/skills_catalog_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/job_browse_filter_sheet.dart';
import '../../../core/widgets/job_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onSeeAllRecommended,
    required this.onSeeAllRecent,
  });

  final VoidCallback onSeeAllRecommended;
  final VoidCallback onSeeAllRecent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  JobBrowseFilters _browseFilters = JobBrowseFilters();
  bool _catalogSkillsReady = false;
  List<String> _skillCatalogSorted = [];

  static final List<String> _categories = [
    'All',
    ...AppConstants.homeCategoryChips,
  ];

  int? _matchPercent(JobModel job, List<String> userSkills) {
    if (userSkills.isEmpty) return null;
    final userSet = userSkills.map((s) => s.toLowerCase()).toSet();
    final jobSet = job.skills.map((s) => s.toLowerCase()).toSet();
    if (jobSet.isEmpty) return null;
    final overlap = jobSet.intersection(userSet).length;
    if (overlap == 0) return null;
    return ((overlap / jobSet.length) * 100).round().clamp(1, 100);
  }

  List<JobModel> _filteredJobs(List<JobModel> source) {
    final selected = _categories[_selectedCategoryIndex];
    return source.where((job) {
      final categoryOk = selected == 'All' ||
          job.category.toLowerCase().contains(selected.toLowerCase());
      final filterOk = _browseFilters.matchesJob(
        job,
        query: _searchController.text,
        useBroadSearch: true,
      );
      return categoryOk && filterOk;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    SkillsCatalogService.instance.ensureLoaded().then((_) {
      if (!mounted) return;
      setState(() {
        _catalogSkillsReady = true;
        _skillCatalogSorted = SkillsCatalogService.instance.allSkillsUnique();
      });
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _openFiltersSheet() async {
    final next =
        await showJobBrowseFiltersSheet(context, initial: _browseFilters);
    if (!mounted || next == null) return;
    setState(() => _browseFilters = next);
  }

  void _toggleStripSkill(String skill) {
    final next = Set<String>.from(_browseFilters.selectedSkills);
    if (next.contains(skill)) {
      next.remove(skill);
    } else {
      next.add(skill);
    }
    setState(() => _browseFilters = _browseFilters.withSkills(next));
  }

  void _applySuggestion(_HomeSearchSuggestion suggestion) {
    if (suggestion.isSkill) {
      final next = Set<String>.from(_browseFilters.selectedSkills)
        ..add(suggestion.label);
      _searchController.clear();
      setState(() => _browseFilters = _browseFilters.withSkills(next));
      _searchFocus.unfocus();
    } else {
      _searchFocus.unfocus();
      _searchController.value = TextEditingValue(
        text: suggestion.label,
        selection:
            TextSelection.collapsed(offset: suggestion.label.length),
      );
      setState(() {});
    }
  }

  List<_HomeSearchSuggestion> _composeSuggestions(List<JobModel> allJobs) {
    final raw = _searchController.text.trim();
    if (!_searchFocus.hasFocus || !_catalogSkillsReady || raw.isEmpty) {
      return [];
    }
    final q = raw.toLowerCase();
    final out = <_HomeSearchSuggestion>[];
    final seen = <String>{};

    for (final sk
        in SkillsCatalogService.instance.searchSkills(raw, limit: 12)) {
      final key = 'sk:$sk';
      if (seen.add(key)) {
        out.add(_HomeSearchSuggestion.skill(sk));
      }
    }

    for (final j in allJobs) {
      if (out.length >= 14) break;
      final title = j.title.trim();
      if (title.toLowerCase().contains(q)) {
        final key = 't:$title';
        if (seen.add(key)) {
          out.add(_HomeSearchSuggestion.jobTitle(title));
        }
      }
      for (final sk in j.skills) {
        if (out.length >= 14) break;
        if (!sk.toLowerCase().contains(q)) continue;
        final key = 'js:$sk';
        if (seen.add(key)) out.add(_HomeSearchSuggestion.skill(sk));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();
    final jobsProvider = context.watch<JobsProvider>();
    final allJobs = jobsProvider.jobs.where((j) {
      if (j.status == 'pending_review') return false;
      if (j.isUserPosted &&
          j.clientName == appState.currentUser.name &&
          jobsProvider.shouldHideApprovedJobFromOwnerHome(j.id)) {
        return false;
      }
      return true;
    }).toList();
    final filtered = _filteredJobs(allJobs);
    final recommendedJobs =
        filtered.where((j) => !j.isUserPosted).take(4).toList();
    final userPosted = filtered.where((j) => j.isUserPosted).toList()
      ..sort((a, b) => b.postedDate.compareTo(a.postedDate));
    final rest = filtered.where((j) => !j.isUserPosted).toList()
      ..sort((a, b) => b.postedDate.compareTo(a.postedDate));
    final recentJobs = [...userPosted, ...rest].take(6).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ListView(
        padding: EdgeInsets.zero,
        children: [
          // ─── Gradient Header ──────────────────────────────────────────
          _HomeHeader(
            userName: appState.currentUser.name,
            unreadNotifications:
                context.watch<NotificationRepository>().unreadCount,
            onProposals: () => context.push('/my-proposals'),
            onFavorites: () => context.push('/favorites'),
            onNotifications: () => context.push('/notifications'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(
                        Iconsax.search_normal_1,
                        color: scheme.onSurfaceVariant,
                      ),
                      hintText: 'Search jobs, skills, or clients…',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Builder(
                  builder: (ctx) {
                    final sug = _composeSuggestions(allJobs);
                    if (sug.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Material(
                        elevation: 3,
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: sug.length,
                            separatorBuilder: (context, _) =>
                                Divider(height: 1, color: scheme.outlineVariant),
                            itemBuilder: (context, index) {
                              final item = sug[index];
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  item.isSkill
                                      ? Iconsax.flash_1
                                      : Iconsax.briefcase,
                                  size: 18,
                                  color: scheme.primary,
                                ),
                                title: Text(
                                  item.label,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: item.isSkill
                                    ? Text(
                                        'Skill filter',
                                        style: GoogleFonts.poppins(fontSize: 11),
                                      )
                                    : Text(
                                        'Search title',
                                        style: GoogleFonts.poppins(fontSize: 11),
                                      ),
                                onTap: () => _applySuggestion(item),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 125),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: !_catalogSkillsReady
                        ? Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _skillCatalogSorted.length,
                            separatorBuilder: (context, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final skill = _skillCatalogSorted[index];
                              final sel = _browseFilters.selectedSkills.any(
                                    (x) =>
                                        x.toLowerCase() == skill.toLowerCase(),
                                  );
                              return ChoiceChip(
                                label: Text(
                                  skill,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: sel,
                                onSelected: (_) => _toggleStripSkill(skill),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: sel
                                      ? scheme.onPrimary
                                      : scheme.onSurface,
                                ),
                                backgroundColor: scheme.surfaceContainerHigh,
                                selectedColor: scheme.primary,
                              );
                            },
                          ),
                  ),
                ),
                IconButton(
                  tooltip: 'All filters',
                  onPressed: _openFiltersSheet,
                  icon: Icon(Iconsax.filter_search, color: scheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
              onSeeAll: widget.onSeeAllRecommended,
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
                      matchPercent: _matchPercent(
                        recommendedJobs[index],
                        appState.currentUser.skills,
                      ),
                      onTap: () => context.push(
                            '/jobs/${recommendedJobs[index].id}',
                          ),
                      onSaveToggle: (saved) {
                        jobsProvider.toggleFavorite(recommendedJobs[index].id, saved);
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
              onSeeAll: widget.onSeeAllRecent,
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
                  matchPercent: _matchPercent(
                    recentJobs[index],
                    appState.currentUser.skills,
                  ),
                  onTap: () =>
                      context.push('/jobs/${recentJobs[index].id}'),
                  onSaveToggle: (saved) {
                    jobsProvider.toggleFavorite(recentJobs[index].id, saved);
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
        ], // Column children
            ), // Column
          ), // Padding
        ],
          ),
          if (appState.showProposalSentCelebration)
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: Material(
                elevation: 8,
                shadowColor: scheme.shadow.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                color: scheme.surfaceContainerHigh,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      context.read<AppState>().dismissProposalSentCelebration(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        ZoomIn(
                          duration: const Duration(milliseconds: 550),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 38,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FadeInLeft(
                            delay: const Duration(milliseconds: 120),
                            duration: const Duration(milliseconds: 450),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  appState.t(
                                      'Proposal sent!', 'Teklif gönderildi!'),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  appState.t(
                                    'Your proposal has reached the client.',
                                    'Teklifiniz işverene iletildi.',
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeSearchSuggestion {
  const _HomeSearchSuggestion._({
    required this.label,
    required this.isSkill,
  });

  factory _HomeSearchSuggestion.skill(String skill) =>
      _HomeSearchSuggestion._(label: skill, isSkill: true);

  factory _HomeSearchSuggestion.jobTitle(String title) =>
      _HomeSearchSuggestion._(label: title, isSkill: false);

  final String label;
  final bool isSkill;
}

// ---------------------------------------------------------------------------
// Gradient header with greeting + quick actions
// ---------------------------------------------------------------------------
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.onProposals,
    required this.onFavorites,
    required this.onNotifications,
    this.unreadNotifications = 0,
  });

  final String userName;
  final VoidCallback onProposals;
  final VoidCallback onFavorites;
  final VoidCallback onNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1A3A), const Color(0xFF12101E)]
              : [
                  AppColors.primary,
                  const Color(0xFF4F46E5),
                  const Color(0xFF7C3AED),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $firstName 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                        Text(
                          'Find your next project',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onProposals,
                    icon: const Icon(Iconsax.briefcase,
                        color: Colors.white, size: 22),
                    tooltip: 'My proposals',
                  ),
                  IconButton(
                    onPressed: onFavorites,
                    icon: const Icon(Iconsax.heart,
                        color: Colors.white, size: 22),
                    tooltip: 'Favorites',
                  ),
                  badges.Badge(
                    showBadge: unreadNotifications > 0,
                    badgeContent: unreadNotifications > 9
                        ? const Text('9+',
                            style: TextStyle(
                                color: Colors.white, fontSize: 9))
                        : Text(
                            '$unreadNotifications',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Color(0xFFFF5252),
                      padding: EdgeInsets.all(4),
                    ),
                    child: IconButton(
                      onPressed: onNotifications,
                      icon: const Icon(Iconsax.notification,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            // Stats strip
            _StatsStrip()
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: '\$2.4M+', sub: 'Paid out'),
      (label: '98%', sub: 'Satisfaction'),
      (label: '12K+', sub: 'Completed'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((s) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.label,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                s.sub,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
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
