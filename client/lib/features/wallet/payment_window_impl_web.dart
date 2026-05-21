// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

html.WindowBase? _iyzicoPaymentWindow;
StreamSubscription<html.MessageEvent>? _messageSubscription;

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

void startIyzicoPaymentResultListener(void Function(String outcome) onResult) {
  stopIyzicoPaymentResultListener();
  _messageSubscription = html.window.onMessage.listen((event) {
    final outcome = _extractOutcome(event.data);
    if (outcome == null || outcome.isEmpty) return;
    onResult(outcome);
  });
}

void stopIyzicoPaymentResultListener() {
  _messageSubscription?.cancel();
  _messageSubscription = null;
}

String? _extractOutcome(dynamic raw) {
  if (raw is String) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['type'] == 'prolance-iyzico-result') {
        return decoded['outcome'] as String?;
      }
    } catch (_) {
      return null;
    }
  }
  if (raw is Map && raw['type'] == 'prolance-iyzico-result') {
    final outcome = raw['outcome'];
    return outcome is String ? outcome : null;
  }
  return null;
}
