import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';

class SubmitProposalScreen extends StatefulWidget {
  const SubmitProposalScreen({super.key, required this.job});

  final JobModel job;

  @override
  State<SubmitProposalScreen> createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _coverLetterController = TextEditingController();
  final List<String> _attachments = [];

  @override
  void dispose() {
    _bidController.dispose();
    _deliveryTimeController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} - \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  void _addAttachment() {
    setState(() {
      _attachments.add('document_${_attachments.length + 1}.pdf');
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _submitProposal() {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLg),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle5,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              Text(
                'Proposal Submitted!',
                style: AppTextStyles.heading5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              Text(
                'Your proposal has been sent successfully. The client will review it and get back to you soon.',
                style: AppTextStyles.bodyMediumSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Pop back to job detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Proposal'),
        backgroundColor: AppColors.surface,
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
              // Job title reference
              Container(
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
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Text(
                      widget.job.title,
                      style: AppTextStyles.heading6,
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Text(
                      'Budget: ${_formatBudget(widget.job)}',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLg),

              // Your Bid section
              Text(
                'Your Bid',
                style: AppTextStyles.heading6,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              TextFormField(
                controller: _bidController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter your bid amount',
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
              const SizedBox(height: AppConstants.paddingLg),

              // Delivery Time section
              Text(
                'Delivery Time',
                style: AppTextStyles.heading6,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              TextFormField(
                controller: _deliveryTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Number of days to complete',
                  suffixText: 'days',
                  suffixStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery time';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return 'Please enter a valid number of days';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingLg),

              // Cover Letter section
              Text(
                'Cover Letter',
                style: AppTextStyles.heading6,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              TextFormField(
                controller: _coverLetterController,
                maxLines: 6,
                minLines: 6,
                decoration: InputDecoration(
                  hintText: 'Describe your approach, relevant experience, and why you\'re the best fit for this project...',
                  alignLabelWithHint: true,
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
                  contentPadding: const EdgeInsets.all(AppConstants.paddingMd),
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
              const SizedBox(height: AppConstants.paddingLg),

              // Attachments section
              Text(
                'Attachments',
                style: AppTextStyles.heading6,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              OutlinedButton.icon(
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
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingMd),
                Wrap(
                  spacing: AppConstants.paddingSm,
                  runSpacing: AppConstants.paddingSm,
                  children: _attachments.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(
                        entry.value,
                        style: AppTextStyles.bodySmall,
                      ),
                      deleteIcon: const Icon(Iconsax.close_circle, size: 18),
                      onDeleted: () => _removeAttachment(entry.key),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.grey300),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppConstants.paddingXl),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: const Text('Submit Proposal'),
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
