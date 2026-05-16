import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/services/skills_catalog_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/utils/project_duration_ymd.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

// DropdownButtonFormField.value / RadioListTile.groupValue: migrate when stable RadioGroup/DropdownMenu Form APIs land.
// ignore_for_file: deprecated_member_use

enum _ListingIntent { hireTalent, openToWork }

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  static const List<String> _durations = [
    'Less than 1 month',
    '1-3 months',
    '3-6 months',
    'More than 6 months',
    'Other',
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _titleController = TextEditingController();
  String? _selectedCategory;
  final _descriptionController = TextEditingController();

  final List<String> _skills = [];
  String _experienceLevel = 'Entry';
  String? _selectedDuration;

  final _durYearsController = TextEditingController(text: '0');
  final _durMonthsController = TextEditingController(text: '0');
  final _durDaysController = TextEditingController(text: '0');

  bool _isFixedPrice = true;
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _minHourlyController = TextEditingController();
  final _maxHourlyController = TextEditingController();

  bool _catalogReady = false;
  final _skillSearchController = TextEditingController();
  _ListingIntent _intent = _ListingIntent.hireTalent;

  void _resetWizardDraft() {
    _titleController.clear();
    _descriptionController.clear();
    _skillSearchController.clear();
    _selectedCategory = null;
    _skills.clear();
    _experienceLevel = 'Entry';
    _selectedDuration = null;
    _durYearsController.text = '0';
    _durMonthsController.text = '0';
    _durDaysController.text = '0';
    _isFixedPrice = true;
    _minBudgetController.clear();
    _maxBudgetController.clear();
    _minHourlyController.clear();
    _maxHourlyController.clear();
  }

  @override
  void initState() {
    super.initState();
    SkillsCatalogService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _catalogReady = true);
    });
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _durYearsController.dispose();
    _durMonthsController.dispose();
    _durDaysController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _minHourlyController.dispose();
    _maxHourlyController.dispose();
    _skillSearchController.dispose();
    super.dispose();
  }

  InputDecoration _postJobInputDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: scheme.onSurfaceVariant,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: scheme.onSurfaceVariant,
      ),
      helperStyle: GoogleFonts.poppins(
        fontSize: 11,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingMd,
      ),
    );
  }

  List<String> _suggestedPool() {
    if (!_catalogReady || _selectedCategory == null) return [];
    return SkillsCatalogService.instance
        .suggestFromDescription(
          _descriptionController.text,
          _selectedCategory!,
        )
        .where((s) => !_skills.contains(s))
        .toList();
  }

  List<String> _quickSelectSkills() {
    if (!_catalogReady) return [];
    final q = _skillSearchController.text.trim();
    if (q.isEmpty) {
      if (_selectedCategory == null) return [];
      return SkillsCatalogService.instance
          .skillsForCategory(_selectedCategory!)
          .where((s) => !_skills.contains(s))
          .toList();
    }
    return SkillsCatalogService.instance
        .searchSkills(q)
        .where((s) => !_skills.contains(s))
        .toList();
  }

  String _composeDuration() {
    if (_selectedDuration == null) return 'Less than 1 month';
    if (_selectedDuration != 'Other') return _selectedDuration!;
    final y = int.tryParse(_durYearsController.text.trim()) ?? 0;
    final m = int.tryParse(_durMonthsController.text.trim()) ?? 0;
    final d = int.tryParse(_durDaysController.text.trim()) ?? 0;
    return 'Custom: ${y}y ${m}m ${d}d';
  }

  void _nextStep() {
    if (_intent == _ListingIntent.hireTalent) {
      if (_currentStep == 0 && !_validateStep1()) return;
      if (_currentStep == 1 && !_validateStep2()) return;
    } else {
      if (_currentStep == 0 && !_validateSeekStep1()) return;
      if (_currentStep == 1 && !_validateSeekStep2()) return;
    }
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
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

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  void _normalizeDurationInputs() {
    if (_selectedDuration != 'Other') return;
    final y = int.tryParse(_durYearsController.text.trim()) ?? 0;
    final m = int.tryParse(_durMonthsController.text.trim()) ?? 0;
    final d = int.tryParse(_durDaysController.text.trim()) ?? 0;
    final n = ProjectDurationYmd.normalize(y, m, d);
    _durYearsController.text = '${n.years}';
    _durMonthsController.text = '${n.months}';
    _durDaysController.text = '${n.days}';
  }

  void _postJob() {
    if (!_validateStep3()) return;

    final appState = context.read<AppState>();
    final jobsProvider = context.read<JobsProvider>();
    late double minVal;
    late double maxVal;
    if (_isFixedPrice) {
      minVal = double.tryParse(_minBudgetController.text.trim()) ?? 0;
      maxVal = double.tryParse(_maxBudgetController.text.trim()) ?? 0;
    } else {
      minVal = double.tryParse(_minHourlyController.text.trim()) ?? 0;
      maxVal = double.tryParse(_maxHourlyController.text.trim()) ?? 0;
    }

    jobsProvider.addJob(
      JobModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientName: appState.currentUser.name,
        clientAvatar: appState.currentUser.avatarUrl,
        budgetMin: minVal,
        budgetMax: maxVal,
        budgetType: _isFixedPrice ? 'fixed' : 'hourly',
        category: _selectedCategory ?? 'General',
        skills: List<String>.from(_skills),
        experienceLevel: _experienceLevel,
        postedDate: DateTime.now(),
        proposalCount: 0,
        duration: _composeDuration(),
        isSaved: false,
        status: 'open',
        isUserPosted: true,
        listingKind: JobListingKinds.jobOffer,
      ),
      currentUserName: appState.currentUser.name,
      currentUserAvatar: appState.currentUser.avatarUrl,
      notifications: context.read<NotificationRepository>(),
      t: appState.t,
    );

    _showSuccessDialog(hiringJob: true);
  }

  void _postSeekListing() {
    if (!_validateSeekStep3()) return;

    final appState = context.read<AppState>();
    final jobsProvider = context.read<JobsProvider>();
    final minH = double.tryParse(_minHourlyController.text.trim()) ?? 0;
    final maxH = double.tryParse(_maxHourlyController.text.trim()) ?? 0;

    jobsProvider.addJob(
      JobModel(
        id: 'seek_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientName: appState.currentUser.name,
        clientAvatar: appState.currentUser.avatarUrl,
        budgetMin: minH,
        budgetMax: maxH,
        budgetType: 'hourly',
        category: _selectedCategory ?? 'General',
        skills: List<String>.from(_skills),
        experienceLevel: _experienceLevel,
        postedDate: DateTime.now(),
        proposalCount: 0,
        duration: _composeDuration(),
        isSaved: false,
        status: 'open',
        isUserPosted: true,
        listingKind: JobListingKinds.freelancerSeeking,
      ),
      currentUserName: appState.currentUser.name,
      currentUserAvatar: appState.currentUser.avatarUrl,
      notifications: context.read<NotificationRepository>(),
      t: appState.t,
    );

    _showSuccessDialog(hiringJob: false);
  }

  bool _validateStep1() {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final words = desc.isEmpty
        ? <String>[]
        : desc.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (title.isEmpty || _selectedCategory == null) {
      _showError('Job Title and Category are required.');
      return false;
    }
    if (words.length < 15) {
      _showError('Description must have at least 15 words.');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_skills.isEmpty) {
      _showError('Please add at least one skill (quick select or search).');
      return false;
    }
    if (_selectedDuration == null) {
      _showError('Please select project duration.');
      return false;
    }
    if (_selectedDuration == 'Other') {
      _normalizeDurationInputs();
      setState(() {});
      final y = int.tryParse(_durYearsController.text.trim()) ?? 0;
      final m = int.tryParse(_durMonthsController.text.trim()) ?? 0;
      final d = int.tryParse(_durDaysController.text.trim()) ?? 0;
      final dur = ProjectDurationYmd(y, m, d);
      if (!dur.isPositive) {
        _showError('Enter a custom duration (years, months, or days).');
        return false;
      }
    }
    return true;
  }

  bool _validateStep3() {
    if (_isFixedPrice) {
      final min = double.tryParse(_minBudgetController.text.trim());
      final max = double.tryParse(_maxBudgetController.text.trim());
      if (min == null || max == null || min <= 0 || max <= 0 || max < min) {
        _showError('Please enter a valid budget range.');
        return false;
      }
    } else {
      final minH = double.tryParse(_minHourlyController.text.trim());
      final maxH = double.tryParse(_maxHourlyController.text.trim());
      if (minH == null ||
          maxH == null ||
          minH <= 0 ||
          maxH <= 0 ||
          maxH < minH) {
        _showError('Please enter a valid minimum and maximum hourly rate.');
        return false;
      }
    }
    return true;
  }

  bool _validateSeekStep1() {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final words = desc.isEmpty
        ? <String>[]
        : desc.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (title.isEmpty) {
      _showError('Add a short headline.');
      return false;
    }
    if (words.length < 15) {
      _showError('Description must have at least 15 words.');
      return false;
    }
    return true;
  }

  bool _validateSeekStep2() {
    if (_selectedCategory == null) {
      _showError('Select your primary category.');
      return false;
    }
    if (_skills.isEmpty) {
      _showError('Please add at least one skill.');
      return false;
    }
    return true;
  }

  bool _validateSeekStep3() {
    if (_selectedDuration == null) {
      _showError('Please select preferred engagement duration.');
      return false;
    }
    if (_selectedDuration == 'Other') {
      _normalizeDurationInputs();
      setState(() {});
      final y = int.tryParse(_durYearsController.text.trim()) ?? 0;
      final m = int.tryParse(_durMonthsController.text.trim()) ?? 0;
      final d = int.tryParse(_durDaysController.text.trim()) ?? 0;
      final dur = ProjectDurationYmd(y, m, d);
      if (!dur.isPositive) {
        _showError('Enter a custom duration (years, months, or days).');
        return false;
      }
    }
    final minH = double.tryParse(_minHourlyController.text.trim());
    final maxH = double.tryParse(_maxHourlyController.text.trim());
    if (minH == null ||
        maxH == null ||
        minH <= 0 ||
        maxH <= 0 ||
        maxH < minH) {
      _showError('Please enter a valid target hourly range.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ProlanceMessenger.error(context, message);
  }

  Future<void> _showSuccessDialog({required bool hiringJob}) async {
    final appState = context.read<AppState>();
    await showProlanceSuccessDialog(
      context,
      title: hiringJob
          ? appState.t('Your job has been posted!', 'İlanınız yayınlandı!')
          : appState.t(
              'Your open-to-work post is submitted!',
              'Açık iş arama ilanınız gönderildi!',
            ),
      message: hiringJob
          ? appState.t(
              'Freelancers can now view and submit proposals for your job.',
              'Freelancerlar ilanınızı görüntüleyip teklif gönderebilir.',
            )
          : appState.t(
              'Your listing will appear in the feed after admin approval.',
              'İlanınız yönetici onayından sonra akışta görünecek.',
            ),
      onDone: () {
        if (context.mounted) context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create listing',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMd,
              AppConstants.paddingMd,
              AppConstants.paddingMd,
              4,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_ListingIntent>(
                segments: [
                  ButtonSegment<_ListingIntent>(
                    value: _ListingIntent.hireTalent,
                    label: Text(
                      'Hire talent',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  ButtonSegment<_ListingIntent>(
                    value: _ListingIntent.openToWork,
                    label: Text(
                      'Open to work',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                ],
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: AppColors.primary,
                ),
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                selected: {_intent},
                multiSelectionEnabled: false,
                emptySelectionAllowed: false,
                onSelectionChanged: (Set<_ListingIntent> set) {
                  setState(() {
                    _intent = set.first;
                    _currentStep = 0;
                    _pageController.jumpToPage(0);
                    _resetWizardDraft();
                  });
                },
              ),
            ),
          ),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _intent == _ListingIntent.hireTalent
                    ? _buildHireStep1()
                    : _buildSeekStep1(),
                _intent == _ListingIntent.hireTalent
                    ? _buildHireStep2()
                    : _buildSeekStep2(),
                _intent == _ListingIntent.hireTalent
                    ? _buildHireStep3()
                    : _buildSeekStep3(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of 3',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ...List.generate(3, (index) {
                final isActive = index <= _currentStep;
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildHireStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: AppTextStyles.heading5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          CustomTextField(
            controller: _titleController,
            label: 'Job Title *',
            hint: 'e.g. Flutter Developer needed for mobile app',
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Category *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor:
                Theme.of(context).colorScheme.surfaceContainerHigh,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: _postJobInputDecoration(context),
            hint: Text(
              'Select category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            items: AppConstants.postJobCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                if (value != null && _catalogReady) {
                  final allowed = SkillsCatalogService.instance
                      .skillsForCategory(value)
                      .toSet();
                  _skills.removeWhere((s) => !allowed.contains(s));
                }
              });
            },
          ),
          const SizedBox(height: AppConstants.paddingLg),
          CustomTextField(
            controller: _descriptionController,
            label: 'Description *',
            hint: 'Describe your project in detail...',
            maxLines: 6,
          ),
          const SizedBox(height: 6),
          Text(
            'Minimum 15 words required',
            style: AppTextStyles.caption
                .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHireStep2() {
    final suggested = _suggestedPool();
    final quick = _quickSelectSkills();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements',
            style: AppTextStyles.heading5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Skills needed',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedCategory == null
                ? 'Choose a category in Step 1 to load relevant skills.'
                : (!_catalogReady
                    ? 'Loading skill catalog…'
                    : 'Tap chips to add, or search below for any skill in the catalog.'),
            style: AppTextStyles.caption
                .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (suggested.isNotEmpty) ...[
            Text(
              'Suggested from description',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggested
                  .map(
                    (skill) => ActionChip(
                      label: Text(skill),
                      onPressed: () => _toggleSkill(skill),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Quick select',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skillSearchController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: _postJobInputDecoration(context).copyWith(
              hintText: 'Search skills…',
              prefixIcon: Icon(
                Iconsax.search_normal_1,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_skillSearchController.text.trim().isEmpty &&
              _selectedCategory == null)
            Text(
              'Pick a category in Step 1 to show category skills, or type above to search the whole catalog.',
              style: AppTextStyles.caption
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          if (_skillSearchController.text.trim().isNotEmpty &&
              quick.isEmpty &&
              _catalogReady)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No matching skills. Try another keyword.',
                style: AppTextStyles.caption
                    .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: quick
                .map(
                  (skill) => ActionChip(
                    label: Text(skill),
                    onPressed: () => _toggleSkill(skill),
                  ),
                )
                .toList(),
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Iconsax.close_circle, size: 18),
                  onDeleted: () => _removeSkill(skill),
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Experience Level',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...['Entry', 'Intermediate', 'Expert'].map((level) {
            final scheme = Theme.of(context).colorScheme;
            return RadioListTile<String>(
              title: Text(
                level,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: scheme.onSurface,
                ),
              ),
              value: level,
              groupValue: _experienceLevel,
              activeColor: AppColors.primary,
              onChanged: (value) =>
                  setState(() => _experienceLevel = value!),
            );
          }),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Project Duration',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDuration,
            dropdownColor:
                Theme.of(context).colorScheme.surfaceContainerHigh,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: _postJobInputDecoration(context),
            hint: Text(
              'Select duration',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            items: _durations
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) => setState(() => _selectedDuration = value),
          ),
          if (_selectedDuration == 'Other') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durYearsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Years',
                      helperText: '0–10 max',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _durMonthsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Months',
                      helperText: '0–12',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _durDaysController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Days',
                      helperText: '0–30 (30 d → 1 mo)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'When you tap Next, values normalize: 30 days roll into a month, 12 months into a year (max 10 years).',
              style: AppTextStyles.caption
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHireStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: AppTextStyles.heading5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.lock, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Secure milestone payments',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Demo: escrow-style payouts will connect to payments later (Stripe / Supabase).',
                  style: AppTextStyles.caption
                      .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFixedPrice = true),
                  child: Builder(
                    builder: (ctx) {
                      final scheme = Theme.of(ctx).colorScheme;
                      return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isFixedPrice
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : scheme.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: _isFixedPrice
                            ? AppColors.primary
                            : scheme.outlineVariant,
                        width: _isFixedPrice ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      'Fixed Price',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _isFixedPrice
                            ? AppColors.primary
                            : scheme.onSurface,
                      ),
                    ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFixedPrice = false),
                  child: Builder(
                    builder: (ctx) {
                      final scheme = Theme.of(ctx).colorScheme;
                      return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isFixedPrice
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : scheme.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: !_isFixedPrice
                            ? AppColors.primary
                            : scheme.outlineVariant,
                        width: !_isFixedPrice ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      'Hourly Rate',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: !_isFixedPrice
                            ? AppColors.primary
                            : scheme.onSurface,
                      ),
                    ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLg),
          if (_isFixedPrice) ...[
            Text(
              'Estimated budget',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBudgetController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _postJobInputDecoration(context).copyWith(
                      hintText: 'Min',
                      prefixText: '\$ ',
                      prefixStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxBudgetController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _postJobInputDecoration(context).copyWith(
                      hintText: 'Max',
                      prefixText: '\$ ',
                      prefixStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Hourly payment',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minHourlyController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _postJobInputDecoration(context).copyWith(
                      hintText: 'Minimum hourly (e.g. 25)',
                      prefixText: '\$ ',
                      prefixStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxHourlyController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _postJobInputDecoration(context).copyWith(
                      hintText: 'Maximum hourly (e.g. 75)',
                      prefixText: '\$ ',
                      prefixStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeekStep1() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Introduce yourself',
            style: AppTextStyles.heading5.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          CustomTextField(
            controller: _titleController,
            label: 'Headline *',
            hint: 'e.g. Flutter dev looking for startups',
          ),
          const SizedBox(height: AppConstants.paddingLg),
          CustomTextField(
            controller: _descriptionController,
            label: 'What you\'re seeking *',
            hint: 'Role types, stack, timezone, freelance vs full-time...',
            maxLines: 6,
          ),
          const SizedBox(height: 6),
          Text(
            'Minimum 15 words required',
            style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekStep2() {
    final suggested = _suggestedPool();
    final quick = _quickSelectSkills();
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category & expertise',
            style: AppTextStyles.heading5.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Category *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: scheme.surfaceContainerHigh,
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
            decoration: _postJobInputDecoration(context),
            hint: Text(
              'Select primary category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
            items: AppConstants.postJobCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                if (value != null && _catalogReady) {
                  final allowed =
                      SkillsCatalogService.instance.skillsForCategory(value).toSet();
                  _skills.removeWhere((s) => !allowed.contains(s));
                }
              });
            },
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Skills *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedCategory == null
                ? 'Select a category to load curated skills.'
                : (!_catalogReady
                    ? 'Loading skill catalog…'
                    : 'Tap chips below or search the full catalog.'),
            style:
                AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (suggested.isNotEmpty) ...[
            Text(
              'Suggested from summary',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggested
                  .map((skill) => ActionChip(
                        label: Text(skill),
                        onPressed: () => _toggleSkill(skill),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Quick select',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skillSearchController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
            decoration: _postJobInputDecoration(context).copyWith(
              hintText: 'Search skills…',
              prefixIcon: Icon(
                Iconsax.search_normal_1,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_skillSearchController.text.trim().isNotEmpty &&
              quick.isEmpty &&
              _catalogReady)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No matching skills. Try another keyword.',
                style:
                    AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: quick
                .map((skill) => ActionChip(
                      label: Text(skill),
                      onPressed: () => _toggleSkill(skill),
                    ))
                .toList(),
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Iconsax.close_circle, size: 18),
                  onDeleted: () => _removeSkill(skill),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeekStep3() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability & target rate',
            style: AppTextStyles.heading5.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Experience Level',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...['Entry', 'Intermediate', 'Expert'].map((level) {
            return RadioListTile<String>(
              title: Text(
                level,
                style: GoogleFonts.poppins(fontSize: 15, color: scheme.onSurface),
              ),
              value: level,
              groupValue: _experienceLevel,
              activeColor: AppColors.primary,
              onChanged: (value) =>
                  setState(() => _experienceLevel = value!),
            );
          }),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Preferred engagement length',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDuration,
            dropdownColor: scheme.surfaceContainerHigh,
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
            decoration: _postJobInputDecoration(context),
            hint: Text(
              'Select duration',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
            items: _durations
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) => setState(() => _selectedDuration = value),
          ),
          if (_selectedDuration == 'Other') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durYearsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: scheme.onSurface),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Years',
                      helperText: '0–10 max',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _durMonthsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: scheme.onSurface),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Months',
                      helperText: '0–12',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _durDaysController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: scheme.onSurface),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _postJobInputDecoration(context).copyWith(
                      labelText: 'Days',
                      helperText: '0–30 (30 d → 1 mo)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Normalize on publish: rolls up weeks/months (max 10 years).',
              style: AppTextStyles.caption
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Expected hourly band *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            'Other opportunities see this as target compensation.',
            style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minHourlyController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: scheme.onSurface),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _postJobInputDecoration(context).copyWith(
                    hintText: 'Minimum (e.g. 40)',
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxHourlyController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: scheme.onSurface),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _postJobInputDecoration(context).copyWith(
                    hintText: 'Maximum (e.g. 90)',
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomOutlinedButton(
                label: 'Back',
                onPressed: _prevStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              label: _currentStep == 2
                  ? (_intent == _ListingIntent.hireTalent
                      ? 'Post job'
                      : 'Publish listing')
                  : 'Next',
              onPressed: _currentStep == 2
                  ? (_intent == _ListingIntent.hireTalent
                      ? _postJob
                      : _postSeekListing)
                  : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
