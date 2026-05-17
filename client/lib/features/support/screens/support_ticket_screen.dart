import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  String _priority = 'NORMAL';
  bool _isLoading = false;
  bool _isSuccess = false;

  static const _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
  static const _priorityLabels = {
    'LOW': 'Low',
    'NORMAL': 'Normal',
    'HIGH': 'High',
    'URGENT': 'Urgent',
  };
  static const _priorityColors = {
    'LOW': Colors.green,
    'NORMAL': Colors.blue,
    'HIGH': Colors.orange,
    'URGENT': Colors.red,
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      if (SupabaseConfig.isEnabled) {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        if (uid != null) {
          await client.from('tickets').insert({
            'author_id': uid,
            'subject': _subjectController.text.trim(),
            'body': _bodyController.text.trim(),
            'priority': _priority,
            'status': 'OPEN',
          });
        }
      } else {
        // Demo build: simulate network delay.
        await Future.delayed(const Duration(milliseconds: 800));
      }
      if (mounted) setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) {
        ProlanceMessenger.error(
          context,
          context.read<AppState>().t('An error occurred: $e', 'Hata oluştu: $e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support ticket',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSuccess ? _buildSuccess(scheme) : _buildForm(scheme),
    );
  }

  Widget _buildSuccess(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: Colors.green,
                size: 44,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            Text(
              'Request received!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Our support team will get back to you\nas soon as possible.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Iconsax.arrow_left, size: 18),
              label: Text(
                'Back to settings',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We usually reply within 24 hours.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Subject
            Text(
              'Subject',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Briefly describe the issue',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
                prefixIcon: const Icon(Iconsax.edit_2, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Subject cannot be empty';
                if (v.trim().length < 5) return 'Enter at least 5 characters';
                return null;
              },
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Priority
            Text(
              'Priority',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _priorities.map((p) {
                final selected = _priority == p;
                final color = _priorityColors[p]!;
                return ChoiceChip(
                  label: Text(
                    _priorityLabels[p]!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : color,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _priority = p),
                  selectedColor: color,
                  backgroundColor: color.withValues(alpha: 0.1),
                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                );
              }).toList(),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // Body
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyController,
              maxLines: 6,
              style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Describe your issue or suggestion in detail...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Description cannot be empty';
                if (v.trim().length < 20) {
                  return 'Enter at least 20 characters';
                }
                return null;
              },
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Iconsax.send_1, size: 18),
              label: Text(
                _isLoading ? 'Sending...' : 'Submit ticket',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),
          ],
        ),
      ),
    );
  }
}
