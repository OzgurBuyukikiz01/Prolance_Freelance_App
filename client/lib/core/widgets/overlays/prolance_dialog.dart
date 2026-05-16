import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../state/app_state.dart';
import '../custom_button.dart';

/// Localized string with English fallback when [AppState] is unavailable.
String prolanceT(BuildContext context, String en, String tr) {
  try {
    return context.read<AppState>().t(en, tr);
  } catch (_) {
    return en;
  }
}

Future<void> showProlanceInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? okLabel,
  IconData? icon,
}) {
  final ok = okLabel ?? prolanceT(context, 'OK', 'Tamam');
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _ProlanceDialogShell(
      title: title,
      icon: icon,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            ok,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
          ),
        ),
      ],
      child: Text(
        message,
        style: _bodyStyle(dialogContext),
      ),
    ),
  );
}

Future<bool?> showProlanceConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? cancelLabel,
  String? confirmLabel,
  IconData? icon,
}) {
  final cancel = cancelLabel ?? prolanceT(context, 'Cancel', 'İptal');
  final confirm = confirmLabel ?? prolanceT(context, 'Confirm', 'Onayla');
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => _ProlanceDialogShell(
      title: title,
      icon: icon,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            cancel,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirm,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
          ),
        ),
      ],
      child: Text(
        message,
        style: _bodyStyle(dialogContext),
      ),
    ),
  );
}

Future<bool?> showProlanceDestructiveDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String destructiveLabel,
  String? cancelLabel,
  IconData? icon,
}) {
  final cancel = cancelLabel ?? prolanceT(context, 'Cancel', 'İptal');
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => _ProlanceDialogShell(
      title: title,
      icon: icon ?? Iconsax.logout,
      iconColor: AppColors.error,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            cancel,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            destructiveLabel,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ],
      child: Text(
        message,
        style: _bodyStyle(dialogContext),
      ),
    ),
  );
}

Future<void> showProlanceSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? buttonLabel,
  VoidCallback? onDone,
  bool barrierDismissible = false,
  IconData icon = Iconsax.tick_circle5,
  Color? iconColor,
}) {
  final label = buttonLabel ?? prolanceT(context, 'Done', 'Tamam');
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final accent = iconColor ?? AppColors.secondary;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLg),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: accent),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSm),
              Text(
                message,
                style: _bodyStyle(dialogContext),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLg),
              CustomButton(
                label: label,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onDone?.call();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shared dialog frame for custom content (e.g. terms scroll, skill input).
Future<T?> showProlanceFramedDialog<T>({
  required BuildContext context,
  String? title,
  required Widget child,
  List<Widget>? actions,
  bool barrierDismissible = true,
  EdgeInsets? insetPadding,
  BoxConstraints? constraints,
  Widget? titleTrailing,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => _ProlanceDialogShell(
      title: title,
      actions: actions ?? const [],
      insetPadding: insetPadding,
      constraints: constraints,
      titleTrailing: titleTrailing,
      child: child,
    ),
  );
}

TextStyle _bodyStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 14,
    height: 1.45,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

class _ProlanceDialogShell extends StatelessWidget {
  const _ProlanceDialogShell({
    this.title,
    required this.child,
    required this.actions,
    this.icon,
    this.iconColor,
    this.insetPadding,
    this.constraints,
    this.titleTrailing,
  });

  final String? title;
  final Widget child;
  final List<Widget> actions;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsets? insetPadding;
  final BoxConstraints? constraints;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dialogTheme = Theme.of(context).dialogTheme;

    return Dialog(
      insetPadding: insetPadding ??
          dialogTheme.insetPadding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: dialogTheme.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
      child: ConstrainedBox(
        constraints: constraints ?? const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 28,
                        color: iconColor ?? scheme.primary,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (titleTrailing != null) titleTrailing!,
                  ],
                ),
                const SizedBox(height: 12),
              ],
              child,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
