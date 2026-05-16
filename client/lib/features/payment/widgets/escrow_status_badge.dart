import 'package:flutter/material.dart';

import '../../../core/models/escrow_transaction_model.dart';

class EscrowStatusBadge extends StatelessWidget {
  const EscrowStatusBadge({super.key, required this.status});

  final EscrowStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, String label) = switch (status) {
      EscrowStatus.funded => (scheme.tertiaryContainer, scheme.onTertiaryContainer, 'Funded'),
      EscrowStatus.held => (scheme.primaryContainer, scheme.onPrimaryContainer, 'Held'),
      EscrowStatus.released => (scheme.secondaryContainer, scheme.onSecondaryContainer, 'Released'),
      EscrowStatus.disputed => (scheme.errorContainer, scheme.onErrorContainer, 'Disputed'),
      EscrowStatus.refunded => (scheme.surfaceContainerHighest, scheme.onSurface, 'Refunded'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
