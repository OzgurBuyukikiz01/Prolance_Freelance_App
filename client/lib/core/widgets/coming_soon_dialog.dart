import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'overlays/prolance_dialog.dart';

Future<void> showComingSoonDialog(
  BuildContext context, {
  required String feature,
}) {
  final t = context.read<AppState>().t;
  return showProlanceInfoDialog(
    context,
    title: t('Coming soon', 'Yakında'),
    message: t(
      '$feature will be available in a future update.',
      '$feature gelecek bir güncellemede kullanıma sunulacak.',
    ),
  );
}
