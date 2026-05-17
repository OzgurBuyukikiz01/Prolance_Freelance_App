import 'dart:typed_data';

import 'save_portfolio_download_stub.dart'
    if (dart.library.html) 'save_portfolio_download_web.dart' as impl;

Future<void> savePortfolioDownload({
  required String name,
  required Uint8List bytes,
  String? extension,
}) =>
    impl.savePortfolioDownload(
      name: name,
      bytes: bytes,
      extension: extension,
    );
