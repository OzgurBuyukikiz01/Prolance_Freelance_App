import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';
import '../../../core/utils/project_duration_ymd.dart';

class ProposalDetailScreen extends StatelessWidget {
  const ProposalDetailScreen({super.key, required this.proposal});

  final SubmittedProposal proposal;

  JobModel? _resolveJob(JobsProvider jobs) {
    for (final j in jobs.jobs) {
      if (j.id == proposal.jobId) return j;
    }
    return null;
  }

  String _deliveryLabel(SubmittedProposal p) {
    final d = ProjectDurationYmd(
      p.deliveryYears,
      p.deliveryMonths,
      p.deliveryDays,
    );
    return d.formatVerbose();
  }

  String _formatBudget(JobModel job) {
    if (job.budgetType == 'fixed') {
      return '\$${job.budgetMin.toStringAsFixed(0)} – \$${job.budgetMax.toStringAsFixed(0)}';
    }
    return '\$${job.budgetMin.toStringAsFixed(0)} – \$${job.budgetMax.toStringAsFixed(0)}/hr';
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProposalRepository>();
    var current = proposal;
    for (final x in repo.myProposals) {
      if (x.id == proposal.id) {
        current = x;
        break;
      }
    }
    final job = _resolveJob(context.watch<JobsProvider>());
    final submitted =
        DateFormat.yMMMd().add_jm().format(current.submittedAt);

    final active = current.status == SubmittedProposalStatus.awaitingResponse;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        children: [
          Text(
            'Job',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: job == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.jobTitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This job is no longer in your local job list. Title is kept from when you applied.',
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.category,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Budget: ${_formatBudget(job)}',
                          style: AppTextStyles.bodySmallSecondary.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: AppTextStyles.bodyMediumSecondary.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Your proposal',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${current.bid.toStringAsFixed(0)}',
                        style: AppTextStyles.heading6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        submitted,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.calendar,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery: ${_deliveryLabel(current)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMd),
                  Text(
                    'Cover letter',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    current.coverLetter.trim().isEmpty
                        ? '—'
                        : current.coverLetter,
                    style: AppTextStyles.bodyMediumSecondary.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (current.attachmentNames.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      'Attachments',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...current.attachmentNames.map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Iconsax.document,
                                size: 16, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(child: Text(n)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'Progress',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: 12),
          _ProgressTimeline(proposal: current),
          if (SupabaseConfig.isEnabled &&
              current.status == SubmittedProposalStatus.accepted &&
              (current.lifecyclePhase == ProposalLifecycle.escrowFunded ||
                  current.lifecyclePhase == ProposalLifecycle.awaitingClientReview ||
                  current.lifecyclePhase == ProposalLifecycle.delivered)) ...[
            const SizedBox(height: AppConstants.paddingLg),
            Text(
              'Deliverables',
              style: AppTextStyles.heading6,
            ),
            const SizedBox(height: 8),
            _FreelancerDeliveriesPanel(
              proposalId: current.id,
              lifecyclePhase: current.lifecyclePhase,
            ),
          ],
          const SizedBox(height: AppConstants.paddingXl),
          if (active)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final appState = context.read<AppState>();
                  final ok = await showProlanceDestructiveDialog(
                        context,
                        title: appState.t('Cancel proposal', 'Teklifi iptal et'),
                        message: appState.t(
                          'Withdraw this proposal? The client will no longer see it.',
                          'Bu teklifi geri çekmek istiyor musunuz? İşveren artık göremeyecek.',
                        ),
                        destructiveLabel: appState.t('Withdraw', 'Geri çek'),
                        cancelLabel: appState.t('Keep', 'Vazgeç'),
                        icon: Iconsax.close_circle,
                      ) ??
                      false;
                  if (!ok || !context.mounted) return;
                  await repo.cancelProposal(current.id);
                },
                icon: Icon(Iconsax.close_circle, color: AppColors.error),
                label: Text(
                  'Cancel proposal',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingMd,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({required this.proposal});

  final SubmittedProposal proposal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = proposal.status;
    switch (status) {
      case SubmittedProposalStatus.awaitingResponse:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Waiting for client',
              subtitle: 'The client has not accepted or declined yet.',
              opacity: 1,
              tone: _StepTone.active,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Decision',
              subtitle: 'Pending response',
              opacity: 0.5,
              tone: _StepTone.upcoming,
            ),
          ],
        );
      case SubmittedProposalStatus.accepted:
        final phase = proposal.lifecyclePhase;
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Client reviewed',
              subtitle: 'The client viewed your proposal.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Accepted',
              subtitle: 'Congratulations — this proposal was accepted.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            if (phase == ProposalLifecycle.escrowFunded)
              _StepRow(
                scheme: scheme,
                title: 'Escrow funded',
                subtitle: 'Client demo balance was debited; funds are held.',
                opacity: 1,
                tone: _StepTone.active,
              ),
            if (phase == ProposalLifecycle.awaitingClientReview ||
                phase == ProposalLifecycle.delivered)
              _StepRow(
                scheme: scheme,
                title: 'With client',
                subtitle:
                    'After you submit files, the client downloads and accepts delivery.',
                opacity: 1,
                tone: _StepTone.passed,
              ),
            if (phase == ProposalLifecycle.payoutPending ||
                phase == ProposalLifecycle.closed)
              _StepRow(
                scheme: scheme,
                title: 'Client accepted delivery',
                subtitle: phase == ProposalLifecycle.closed
                    ? 'Completed — earnings available after finalize.'
                    : 'Funds released to pending; 24h dispute window for the client.',
                opacity: 1,
                tone: phase == ProposalLifecycle.closed
                    ? _StepTone.successEnd
                    : _StepTone.active,
              ),
            if (phase == ProposalLifecycle.disputed)
              _StepRow(
                scheme: scheme,
                title: 'Disputed',
                subtitle: 'This contract stopped in a disputed state (demo).',
                opacity: 1,
                tone: _StepTone.failedEnd,
              ),
          ],
        );
      case SubmittedProposalStatus.declined:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered to the client.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Client reviewed',
              subtitle: 'The client viewed your proposal.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Declined',
              subtitle: 'The client declined this proposal.',
              opacity: 1,
              tone: _StepTone.failedEnd,
            ),
          ],
        );
      case SubmittedProposalStatus.cancelled:
        return Column(
          children: [
            _StepRow(
              scheme: scheme,
              title: 'Submitted',
              subtitle: 'Your proposal was delivered.',
              opacity: 1,
              tone: _StepTone.passed,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Withdrawn',
              subtitle: 'You cancelled this proposal before a decision.',
              opacity: 1,
              tone: _StepTone.neutral,
            ),
            _StepRow(
              scheme: scheme,
              title: 'Closed',
              subtitle: 'No further action from the client.',
              opacity: 0.5,
              tone: _StepTone.upcoming,
            ),
          ],
        );
    }
  }
}

enum _StepTone { passed, active, upcoming, successEnd, failedEnd, neutral }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.scheme,
    required this.title,
    required this.subtitle,
    required this.opacity,
    required this.tone,
  });

  final ColorScheme scheme;
  final String title;
  final String subtitle;
  final double opacity;
  final _StepTone tone;

  Color _leadingColor() {
    switch (tone) {
      case _StepTone.passed:
      case _StepTone.successEnd:
        return AppColors.success;
      case _StepTone.failedEnd:
        return AppColors.error;
      case _StepTone.active:
        return AppColors.primary;
      case _StepTone.upcoming:
        return scheme.outline;
      case _StepTone.neutral:
        return scheme.onSurfaceVariant;
    }
  }

  IconData _leadingIcon() {
    switch (tone) {
      case _StepTone.passed:
      case _StepTone.successEnd:
        return Iconsax.tick_circle;
      case _StepTone.failedEnd:
        return Iconsax.close_circle;
      case _StepTone.active:
        return Iconsax.clock;
      case _StepTone.upcoming:
        return Icons.more_horiz;
      case _StepTone.neutral:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _leadingColor();
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_leadingIcon(), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tone == _StepTone.upcoming
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreelancerDeliveriesPanel extends StatefulWidget {
  const _FreelancerDeliveriesPanel({
    required this.proposalId,
    required this.lifecyclePhase,
  });

  final String proposalId;
  final String lifecyclePhase;

  @override
  State<_FreelancerDeliveriesPanel> createState() =>
      _FreelancerDeliveriesPanelState();
}

class _FreelancerDeliveriesPanelState extends State<_FreelancerDeliveriesPanel> {
  List<ProposalDeliveryRow> _rows = [];
  bool _loading = true;
  bool _uploading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _FreelancerDeliveriesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proposalId != widget.proposalId ||
        oldWidget.lifecyclePhase != widget.lifecyclePhase) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = context.read<ProposalRepository>();
    final list = await repo.fetchDeliveries(widget.proposalId);
    if (!mounted) return;
    setState(() {
      _rows = list;
      _loading = false;
    });
  }

  bool get _canUpload =>
      widget.lifecyclePhase == ProposalLifecycle.escrowFunded;

  bool get _awaitingClient =>
      widget.lifecyclePhase == ProposalLifecycle.awaitingClientReview ||
      widget.lifecyclePhase == ProposalLifecycle.delivered;

  Future<void> _pickUpload() async {
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    final res = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    final file = res?.files.single;
    final bytes = file?.bytes;
    if (bytes == null || file == null) return;

    final phaseBefore = widget.lifecyclePhase;
    setState(() => _uploading = true);
    final out = await repo.uploadDeliveryAndRegister(
      proposalId: widget.proposalId,
      fileName: file.name,
      bytes: bytes,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (out['ok'] == true) {
      await repo.reloadFromRemote();
      await _load();
      if (!mounted) return;
      // First upload from escrow also notifies the client (same as "Accept delivery").
      if (phaseBefore == ProposalLifecycle.escrowFunded) {
        await _confirmSubmitToClient();
      } else {
        ProlanceMessenger.success(
          context,
          app.t('File uploaded.', 'Dosya yüklendi.'),
        );
      }
    } else {
      ProlanceMessenger.error(
        context,
        app.t('Upload failed.', 'Yükleme başarısız.'),
      );
    }
  }

  Future<void> _confirmSubmitToClient() async {
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    setState(() => _submitting = true);
    final out = await repo.confirmFreelancerDeliverySubmission(widget.proposalId);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (out['ok'] == true) {
      await repo.reloadFromRemote();
      if (!mounted) return;
      ProlanceMessenger.success(
        context,
        app.t(
          'Delivery sent to the client for review.',
          'Teslim işverene inceleme için gönderildi.',
        ),
      );
    } else {
      final err = '${out['err'] ?? ''}';
      final msg = err == 'no_deliverables'
          ? app.t('Upload at least one file first.', 'Önce en az bir dosya yükleyin.')
          : app.t('Could not submit.', 'Gönderilemedi.');
      ProlanceMessenger.error(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();

    return Card(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_canUpload)
              FilledButton.icon(
                onPressed: _uploading ? null : _pickUpload,
                icon: _uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.document_upload),
                label: Text(
                  app.t('Upload deliverable', 'Teslim dosyası yükle'),
                ),
              ),
            if (_canUpload) const SizedBox(height: 12),
            Text(
              app.t(
                'Upload your files: the first upload from escrow is sent to the client automatically for download and approval. You can add more files while the client reviews.',
                'Dosyalarınızı yükleyin: eskrowdan ilk yükleme işverene indirip onaylaması için otomatik gider. İşveren incelerken ek dosya ekleyebilirsiniz.',
              ),
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_rows.isEmpty)
              Text(
                app.t('No deliverables yet.', 'Henüz teslim yok.'),
                style: AppTextStyles.bodyMediumSecondary,
              )
            else
              ..._rows.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.fileName)),
                    ],
                  ),
                ),
              ),
            if (_awaitingClient) ...[
              const SizedBox(height: 12),
              Text(
                app.t(
                  'Waiting for the client to download, review, and accept delivery.',
                  'İşverenin indirip inceleyip teslimi kabul etmesi bekleniyor.',
                ),
                style: AppTextStyles.caption.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_canUpload && _rows.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _submitting ? null : _confirmSubmitToClient,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(app.t('Accept delivery', 'Accept delivery')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
