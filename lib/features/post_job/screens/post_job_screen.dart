import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _titleController = TextEditingController();
  String? _selectedCategory;
  final _descriptionController = TextEditingController();

  final List<String> _skills = [];
  final _skillInputController = TextEditingController();
  String _experienceLevel = 'Entry';
  String? _selectedDuration;

  bool _isFixedPrice = true;
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();

  static const List<String> _categories = [
    'Mobile Dev',
    'Web Dev',
    'UI/UX Design',
    'Data Science',
    'Cloud & DevOps',
    'Graphic Design',
    'Content Writing',
    'Video Editing',
    'Digital Marketing',
    'Blockchain',
  ];

  static const List<String> _durations = [
    'Less than 1 month',
    '1-3 months',
    '3-6 months',
    'More than 6 months',
  ];

  static const List<String> _presetSkills = [
    'Flutter',
    'Dart',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'C#',
    'UI/UX',
    'SEO',
    'Social Media Marketing',
    'Copywriting',
    'Google Ads',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _skillInputController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
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

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _postJob() {
    if (!_validateStep3()) return;

    final appState = context.read<AppState>();
    final min = double.tryParse(_minBudgetController.text.trim()) ?? 0;
    final max = double.tryParse(_maxBudgetController.text.trim()) ?? 0;

    appState.addJob(
      JobModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientName: appState.currentUser.name,
        clientAvatar: appState.currentUser.avatarUrl,
        budgetMin: min,
        budgetMax: max,
        budgetType: _isFixedPrice ? 'fixed' : 'hourly',
        category: _selectedCategory ?? 'General',
        skills: _skills,
        experienceLevel: _experienceLevel,
        postedDate: DateTime.now(),
        proposalCount: 0,
        duration: _selectedDuration ?? 'Less than 1 month',
        isSaved: false,
        status: 'open',
      ),
    );

    _showSuccessDialog();
  }

  bool _validateStep1() {
    final title = _titleController.text.trim();
    final words = _descriptionController.text.trim().split(RegExp(r'\s+'));
    if (title.isEmpty || _selectedCategory == null) {
      _showError('Job Title and Category are required.');
      return false;
    }
    if (words.length < 50) {
      _showError('Description must have at least 50 words.');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_skills.isEmpty) {
      _showError('Please add at least one skill.');
      return false;
    }
    if (_selectedDuration == null) {
      _showError('Please select project duration.');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    final min = double.tryParse(_minBudgetController.text.trim());
    final max = double.tryParse(_maxBudgetController.text.trim());
    if (min == null || max == null || min <= 0 || max <= 0 || max < min) {
      _showError('Please enter a valid budget range.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLg),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_circle5,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              Text(
                'Your job has been posted!',
                style: AppTextStyles.heading5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              Text(
                'Freelancers can now view and submit proposals for your job.',
                style: AppTextStyles.bodyMediumSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLg),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Post a Job',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
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
                  color: AppColors.textSecondary,
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
                    color: isActive
                        ? AppColors.primary
                        : AppColors.grey300,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: AppTextStyles.heading5,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd,
                vertical: AppConstants.paddingMd,
              ),
            ),
            hint: Text(
              'Select category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
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
            'Minimum 50 words required',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements',
            style: AppTextStyles.heading5,
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Skills needed',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  decoration: InputDecoration(
                    hintText: 'Add skill and press +',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                      vertical: AppConstants.paddingMd,
                    ),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addSkill,
                icon: const Icon(Iconsax.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetSkills
                .map(
                  (skill) => ActionChip(
                    label: Text(skill),
                    onPressed: () {
                      if (!_skills.contains(skill)) {
                        setState(() => _skills.add(skill));
                      }
                    },
                  ),
                )
                .toList(),
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 12),
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
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Experience Level',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...['Entry', 'Intermediate', 'Expert'].map((level) {
            return RadioListTile<String>(
              title: Text(level),
              value: level,
              groupValue: _experienceLevel,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => _experienceLevel = value!),
            );
          }),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Project Duration',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDuration,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd,
                vertical: AppConstants.paddingMd,
              ),
            ),
            hint: Text(
              'Select duration',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            items: _durations
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) => setState(() => _selectedDuration = value),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: AppTextStyles.heading5,
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFixedPrice = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isFixedPrice
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: _isFixedPrice
                            ? AppColors.primary
                            : AppColors.grey300,
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
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFixedPrice = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isFixedPrice
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: !_isFixedPrice
                            ? AppColors.primary
                            : AppColors.grey300,
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
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Estimated budget',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minBudgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Min',
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                      vertical: AppConstants.paddingMd,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxBudgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Max',
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                      vertical: AppConstants.paddingMd,
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            flex: _currentStep > 0 ? 1 : 1,
            child: CustomButton(
              label: _currentStep == 2 ? 'Post Job' : 'Next',
              onPressed: _currentStep == 2 ? _postJob : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
