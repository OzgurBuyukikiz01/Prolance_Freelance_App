import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:prolance_app/features/messages/widgets/quick_reply_bar.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('QuickReplyBar renders at least one chip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickReplyBar(onSelect: (_) {}),
        ),
      ),
    );
    await tester.pump();

    // Should contain the first reply text.
    expect(
      find.textContaining('Merhaba'),
      findsWidgets,
    );
  });

  testWidgets('QuickReplyBar fires onSelect with correct text', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 60,
            child: QuickReplyBar(onSelect: (t) => selected = t),
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap the first visible chip.
    final firstInkWell = find.byType(InkWell).first;
    await tester.tap(firstInkWell);

    expect(selected, isNotNull);
    expect(selected, isNotEmpty);
  });
}
