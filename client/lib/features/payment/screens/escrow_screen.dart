import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/models/escrow_transaction_model.dart';
import '../../../core/models/job_model.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';
import '../widgets/escrow_status_badge.dart';
import '../widgets/payment_widget.dart';

class EscrowScreen extends StatefulWidget {
  const EscrowScreen({super.key, required this.job});

  final JobModel job;

  @override
  State<EscrowScreen> createState() => _EscrowScreenState();
}

class _EscrowScreenState extends State<EscrowScreen> {
  List<EscrowTransactionModel> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await PaymentService.instance.listForJob(widget.job.id);
    if (mounted) {
      setState(() {
        _rows = list;
        _loading = false;
      });
    }
  }

  Future<void> _fund(int cents) async {
    await PaymentService.instance.createFunded(
      jobId: widget.job.id,
      amountCents: cents,
    );
    await _load();
    if (mounted) {
      ProlanceMessenger.success(
        context,
        context.read<AppState>().t('Escrow funded (mock).', 'Escrow fonlandı (mock).'),
      );
    }
  }

  Future<void> _release(EscrowTransactionModel e) async {
    await PaymentService.instance.releaseToFreelancer(e.id);
    await _load();
  }

  Future<void> _dispute(EscrowTransactionModel e) async {
    await PaymentService.instance.openDispute(
      escrowId: e.id,
      reason: 'Buyer opened dispute (demo).',
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final jobOwnerId = widget.job.clientId;
    final isJobOwner = jobOwnerId != null &&
        jobOwnerId.isNotEmpty &&
        jobOwnerId == app.currentUser.id;
    // Platform admin can run mock escrow on any listing (employer_id stays admin).
    final isEmployer = isJobOwner || app.currentUser.isAdmin;
    final children = <Widget>[
      Text(
        widget.job.title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        SupabaseConfig.isEnabled
            ? 'Funds are held in-platform (mock). Release pays the freelancer.'
            : 'Enable Supabase to persist escrow rows.',
      ),
      const SizedBox(height: 16),
    ];

    if (SupabaseConfig.isEnabled && isEmployer) {
      children.addAll([
        PaymentWidget(
          onTokenLabel: (_) => _fund(
            ((widget.job.budgetMin + widget.job.budgetMax) / 2 * 100).round(),
          ),
        ),
        const SizedBox(height: 24),
      ]);
    }

    if (_rows.isEmpty && !SupabaseConfig.isEnabled) {
      children.add(const Text('No escrow data (Supabase off).'));
    }

    for (final e in _rows) {
      children.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${e.amountCents / 100} ${e.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    EscrowStatusBadge(status: e.status),
                  ],
                ),
                Text('ID: ${e.id}', style: Theme.of(context).textTheme.bodySmall),
                if (isEmployer && e.status == EscrowStatus.held) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _release(e),
                          child: const Text('Release'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _dispute(e),
                          child: const Text('Dispute'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isEmployer && e.status == EscrowStatus.funded) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _dispute(e),
                    child: const Text('Dispute'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escrow')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: children,
            ),
    );
  }
}
