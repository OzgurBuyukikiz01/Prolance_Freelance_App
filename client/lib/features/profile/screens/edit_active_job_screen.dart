import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/job_model.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class EditActiveJobScreen extends StatefulWidget {
  const EditActiveJobScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<EditActiveJobScreen> createState() => _EditActiveJobScreenState();
}

class _EditActiveJobScreenState extends State<EditActiveJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _skillsController = TextEditingController();

  String? _category;
  String _budgetType = 'fixed';
  String _experienceLevel = 'Intermediate';
  String _duration = '1-3 months';
  bool _saving = false;
  JobModel? _initialJob;

  static const _durations = [
    'Less than 1 month',
    '1-3 months',
    '3-6 months',
    'More than 6 months',
    'Other',
  ];

  static const _experienceLevels = ['Entry', 'Intermediate', 'Expert'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialJob != null) return;
    final jobs = context.read<JobsProvider>().jobs;
    final job = jobs.cast<JobModel?>().firstWhere(
      (item) => item?.id == widget.jobId,
      orElse: () => null,
    );
    if (job == null) return;
    _initialJob = job;
    _titleController.text = job.title;
    _descriptionController.text = job.description;
    _budgetMinController.text = job.budgetMin.toStringAsFixed(0);
    _budgetMaxController.text = job.budgetMax.toStringAsFixed(0);
    _skillsController.text = job.skills.join(', ');
    _category = job.category;
    _budgetType = job.budgetType;
    _experienceLevel = job.experienceLevel;
    _duration = job.duration;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    String? hint,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(color: scheme.onSurfaceVariant),
      hintStyle: GoogleFonts.poppins(color: scheme.onSurfaceVariant),
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
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
    );
  }

  Future<void> _save() async {
    final current = _initialJob;
    if (current == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final min = double.tryParse(_budgetMinController.text.trim());
    final max = double.tryParse(_budgetMaxController.text.trim());
    if (min == null || max == null || min <= 0 || max <= 0 || max < min) {
      ProlanceMessenger.error(context, 'Please enter a valid budget range.');
      return;
    }

    final skills = _skillsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (skills.isEmpty) {
      ProlanceMessenger.error(context, 'Please enter at least one skill.');
      return;
    }

    final app = context.read<AppState>();
    final jobs = context.read<JobsProvider>();

    final updatedDraft = current.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      budgetMin: min,
      budgetMax: max,
      budgetType: _budgetType,
      skills: skills,
      experienceLevel: _experienceLevel,
      duration: _duration,
      clientName: app.currentUser.name,
      clientAvatar: app.currentUser.avatarUrl,
      clientId: app.currentUser.id,
    );

    setState(() => _saving = true);
    final saved = await jobs.updateJob(updatedDraft, t: app.t);
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved == null) {
      ProlanceMessenger.error(
        context,
        'Could not update this job. Please try again.',
      );
      return;
    }

    _initialJob = saved;
    ProlanceMessenger.success(context, 'Job updated. Changes are now live.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_initialJob == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Job')),
        body: const Center(child: Text('Job not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: _decoration(context, label: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Title is required.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: _decoration(
                context,
                label: 'Description',
                hint: 'Describe the work, deliverables, and expectations.',
              ),
              maxLines: 6,
              validator: (value) {
                final words = (value ?? '')
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((word) => word.isNotEmpty)
                    .length;
                if (words < 15) {
                  return 'Description must contain at least 15 words.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _decoration(context, label: 'Category'),
              items: AppConstants.postJobCategories
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Category is required.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _budgetType,
              decoration: _decoration(context, label: 'Budget Type'),
              items: const [
                DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _budgetType = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetMinController,
                    keyboardType: TextInputType.number,
                    decoration: _decoration(context, label: 'Min Budget'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _budgetMaxController,
                    keyboardType: TextInputType.number,
                    decoration: _decoration(context, label: 'Max Budget'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _experienceLevel,
              decoration: _decoration(context, label: 'Experience Level'),
              items: _experienceLevels
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _experienceLevel = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _duration,
              decoration: _decoration(context, label: 'Duration'),
              items: _durations
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _duration = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: _decoration(
                context,
                label: 'Skills',
                hint: 'Comma-separated skills',
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
