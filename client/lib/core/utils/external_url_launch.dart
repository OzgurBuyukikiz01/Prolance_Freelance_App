import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import '../widgets/overlays/prolance_dialog.dart';
import '../widgets/overlays/prolance_messenger.dart';

/// Parses [raw] as HTTP/HTTPS [Uri]; adds https if scheme missing.
Uri? parseExternalHttpUri(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final withScheme = t.contains('://') ? t : 'https://$t';
  final u = Uri.tryParse(withScheme);
  if (u == null || !u.hasScheme || (u.scheme != 'http' && u.scheme != 'https')) {
    return null;
  }
  return u;
}

Future<void> confirmAndLaunchExternalUrl(
  BuildContext context, {
  required String rawUrl,
}) async {
  final appState = context.read<AppState>();
  final uri = parseExternalHttpUri(rawUrl);
  if (uri == null) {
    if (!context.mounted) return;
    ProlanceMessenger.error(
      context,
      appState.t('Enter a valid website URL.', 'Geçerli bir web sitesi URL\'si girin.'),
    );
    return;
  }

  final go = await showProlanceConfirmDialog(
        context,
        title: appState.t('External website', 'Harici web sitesi'),
        message: appState.t(
          'You are being redirected to an external website.',
          'Harici bir web sitesine yönlendiriliyorsunuz.',
        ),
        cancelLabel: appState.t('Stay', 'Kal'),
        confirmLabel: appState.t('Continue', 'Devam'),
      ) ??
      false;

  if (!go || !context.mounted) return;

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ProlanceMessenger.error(
      context,
      appState.t('Could not open the link.', 'Bağlantı açılamadı.'),
    );
  }
}
