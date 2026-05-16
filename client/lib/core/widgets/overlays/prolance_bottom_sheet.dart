import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_constants.dart';

Future<T?> showProlanceBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool showDragHandle = true,
  bool showTitleBar = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => ProlanceSheetShell(
      title: title,
      showDragHandle: showDragHandle,
      showTitleBar: showTitleBar && title != null,
      child: child,
    ),
  );
}

/// Branded bottom sheet container aligned with [AppTheme.bottomSheetTheme].
class ProlanceSheetShell extends StatelessWidget {
  const ProlanceSheetShell({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showTitleBar = true,
    this.onClose,
  });

  final Widget child;
  final String? title;
  final bool showDragHandle;
  final bool showTitleBar;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (showTitleBar && title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
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
                  IconButton(
                    icon: Icon(Iconsax.close_circle, color: scheme.onSurfaceVariant),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class ProlanceSheetListTile extends StatelessWidget {
  const ProlanceSheetListTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
