import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../models/job_browse_filters.dart';
import '../services/skills_catalog_service.dart';
import 'overlays/prolance_bottom_sheet.dart';

// DropdownButtonFormField.value: migrate when stable Form APIs land (matches post_job).
// ignore_for_file: deprecated_member_use

Future<JobBrowseFilters?> showJobBrowseFiltersSheet(
  BuildContext context, {
  required JobBrowseFilters initial,
}) async {
  return showProlanceBottomSheet<JobBrowseFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    showTitleBar: false,
    child: DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, scrollController) => _JobBrowseFilterSheetBody(
        scrollController: scrollController,
        initial: initial,
      ),
    ),
  );
}

class _JobBrowseFilterSheetBody extends StatefulWidget {
  const _JobBrowseFilterSheetBody({
    required this.scrollController,
    required this.initial,
  });

  final ScrollController scrollController;
  final JobBrowseFilters initial;

  @override
  State<_JobBrowseFilterSheetBody> createState() =>
      _JobBrowseFilterSheetBodyState();
}

class _JobBrowseFilterSheetBodyState extends State<_JobBrowseFilterSheetBody> {
  late String? _category;
  late String? _budgetRange;
  late String? _experienceLevel;
  late String? _duration;
  late Set<String> _skills;
  final _skillSearch = TextEditingController();
  List<String> _skillHits = [];
  bool _catalogReady = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.category;
    _budgetRange = widget.initial.budgetRange;
    _experienceLevel = widget.initial.experienceLevel;
    _duration = widget.initial.duration;
    _skills = Set<String>.from(widget.initial.selectedSkills);
    SkillsCatalogService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _catalogReady = true);
    });
    _skillSearch.addListener(_onSkillQuery);
  }

  void _onSkillQuery() {
    final q = _skillSearch.text;
    setState(() {
      if (!_catalogReady || q.trim().isEmpty) {
        _skillHits = [];
      } else {
        _skillHits = SkillsCatalogService.instance.searchSkills(q, limit: 80);
      }
    });
  }

  @override
  void dispose() {
    _skillSearch.removeListener(_onSkillQuery);
    _skillSearch.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_skills.contains(skill)) {
        _skills.remove(skill);
      } else {
        _skills.add(skill);
      }
    });
  }

  JobBrowseFilters _result() => JobBrowseFilters(
        category: _category?.isEmpty == true ? null : _category,
        budgetRange: _budgetRange?.isEmpty == true ? null : _budgetRange,
        experienceLevel:
            _experienceLevel?.isEmpty == true ? null : _experienceLevel,
        duration: _duration?.isEmpty == true ? null : _duration,
        selectedSkills: Set<String>.from(_skills),
      );

  Widget _labeled(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );

  DropdownButtonFormField<String?> _stringDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String?>(
      value: value,
      isExpanded: true,
      dropdownColor: scheme.surfaceContainerHigh,
      style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
      hint: Text(hint),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            '(Any)',
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
          ),
        ),
        ...items.map(
          (e) => DropdownMenuItem<String?>(
            value: e,
            child: Text(e),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: scheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMd,
            16,
            AppConstants.paddingMd,
            AppConstants.paddingSm,
          ),
          child: Row(
            children: [
              Text(
                'Filters',
                style: AppTextStyles.heading5.copyWith(color: scheme.onSurface),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _category = null;
                    _budgetRange = null;
                    _experienceLevel = null;
                    _duration = null;
                    _skills.clear();
                    _skillSearch.clear();
                  });
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMd,
              0,
              AppConstants.paddingMd,
              AppConstants.paddingLg,
            ),
            children: [
              _labeled('Category'),
              _stringDropdown(
                hint: 'Category',
                value: _category,
                items: AppConstants.jobCategories.toList(growable: false),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _labeled('Budget range (uses job max budget)'),
              _stringDropdown(
                hint: 'Budget',
                value: _budgetRange,
                items:
                    JobBrowseFilters.budgetRangeOptions.toList(growable: false),
                onChanged: (v) => setState(() => _budgetRange = v),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _labeled('Experience level'),
              _stringDropdown(
                hint: 'Experience',
                value: _experienceLevel,
                items: JobBrowseFilters.experienceLevelOptions
                    .toList(growable: false),
                onChanged: (v) => setState(() => _experienceLevel = v),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _labeled('Duration'),
              _stringDropdown(
                hint: 'Duration',
                value: _duration,
                items: JobBrowseFilters.durationOptions.toList(growable: false),
                onChanged: (v) => setState(() => _duration = v),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _labeled('Skills (any match)'),
              TextField(
                controller: _skillSearch,
                style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  hintText: _catalogReady
                      ? 'Search catalog…'
                      : 'Loading skill catalog…',
                  prefixIcon: Icon(
                    Iconsax.search_normal_1,
                    color: scheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_skills.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((s) {
                    return FilterChip(
                      label: Text(s),
                      selected: true,
                      showCheckmark: false,
                      onSelected: (_) => _toggleSkill(s),
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Tap a result to add or remove.',
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (_skillSearch.text.trim().isNotEmpty &&
                  _skillHits.isEmpty &&
                  _catalogReady)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No skills match.',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ..._skillHits.map((s) {
                final sel = _skills.contains(s);
                return ListTile(
                  dense: true,
                  title: Text(s),
                  trailing: Icon(
                    sel ? Iconsax.tick_circle5 : Iconsax.add,
                    color: sel ? AppColors.primary : scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: () => _toggleSkill(s),
                );
              }),
              SizedBox(height: bottomInset + 80),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingMd,
            AppConstants.paddingSm,
            AppConstants.paddingMd,
            bottomInset + AppConstants.paddingMd,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context, _result()),
              child: Text(
                'Apply',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
