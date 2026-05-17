import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/messaging/proposal_intro_message.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/navigation/main_nav_controller.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/project_duration_ymd.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class SubmitProposalScreen extends StatefulWidget {
  const SubmitProposalScreen({super.key, required this.job});

  final JobModel job;

  @override
  State<SubmitProposalScreen> createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  final _deliveryYearsController = TextEditingController(text: '0');
  final _deliveryMonthsController = TextEditingController(text: '0');
  final _deliveryDaysController = TextEditingController(text: '0');
  final _coverLetterController = TextEditingController();
  final List<PlatformFile> _attachments = [];

  @override
  void dispose() {
    _bidController.dispose();
    _deliveryYearsController.dispose();
    _deliveryMonthsController.dispose();
    _deliveryDaysController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  InputDecoration _proposalDecoration(
    BuildContext context, {
    String? hintText,
    String? labelText,
    String? helperText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      helperText: helperText,
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w400),
      labelStyle:
          AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
      helperStyle: AppTextStyles.caption.copyWith(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingMd,
      ),
    );
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  int _proposalQualityPercent(String letter, JobModel job) {
    final t = letter.trim();
    if (t.isEmpty) return 0;
    var score = 0;
    if (t.length >= 50) score += 25;
    if (t.length >= 120) score += 25;
    if (t.split(RegExp(r'\s+')).length >= 40) score += 15;
    final lower = t.toLowerCase();
    for (final s in job.skills) {
      if (lower.contains(s.toLowerCase())) score += 5;
    }
    return score.clamp(0, 100);
  }

  Future<void> _addAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: true,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _attachments.addAll(result.files));
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<void> _sendProposalIntroToClient(
    BuildContext context, {
    required String proposalId,
    required double bid,
  }) async {
    if (!SupabaseConfig.isEnabled || !_uuid.hasMatch(proposalId)) return;

    final client = Supabase.instance.client;
    final me = client.auth.currentUser?.id;
    if (me == null) return;

    final appState = context.read<AppState>();
    final freelanceName = appState.currentUser.name;
    final msgRepo = context.read<MessageRepository>();

    String? employerId = widget.job.clientId;
    if (employerId == null || employerId.isEmpty) {
      try {
        final row = await client
            .from('jobs')
            .select('client_id')
            .eq('id', widget.job.id)
            .maybeSingle();
        employerId = row?['client_id'] as String?;
      } catch (_) {}
    }
    if (employerId == null || employerId.isEmpty || employerId == me) return;
    if (!context.mounted) return;

    try {
      final convId =
          await msgRepo.ensureDirectConversation(otherUserId: employerId);
      if (convId.startsWith('local_')) return;

      final budget = _formatBudget(widget.job);
      final skills = widget.job.skills.isEmpty
          ? '—'
          : widget.job.skills.take(8).join(', ');

      final body = ProposalIntroMessage.compose(
        jobTitle: widget.job.title,
        jobDescription: widget.job.description,
        budgetLine: budget,
        category: widget.job.category,
        duration: widget.job.duration,
        skillsLine: skills,
        pitch: _coverLetterController.text.trim(),
        profilePath: '/user/$me',
        proposalId: proposalId,
        jobId: widget.job.id,
        freelancerId: me,
        freelancerName: freelanceName,
        bid: bid,
      );

      await msgRepo.sendMessageAsync(convId, body);
    } catch (e, st) {
      debugPrint('[SubmitProposal] intro message: $e $st');
    }
  }

  Future<void> _submitProposal() async {
    if (_formKey.currentState?.validate() ?? false) {
      final y = int.tryParse(_deliveryYearsController.text.trim()) ?? 0;
      final m = int.tryParse(_deliveryMonthsController.text.trim()) ?? 0;
      final d = int.tryParse(_deliveryDaysController.text.trim()) ?? 0;
      final normalized = ProjectDurationYmd.normalize(y, m, d);
      _deliveryYearsController.text = '${normalized.years}';
      _deliveryMonthsController.text = '${normalized.months}';
      _deliveryDaysController.text = '${normalized.days}';
      setState(() {});

      if (!normalized.isPositive) {
        if (!mounted) return;
        ProlanceMessenger.error(
          context,
          context.read<AppState>().t(
            'Enter delivery time (years, months, or days).',
            'Teslim süresi girin (yıl, ay veya gün).',
          ),
        );
        return;
      }

      final repo = context.read<ProposalRepository>();
      final bid = double.tryParse(_bidController.text) ?? 0;
      final proposalId = await repo.submitProposal(
        jobId: widget.job.id,
        jobTitle: widget.job.title,
        bid: bid,
        deliveryYears: normalized.years,
        deliveryMonths: normalized.months,
        deliveryDays: normalized.days,
        coverLetter: _coverLetterController.text.trim(),
        attachmentNames: _attachments.map((f) => f.name).toList(),
      );

      if (!mounted) return;
      await _sendProposalIntroToClient(
        context,
        proposalId: proposalId ?? '',
        bid: bid,
      );

      if (!mounted) return;
      final appState = context.read<AppState>();
      await showProlanceSuccessDialog(
        context,
        title: appState.t('Proposal submitted!', 'Teklif gönderildi!'),
        message: appState.t(
          'The client can review your proposal in their inbox.',
          'İşveren teklifinizi gelen kutusunda inceleyebilir.',
        ),
        onDone: () {
          if (!context.mounted) return;
          context.read<MainNavController>().selectTab(0);
          context.go('/home');
          appState.triggerProposalSentCelebration();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter = _coverLetterController.text;
    final quality =
        _proposalQualityPercent(letter, widget.job);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Proposal'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applying for',
                        style: AppTextStyles.caption
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppConstants.paddingXs),
                      Text(
                        widget.job.title,
                        style: AppTextStyles.heading6
                            .copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: AppConstants.paddingXs),
                      Text(
                        'Budget: ${_formatBudget(widget.job)}',
                        style: AppTextStyles.bodySmallSecondary
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Your Bid',
                  style: AppTextStyles.heading6.copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: TextFormField(
                  controller: _bidController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: scheme.onSurface),
                  decoration: _proposalDecoration(
                    context,
                    hintText: 'Enter your bid amount',
                  ).copyWith(
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bid amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              FadeInUp(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  'Estimated delivery',
                  style:
                      AppTextStyles.heading6.copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
              FadeInUp(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _deliveryYearsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: scheme.onSurface),
                        decoration: _proposalDecoration(
                          context,
                          labelText: 'Years',
                          helperText: '0–10 max',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _deliveryMonthsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: scheme.onSurface),
                        decoration: _proposalDecoration(
                          context,
                          labelText: 'Months',
                          helperText: '0–12',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _deliveryDaysController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: scheme.onSurface),
                        decoration: _proposalDecoration(
                          context,
                          labelText: 'Days',
                          helperText: '0–30',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Cover Letter',
                  style:
                      AppTextStyles.heading6.copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
              FadeInUp(
                delay: const Duration(milliseconds: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _coverLetterController,
                      maxLines: 6,
                      minLines: 6,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: scheme.onSurface),
                      decoration: _proposalDecoration(
                        context,
                        hintText:
                            'Describe your approach, relevant experience, and why you\'re the best fit for this project...',
                      ).copyWith(
                        alignLabelWithHint: true,
                        contentPadding:
                            const EdgeInsets.all(AppConstants.paddingMd),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please write a cover letter';
                        }
                        if (value.length < 50) {
                          return 'Cover letter should be at least 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proposal strength: $quality%',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: quality / 100,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              FadeInUp(
                delay: const Duration(milliseconds: 260),
                child: Text(
                  'Attachments',
                  style:
                      AppTextStyles.heading6.copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
              FadeInUp(
                delay: const Duration(milliseconds: 280),
                child: OutlinedButton.icon(
                  onPressed: _addAttachment,
                  icon: const Icon(Iconsax.attach_circle, size: 20),
                  label: const Text('Add Attachment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                      vertical: AppConstants.paddingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                ),
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingMd),
                Wrap(
                  spacing: AppConstants.paddingSm,
                  runSpacing: AppConstants.paddingSm,
                  children: _attachments.asMap().entries.map((entry) {
                    final f = entry.value;
                    final label =
                        f.size > 0 ? '${f.name} (${(f.size / 1024).toStringAsFixed(1)} KB)' : f.name;
                    return Chip(
                      label: Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      deleteIcon:
                          const Icon(Iconsax.close_circle, size: 18),
                      onDeleted: () => _removeAttachment(entry.key),
                      backgroundColor: scheme.surfaceContainerHigh,
                      side: BorderSide(color: scheme.outlineVariant),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppConstants.paddingXl),
              FadeInUp(
                delay: const Duration(milliseconds: 320),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitProposal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMd),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                    ),
                    child: const Text('Submit Proposal'),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
            ],
          ),
        ),
      ),
    );
  }
}
