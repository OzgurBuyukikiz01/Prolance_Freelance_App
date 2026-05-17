import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prolance_app/core/repositories/proposal_repository.dart';
import 'package:prolance_app/core/models/submitted_proposal_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProposalRepository (local / SharedPrefs only)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initialize with empty prefs returns empty list', () async {
      final repo = ProposalRepository();
      await repo.initialize();
      expect(repo.myProposals, isEmpty);
    });

    test('submitProposal adds entry to local list', () async {
      final repo = ProposalRepository();
      await repo.initialize();

      await repo.submitProposal(
        jobId: 'job_1',
        jobTitle: 'Flutter Dev',
        bid: 500,
        deliveryYears: 0,
        deliveryMonths: 1,
        deliveryDays: 0,
        coverLetter: 'I am a great Flutter developer.',
        attachmentNames: [],
      );

      expect(repo.myProposals.length, 1);
      expect(repo.myProposals.first.jobId, 'job_1');
      expect(repo.myProposals.first.bid, 500);
      expect(
        repo.myProposals.first.status,
        SubmittedProposalStatus.awaitingResponse,
      );
    });

    test('submitProposal persists to SharedPrefs', () async {
      final repo = ProposalRepository();
      await repo.initialize();
      await repo.submitProposal(
        jobId: 'job_2',
        jobTitle: 'Node.js Dev',
        bid: 800,
        deliveryYears: 0,
        deliveryMonths: 0,
        deliveryDays: 14,
        coverLetter: 'Experience with Node.js.',
        attachmentNames: ['cv.pdf'],
      );

      // Reload from SharedPrefs.
      final repo2 = ProposalRepository();
      await repo2.initialize();
      expect(repo2.myProposals.length, 1);
      expect(repo2.myProposals.first.jobTitle, 'Node.js Dev');
    });

    test('cancelProposal sets status to cancelled', () async {
      final repo = ProposalRepository();
      await repo.initialize();
      await repo.submitProposal(
        jobId: 'job_3',
        jobTitle: 'React Native Dev',
        bid: 400,
        deliveryYears: 0,
        deliveryMonths: 0,
        deliveryDays: 7,
        coverLetter: 'I build React Native apps.',
        attachmentNames: [],
      );

      final id = repo.myProposals.first.id;
      await repo.cancelProposal(id);
      expect(repo.myProposals.first.status, SubmittedProposalStatus.cancelled);
    });

    test('cancelProposal does nothing if already cancelled', () async {
      final repo = ProposalRepository();
      await repo.initialize();
      await repo.submitProposal(
        jobId: 'job_4',
        jobTitle: 'Test Job',
        bid: 200,
        deliveryYears: 0,
        deliveryMonths: 0,
        deliveryDays: 3,
        coverLetter: 'Test cover letter.',
        attachmentNames: [],
      );

      final id = repo.myProposals.first.id;
      await repo.cancelProposal(id);
      await repo.cancelProposal(id); // second call is no-op

      expect(repo.myProposals.first.status, SubmittedProposalStatus.cancelled);
      expect(repo.myProposals.length, 1);
    });

    test('dismissFromMyList removes withdrawn proposal and hides on reload',
        () async {
      final repo = ProposalRepository();
      await repo.initialize();
      await repo.submitProposal(
        jobId: 'job_5',
        jobTitle: 'Swipe test',
        bid: 100,
        deliveryYears: 0,
        deliveryMonths: 0,
        deliveryDays: 1,
        coverLetter: 'x',
        attachmentNames: [],
      );
      final id = repo.myProposals.first.id;
      await repo.cancelProposal(id);
      expect(repo.myProposals.first.status, SubmittedProposalStatus.cancelled);

      await repo.dismissFromMyList(id);
      expect(repo.myProposals, isEmpty);

      final repo2 = ProposalRepository();
      await repo2.initialize();
      expect(repo2.myProposals, isEmpty);
    });
  });
}
