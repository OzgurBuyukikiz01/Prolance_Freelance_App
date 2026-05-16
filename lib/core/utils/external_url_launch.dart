import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final uri = parseExternalHttpUri(rawUrl);
  if (uri == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid website URL.')),
    );
    return;
  }

  final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('External website'),
          content: const Text(
            'You are being redirected to an external website.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      ) ??
      false;

  if (!go || !context.mounted) return;

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the link.')),
    );
  }
}
