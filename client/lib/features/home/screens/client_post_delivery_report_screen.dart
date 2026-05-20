import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/services/support_email_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

/// Client-only: after delivery is accepted / completed, report issues next to Preview
/// on My proposals — formal dispute (24h window) and/or support ticket.
class ClientPostDeliveryReportScreen extends StatefulWidget {
  const ClientPostDeliveryReportScreen({super.key, required this.proposalId});

  final String proposalId;

  @override
  State<ClientPostDeliveryReportScreen> createState() =>
      _ClientPostDeliveryReportScreenState();
}

class _ClientPostDeliveryReportScreenState
    extends State<ClientPostDeliveryReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmail = TextEditingController();
  final _details = TextEditingController();

  bool _loading = true;
  String? _accessError;
  String _jobTitle = '';
  String _freelancerName = '';
  String _lifecycle = '';
  DateTime? _deadline;
  bool _payoutFinalized = false;
  bool _submitting = false;
  bool _disputing = false;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _contactEmail.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _load() async {
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
            'id, job_id, freelancer_id, status, lifecycle_phase, delivery_dispute_deadline, payout_finalized',
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
          .select('client_id, title')
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

      final fid = '${prop['freelancer_id']}';
      String flName = '';
      final prof = await client
          .from('profiles')
          .select('full_name')
          .eq('id', fid)
          .maybeSingle();
      if (prof != null) {
        flName = '${prof['full_name'] ?? ''}'.trim();
      }

      if (!mounted) return;
      final authEmail = client.auth.currentUser?.email?.trim();
      final appEmail = context.read<AppState>().currentUser.email.trim();
      final prefill = (authEmail != null && authEmail.contains('@'))
          ? authEmail
          : (appEmail.contains('@') ? appEmail : '');

      if (!mounted) return;
      setState(() {
        _jobTitle = '${job['title'] ?? ''}'.trim();
        _freelancerName = flName.isEmpty ? 'Freelancer' : flName;
        _lifecycle =
            '${prop['lifecycle_phase'] ?? ProposalLifecycle.submitted}';
        _deadline = DateTime.tryParse(
          '${prop['delivery_dispute_deadline'] ?? ''}',
        );
        _payoutFinalized = prop['payout_finalized'] == true;
        if (_contactEmail.text.isEmpty && prefill.isNotEmpty) {
          _contactEmail.text = prefill;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _accessError = 'Could not load proposal.';
      });
    }
  }

  bool get _withinFormalDisputeWindow {
    if (_lifecycle != ProposalLifecycle.payoutPending) return false;
    if (_payoutFinalized) return false;
    final d = _deadline;
    if (d == null) return false;
    return DateTime.now().isBefore(d);
  }

  Future<void> _submitSupportTicket(AppState app) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!SupabaseConfig.isEnabled) {
      ProlanceMessenger.error(
        context,
        app.t('Supabase is disabled.', 'Supabase kapalı.'),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser!.id;
      final subject =
          '${app.t('Post-delivery report', 'Teslim sonrası bildirim')} · $_jobTitle';
      final body = '''
${app.t('Proposal ID', 'Teklif ID')}: ${widget.proposalId}
${app.t('Job', 'İlan')}: $_jobTitle
${app.t('Freelancer', 'Serbest çalışan')}: $_freelancerName
${app.t('Lifecycle', 'Aşama')}: $_lifecycle

${app.t('Client report', 'İşveren bildirimi')}:
${_details.text.trim()}
''';
      await client.from('tickets').insert({
        'author_id': uid,
        'subject': subject,
        'body': body,
        'priority': 'NORMAL',
        'status': 'OPEN',
      });
      final emailOk = await SupportEmailService.sendSupportEmail(
        subject: subject,
        body: body,
        priority: 'NORMAL',
        contactEmail: _contactEmail.text.trim(),
        source: 'client_post_delivery_report',
      );
      if (!mounted) return;
      if (!emailOk) {
        ProlanceMessenger.info(
          context,
          app.t(
            'Ticket saved. Email may not have been sent (check Edge Function).',
            'Talep kaydedildi. E-posta gönderilememiş olabilir (Edge Function).',
          ),
        );
      } else {
        ProlanceMessenger.success(
          context,
          app.t('Report submitted.', 'Bildiriminiz iletildi.'),
        );
      }
      context.pop();
    } catch (e) {
      if (mounted) {
        ProlanceMessenger.error(
          context,
          '${app.t('Could not submit.', 'Gönderilemedi.')} ($e)',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _fileFormalDispute(AppState app) async {
    if (!_withinFormalDisputeWindow) return;
    if (_details.text.trim().length < 12) {
      ProlanceMessenger.error(
        context,
        app.t(
          'Describe the issue in the box below (at least 12 characters).',
          'Aşağıdaki kutuya en az 12 karakterlik açıklama yazın.',
        ),
      );
      return;
    }
    final ok = await showProlanceDestructiveDialog(
          context,
          title: app.t('File formal dispute?', 'Resmi itiraz açılsın mı?'),
          message: app.t(
            'Demo rules: escrow may be returned and the contract marked disputed. This cannot be undone from the app.',
            'Demo kuralları: eskrow iade edilebilir ve sözleşme anlaşmazlık olarak işaretlenebilir. Uygulamadan geri alınamaz.',
          ),
          destructiveLabel: app.t('File dispute', 'İtiraz aç'),
          cancelLabel: app.t('Cancel', 'İptal'),
          icon: Iconsax.warning_2,
        ) ??
        false;
    if (!ok || !mounted) return;

    setState(() => _disputing = true);
    try {
      final repo = context.read<ProposalRepository>();
      final res = await repo.disputeDelivery(
        proposalId: widget.proposalId,
        note: _details.text.trim(),
      );
      if (!mounted) return;
      if (res['ok'] == true) {
        ProlanceMessenger.success(
          context,
          app.t('Dispute recorded.', 'İtiraz kaydedildi.'),
        );
        await repo.reloadFromRemote();
        if (mounted) context.pop();
      } else {
        final err = '${res['err'] ?? ''}';
        final msg = err == 'dispute_window_closed'
            ? app.t('The 24h window has ended.', '24 saatlik süre doldu.')
            : app.t('Could not file dispute.', 'İtiraz açılamadı.');
        ProlanceMessenger.error(context, msg);
      }
    } finally {
      if (mounted) setState(() => _disputing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(app.t('Report an issue', 'Sorun bildir')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_accessError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(app.t('Report an issue', 'Sorun bildir')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_accessError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('Report an issue', 'Sorun bildir')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          children: [
            Text(
              app.t('Completed job', 'Tamamlanan iş'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jobTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${app.t('Freelancer', 'Serbest çalışan')}: $_freelancerName',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.t('Proposal', 'Teklif')}: ${widget.proposalId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_withinFormalDisputeWindow) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.clock, size: 20, color: scheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        app.t(
                          'You are still inside the 24h payout protection window. You may file a formal dispute (demo) or send a support message below.',
                          '24 saatlik ödeme koruma süresindesiniz. Resmi itiraz (demo) açabilir veya aşağıdan destek mesajı gönderebilirsiniz.',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.35,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (SupabaseConfig.isEnabled) ...[
              Text(
                app.t('Your email (for replies)', 'E-postanız (yanıt için)'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.sms, size: 18),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) {
                    return app.t('Email required', 'E-posta gerekli');
                  }
                  if (!_emailRe.hasMatch(t)) {
                    return app.t('Invalid email', 'Geçersiz e-posta');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            Text(
              app.t('What went wrong?', 'Ne oldu?'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _details,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: app.t(
                  'Describe the problem in detail…',
                  'Sorunu ayrıntılı yazın…',
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 12) {
                  return app.t(
                    'Enter at least 12 characters.',
                    'En az 12 karakter girin.',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_withinFormalDisputeWindow) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _disputing ? null : () => _fileFormalDispute(app),
                  icon: _disputing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Iconsax.warning_2, color: scheme.error),
                  label: Text(
                    app.t('File formal dispute (demo)', 'Resmi itiraz (demo)'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _submitting ? null : () => _submitSupportTicket(app),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Iconsax.send_1),
              label: Text(
                app.t('Send support report', 'Destek bildirimi gönder'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(app.t('Cancel', 'İptal')),
            ),
          ],
        ),
      ),
    );
  }
}
