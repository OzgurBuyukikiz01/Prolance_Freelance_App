import 'job_model.dart';

/// Shared browse filters for Home and Jobs screens (budget strings match Jobs UI).
class JobBrowseFilters {
  JobBrowseFilters({
    this.category,
    this.budgetRange,
    this.experienceLevel,
    this.duration,
    Set<String>? selectedSkills,
  }) : selectedSkills = selectedSkills ?? {};

  static const List<String> budgetRangeOptions = [
    'Under \$500',
    '\$500 - \$1,000',
    '\$1,000 - \$5,000',
    '\$5,000 - \$10,000',
    'Over \$10,000',
  ];

  static const List<String> durationOptions = [
    'Less than 1 month',
    '1-3 months',
    '3-6 months',
    'More than 6 months',
    'Custom',
  ];

  static const List<String> experienceLevelOptions = [
    'Entry',
    'Intermediate',
    'Expert',
  ];

  final String? category;
  final String? budgetRange;
  final String? experienceLevel;
  final String? duration;
  final Set<String> selectedSkills;

  bool get hasAnyCriteria =>
      (category != null && category!.isNotEmpty) ||
      (budgetRange != null && budgetRange!.isNotEmpty) ||
      (experienceLevel != null && experienceLevel!.isNotEmpty) ||
      (duration != null && duration!.isNotEmpty) ||
      selectedSkills.isNotEmpty;

  JobBrowseFilters clearAll() => JobBrowseFilters();

  /// Copy with replaced multi-select skills (e.g. chip strip / autocomplete).
  JobBrowseFilters withSkills(Set<String> skills) {
    return JobBrowseFilters(
      category: category,
      budgetRange: budgetRange,
      experienceLevel: experienceLevel,
      duration: duration,
      selectedSkills: Set<String>.from(skills),
    );
  }

  /// How [JobsScreen] originally matched search text.
  bool matchesJobsSearch(JobModel job, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return job.title.toLowerCase().contains(q) ||
        job.skills.join(' ').toLowerCase().contains(q);
  }

  /// Broad search (home + autocomplete flows).
  bool matchesBroadSearch(JobModel job, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack =
        '${job.title} ${job.skills.join(' ')} ${job.description} ${job.clientName}'
            .toLowerCase();
    return haystack.contains(q);
  }

  static bool budgetRangeMatches(JobModel job, String range) {
    final value = job.budgetMax;
    if (range == 'Under \$500') return value < 500;
    if (range == '\$500 - \$1,000') return value >= 500 && value <= 1000;
    if (range == '\$1,000 - \$5,000') return value > 1000 && value <= 5000;
    if (range == '\$5,000 - \$10,000') return value > 5000 && value <= 10000;
    if (range == 'Over \$10,000') return value > 10000;
    return true;
  }

  bool matchesJob(
    JobModel job, {
    required String query,
    bool useBroadSearch = false,
  }) {
    final searchOk =
        useBroadSearch ? matchesBroadSearch(job, query) : matchesJobsSearch(job, query);

    final categoryOk = category == null ||
        category!.isEmpty ||
        job.category.toLowerCase().contains(category!.toLowerCase());

    final experienceOk =
        experienceLevel == null ||
            experienceLevel!.isEmpty ||
            job.experienceLevel == experienceLevel;

    final durationOk = duration == null ||
        duration!.isEmpty ||
        job.duration == duration ||
        (duration == 'Custom' && job.duration.startsWith('Custom:'));

    final budgetOk = budgetRange == null ||
        budgetRange!.isEmpty ||
        budgetRangeMatches(job, budgetRange!);

    final skillsOk = selectedSkills.isEmpty ||
        job.skills.any(
          (s) => selectedSkills.any(
            (sel) => s.toLowerCase() == sel.toLowerCase(),
          ),
        );

    return searchOk &&
        categoryOk &&
        experienceOk &&
        durationOk &&
        budgetOk &&
        skillsOk;
  }
}
