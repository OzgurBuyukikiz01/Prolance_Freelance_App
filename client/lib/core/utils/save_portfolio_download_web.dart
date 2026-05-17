// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

Future<void> savePortfolioDownload({
  required String name,
  required Uint8List bytes,
  String? extension,
}) async {
  final ext = extension?.replaceAll('.', '');
  final fileName = name.contains('.')
      ? name
      : (ext != null && ext.isNotEmpty ? '$name.$ext' : name);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
