import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class PortfolioItem {
  final PlatformFile file;
  final DateTime addedAt;
  final Uint8List? thumbnailBytes;

  PortfolioItem({
    required this.file,
    DateTime? addedAt,
    this.thumbnailBytes,
  }) : addedAt = addedAt ?? DateTime.now();

  String get name => file.name;
  String get extension => (file.extension ?? '').toLowerCase();
  bool get isPdf => extension == 'pdf';
  bool get isImage => {'jpg', 'jpeg', 'png', 'gif', 'webp'}.contains(extension);
  int get sizeBytes => file.size;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get typeLabel {
    if (isPdf) return 'PDF';
    return extension.toUpperCase();
  }
}
