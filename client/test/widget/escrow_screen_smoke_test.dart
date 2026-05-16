import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prolance_app/core/models/job_model.dart';
import 'package:prolance_app/core/state/app_state.dart';
import 'package:prolance_app/features/payment/screens/escrow_screen.dart';

JobModel _demoJob() => JobModel(
      id: 'escrow_test_job',
      title: 'Escrow Test Job',
      description: 'Test description.',
      clientName: 'Test Client',
      clientAvatar: 'https://i.pravatar.cc/150?img=5',
      budgetMin: 500,
      budgetMax: 1500,
      budgetType: 'fixed',
      category: 'Mobile Development',
      skills: ['Flutter'],
      experienceLevel: 'Intermediate',
      postedDate: DateTime(2026, 5, 1),
      proposalCount: 0,
      duration: '< 1 month',
      isSaved: false,
      status: 'open',
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('EscrowScreen renders without throwing (smoke)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState()..initialize(),
        child: MaterialApp(
          home: EscrowScreen(job: _demoJob()),
        ),
      ),
    );
    // First pump initializes the widget tree.
    await tester.pump();

    // The screen shows either the title or a loading indicator.
    final titleOrLoading = find.byWidgetPredicate(
      (w) =>
          (w is CircularProgressIndicator) ||
          (w is Text && (w.data?.contains('Escrow') ?? false)),
    );
    expect(titleOrLoading, findsWidgets);
  });
}
