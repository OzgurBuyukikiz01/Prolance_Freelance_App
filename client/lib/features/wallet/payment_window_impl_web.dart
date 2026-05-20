// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

html.WindowBase? _iyzicoPaymentWindow;

bool openIyzicoPaymentWindow(String url) {
  _iyzicoPaymentWindow = html.window.open(url, '_blank');
  return _iyzicoPaymentWindow != null;
}

void closeIyzicoPaymentWindow() {
  try {
    _iyzicoPaymentWindow?.close();
  } catch (_) {
    /* browser may block close */
  }
  _iyzicoPaymentWindow = null;
}
