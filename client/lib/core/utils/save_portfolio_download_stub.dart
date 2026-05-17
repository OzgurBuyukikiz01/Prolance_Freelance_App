import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

Future<void> savePortfolioDownload({
  required String name,
  required Uint8List bytes,
  String? extension,
}) async {
  final ext = (extension ?? 'bin').replaceAll('.', '');
  final base = name.contains('.')
      ? name.substring(0, name.lastIndexOf('.'))
      : name;
  await FileSaver.instance.saveFile(
    name: base,
    bytes: bytes,
    ext: ext,
    mimeType: MimeType.other,
  );
}
