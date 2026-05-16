import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:prolance_app/core/models/job_model.dart';
import 'package:prolance_app/core/widgets/job_card.dart';

// Disable HTTP font fetching in tests.
void _disableFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

JobModel _makeJob({bool isSaved = false}) {
  return JobModel(
    id: 'test_job_1',
    title: 'Flutter Developer Needed',
    description: 'Build a cross-platform app with Flutter.',
    clientName: 'Acme Corp',
    clientAvatar: 'https://i.pravatar.cc/150?img=1',
    budgetMin: 1000,
    budgetMax: 3000,
    budgetType: 'fixed',
    category: 'Mobile Development',
    skills: ['Flutter', 'Dart'],
    experienceLevel: 'Intermediate',
    postedDate: DateTime(2026, 5, 1),
    proposalCount: 5,
    duration: '1-3 months',
    isSaved: isSaved,
    status: 'open',
  );
}

void main() {
  _disableFonts();

  testWidgets('JobCard renders job title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: _makeJob()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Flutter Developer Needed'), findsOneWidget);
  });

  testWidgets('JobCard renders client name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: _makeJob()),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Acme Corp'), findsOneWidget);
  });

  testWidgets('JobCard renders budget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: _makeJob()),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('\$1000'), findsWidgets);
  });

  testWidgets('JobCard calls onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(
            job: _makeJob(),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(JobCard));
    expect(tapped, isTrue);
  });

  testWidgets('JobCard calls onSaveToggle when save button tapped',
      (tester) async {
    bool? savedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(
            job: _makeJob(isSaved: false),
            onSaveToggle: (v) => savedValue = v,
          ),
        ),
      ),
    );
    await tester.pump();

    // Find and tap the save IconButton.
    final saveBtn = find.byWidgetPredicate(
      (w) => w is IconButton,
    );
    expect(saveBtn, findsWidgets);
    await tester.tap(saveBtn.last);
    expect(savedValue, isNotNull);
  });
}
