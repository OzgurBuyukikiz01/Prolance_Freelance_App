import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

/// Client-only: download deliverables, accept/decline delivery, then 24h dispute.
class ClientDeliveryReviewScreen extends StatefulWidget {
  const ClientDeliveryReviewScreen({
    super.key,
    required this.proposalId,
    this.openDisputeOnLoad = false,
  });

  final String proposalId;

  /// When true (e.g. `?dispute=1` from My proposals), opens the dispute dialog once if allowed.
  final bool openDisputeOnLoad;

  @override
  State<ClientDeliveryReviewScreen> createState() =>
      _ClientDeliveryReviewScreenState();
}

class _ClientDeliveryReviewScreenState
    extends State<ClientDeliveryReviewScreen> {
  bool _loading = true;
  String? _accessError;
  String _lifecycle = ProposalLifecycle.submitted;
  String _status = 'pending';
  DateTime? _deadline;
  bool _payoutFinalized = false;
  List<ProposalDeliveryRow> _files = [];
  bool _acting = false;
  bool _autoDisputePromptShown = false;
  ProposalRepository? _repo;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _repo = context.read<ProposalRepository>();
      _repo!.addListener(_onProposalRepoChanged);
    });
    _reload();
  }

  void _onProposalRepoChanged() {
    if (mounted) {
      unawaited(_reload());
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _repo?.removeListener(_onProposalRepoChanged);
    super.dispose();
  }

  Future<void> _reload() async {
    if (!SupabaseConfig.isEnabled) {
      setState(() {
        _loading = false;
        _accessError = 'Supabase is disabled.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _accessError = null;
    });
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _loading = false;
          _accessError = 'Not signed in.';
        });
        return;
      }

      final prop = await client
          .from('proposals')
          .select(
            'id, job_id, status, lifecycle_phase, delivery_dispute_deadline, payout_finalized',
          )
          .eq('id', widget.proposalId)
          .maybeSingle();
      if (prop == null) {
        setState(() {
          _loading = false;
          _accessError = 'Proposal not found.';
        });
        return;
      }
      final jobId = '${prop['job_id']}';
      final job = await client
          .from('jobs')
          .select('client_id')
          .eq('id', jobId)
          .maybeSingle();
      if (job == null || '${job['client_id']}' != uid) {
        setState(() {
          _loading = false;
          _accessError = 'You are not the client for this job.';
        });
        return;
      }

      if (!mounted) return;
      final repo = context.read<ProposalRepository>();
      final deliveries = await repo.fetchDeliveries(widget.proposalId);

      if (!mounted) return;
      setState(() {
        _lifecycle =
            '${prop['lifecycle_phase'] ?? ProposalLifecycle.submitted}';
        _status = '${prop['status']}';
        _deadline = DateTime.tryParse(
          '${prop['delivery_dispute_deadline'] ?? ''}',
        );
        _payoutFinalized = prop['payout_finalized'] == true;
        _files = deliveries;
        _loading = false;
      });
      _syncCountdownTicker();

      if (widget.openDisputeOnLoad &&
          !_autoDisputePromptShown &&
          mounted &&
          _lifecycle == ProposalLifecycle.payoutPending &&
          !_payoutFinalized &&
          _deadline != null &&
          DateTime.now().isBefore(_deadline!)) {
        _autoDisputePromptShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_onReportIssue());
        });
      }
    } catch (e) {
      if (!mounted) return;
      _countdownTicker?.cancel();
      setState(() {
        _loading = false;
        _accessError = 'Could not load proposal.';
      });
    }
  }

  void _syncCountdownTicker() {
    _countdownTicker?.cancel();
    if (_lifecycle != ProposalLifecycle.payoutPending ||
        _payoutFinalized ||
        _deadline == null ||
        !_deadline!.isAfter(DateTime.now())) {
      return;
    }
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final deadline = _deadline;
      if (deadline == null || !deadline.isAfter(DateTime.now())) {
        _countdownTicker?.cancel();
      }
      setState(() {});
    });
  }

  Future<void> _onAcceptDelivery() async {
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    setState(() => _acting = true);
    final res = await repo.clientReviewDelivery(
      proposalId: widget.proposalId,
      accept: true,
    );
    if (!mounted) return;
    setState(() => _acting = false);
    if (res['ok'] == true) {
      ProlanceMessenger.success(
        context,
        app.t(
          'Work accepted. The freelancer is paid after 24 hours unless you report an issue.',
          'İş kabul edildi. Şikayet etmezseniz ödeme 24 saat sonra serbest kalır.',
        ),
      );
      await repo.reloadFromRemote();
      await _reload();
    } else {
      ProlanceMessenger.error(
        context,
        app.t('Could not accept delivery.', 'Teslim kabul edilemedi.'),
      );
    }
  }

  Future<void> _onDeclineDelivery() async {
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(app.t('Decline delivery?', 'Teslimi reddet?')),
        content: Text(
          app.t(
            'Demo funds return to your wallet and this contract is marked disputed.',
            'Demo bakiye cüzdanınıza döner; sözleşme anlaşmazlık olarak işaretlenir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(app.t('Cancel', 'İptal')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(app.t('Decline', 'Reddet')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _acting = true);
    final res = await repo.clientReviewDelivery(
      proposalId: widget.proposalId,
      accept: false,
    );
    if (!mounted) return;
    setState(() => _acting = false);
    if (res['ok'] == true) {
      ProlanceMessenger.success(
        context,
        app.t('Delivery declined.', 'Teslim reddedildi.'),
      );
      await repo.reloadFromRemote();
      await app.refreshProfileFromServer();
      if (mounted) context.pop();
    } else {
      ProlanceMessenger.error(
        context,
        app.t('Could not decline delivery.', 'Teslim reddedilemedi.'),
      );
    }
  }

  Future<void> _onReportIssue() async {
    final app = context.read<AppState>();
    final noteCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(app.t('Report an issue', 'Sorun bildir')),
          content: TextField(
            controller: noteCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: app.t('Brief description', 'Kısa açıklama'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(app.t('Cancel', 'İptal')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(app.t('Submit', 'Gönder')),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!mounted) return;
      final repo = context.read<ProposalRepository>();
      setState(() => _acting = true);
      final res = await repo.disputeDelivery(
        proposalId: widget.proposalId,
        note: noteCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _acting = false);
      if (res['ok'] == true) {
        ProlanceMessenger.success(
          context,
          app.t(
            'Issue recorded. Demo funds were returned.',
            'Kayıt alındı; demo bakiye iade edildi.',
          ),
        );
        await repo.reloadFromRemote();
        await app.refreshProfileFromServer();
        if (mounted) context.pop();
      } else {
        final err = '${res['err'] ?? ''}';
        final msg = err == 'dispute_window_closed'
            ? app.t('The 24h window has ended.', '24 saatlik süre doldu.')
            : app.t('Could not submit issue.', 'Bildiri gönderilemedi.');
        ProlanceMessenger.error(context, msg);
      }
    } finally {
      noteCtrl.dispose();
    }
  }

  Future<void> _openDownload(ProposalDeliveryRow f) async {
    final repo = context.read<ProposalRepository>();
    final app = context.read<AppState>();
    final url = await repo.signedDeliverableDownloadUrl(f.storagePath);
    if (!mounted) return;
    if (url == null) {
      ProlanceMessenger.error(
        context,
        app.t(
          'Could not create download link.',
          'İndirme bağlantısı oluşturulamadı.',
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    final okLaunch = await canLaunchUrl(uri);
    if (!mounted) return;
    if (okLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ProlanceMessenger.error(
        context,
        app.t('Cannot open link.', 'Bağlantı açılamadı.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(app.t('Review delivery', 'Teslimi incele'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_accessError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(app.t('Review delivery', 'Teslimi incele'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_accessError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final canClientReviewDelivery =
        _status == 'accepted' &&
        (_lifecycle == ProposalLifecycle.awaitingClientReview ||
            _lifecycle == ProposalLifecycle.delivered);
    final payoutPending = _lifecycle == ProposalLifecycle.payoutPending;
    final now = DateTime.now();
    Duration? timeLeft;
    if (payoutPending && _deadline != null && _deadline!.isAfter(now)) {
      timeLeft = _deadline!.difference(now);
    }

    return Scaffold(
      appBar: AppBar(title: Text(app.t('Review delivery', 'Teslimi incele'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            canClientReviewDelivery
                ? app.t(
                    'Download each file to review, then accept or decline delivery.',
                    'Her dosyayı indirip inceleyin; ardından teslimi kabul veya reddedin.',
                  )
                : payoutPending
                ? app.t(
                    'Delivery was accepted. You can report an issue during the window below; the freelancer does not see this button.',
                    'Teslim kabul edildi. Aşağıdaki süre içinde sorun bildirebilirsiniz; bu düğme serbest çalışanda görünmez.',
                  )
                : app.t(
                    'Delivery status for this proposal.',
                    'Bu teklifin teslim durumu.',
                  ),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_files.isEmpty)
            Text(
              app.t('No files uploaded yet.', 'Henüz dosya yüklenmedi.'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            )
          else
            ..._files.map(
              (f) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Iconsax.document, color: scheme.primary),
                  title: Text(f.fileName),
                  subtitle: Text(
                    app.t(
                      'Signed link · opens in a new tab',
                      'İmzalı bağlantı · yeni sekmede açılır',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: app.t('Download', 'İndir'),
                    icon: const Icon(Iconsax.import),
                    onPressed: () => _openDownload(f),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (canClientReviewDelivery) ...[
            Text(
              app.t(
                'Accept or decline the delivered work.',
                'Teslim edilen işi kabul veya reddedin.',
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _acting ? null : _onDeclineDelivery,
                    child: Text(app.t('Decline', 'Reddet')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _acting ? null : _onAcceptDelivery,
                    child: Text(app.t('Accept delivery', 'Teslimi kabul et')),
                  ),
                ),
              ],
            ),
          ],
          if (payoutPending && !_payoutFinalized) ...[
            const SizedBox(height: 24),
            Text(
              app.t('Payout protection window', 'Ödeme koruma süresi'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (timeLeft != null) ...[
              Text(
                app.t(
                  'Time left: ${_formatDuration(timeLeft)}',
                  'Kalan süre: ${_formatDuration(timeLeft)}',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _acting ? null : _onReportIssue,
                icon: const Icon(Iconsax.warning_2),
                label: Text(app.t('Report an Issue', 'Sorun Bildir')),
              ),
            ] else
              Text(
                app.t(
                  'The 24-hour dispute window has closed. Payment will be released to the freelancer.',
                  '24 saatlik itiraz süresi doldu. Ödeme serbest çalışana aktarılacak.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
