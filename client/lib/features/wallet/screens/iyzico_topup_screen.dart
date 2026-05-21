import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../payment_window.dart';

/// iyzico Checkout Form sandbox — credits [UserModel.demoBalanceCents] after callback.
///
/// Flow: user pays on iyzico-hosted page → when the return URL is seen (Supabase
/// `iyzico-checkout-callback` or `io.prolance.app://iyzico-result`), wait **2s**
/// then close the payment surface → **5s** full-screen spinner → **4s** info card
/// → poll balance for up to **30s**.
class IyzicoTopupScreen extends StatefulWidget {
  const IyzicoTopupScreen({super.key});

  @override
  State<IyzicoTopupScreen> createState() => _IyzicoTopupScreenState();
}

class _IyzicoTopupScreenState extends State<IyzicoTopupScreen> {
  static const _presets = <(int cents, String label)>[
    (5000, '₺50'),
    (10000, '₺100'),
    (20000, '₺200'),
  ];

  int _selectedCents = 5000;
  bool _paying = false;
  int _sessionGeneration = 0;

  bool _blockingSpinner = false;
  bool _checkingPopup = false;
  String? _paymentPageUrl;
  bool _paymentSurfaceVisible = false;
  bool _webPaymentWindowOpened = false;

  bool _hostEndCloseArmed = false;
  Timer? _hostCloseTimer;

  int? _checkoutBaselineCents;
  int? _expectedTopupCents;

  bool get _nativePaymentOpen =>
      !kIsWeb && _paymentPageUrl != null && _paymentSurfaceVisible;

  bool get _checkoutBusy =>
      _paying ||
      _blockingSpinner ||
      _checkingPopup ||
      _nativePaymentOpen ||
      _webPaymentWindowOpened;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      startIyzicoPaymentResultListener(_handleWebPaymentResult);
    }
  }

  static bool _isHostFlowEndUrl(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return false;
    if (u.scheme == 'io.prolance.app' && u.host == 'iyzico-result') {
      return true;
    }
    return url.contains('iyzico-checkout-callback');
  }

  /// Called when the hosted payment flow reaches the return/callback URL (WebView),
  /// or manually on web when the user finishes in the external tab.
  void _onIyzicoHostFlowEnded() {
    if (!mounted) return;
    if (_hostEndCloseArmed) return;
    _hostEndCloseArmed = true;

    final sessionGen = _sessionGeneration;
    _hostCloseTimer?.cancel();
    _hostCloseTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || sessionGen != _sessionGeneration) return;
      setState(() {
        _paymentPageUrl = null;
        _paymentSurfaceVisible = false;
        _webPaymentWindowOpened = false;
        _hostEndCloseArmed = false;
      });
      closeIyzicoPaymentWindow();
      unawaited(_runPostCloseSequence(sessionGen));
    });
  }

  void _handleWebPaymentResult(String outcome) {
    if (!mounted) return;
    if (!_webPaymentWindowOpened && !_checkingPopup && !_paying) return;

    _onIyzicoHostFlowEnded();

    final app = context.read<AppState>();
    final message = switch (outcome) {
      'success' => app.t(
        'Payment completed. We are verifying your balance update.',
        'Ödeme tamamlandı. Bakiye güncellemesi doğrulanıyor.',
      ),
      'not_paid' || 'failed' || 'amount_mismatch' || 'credit_error' => app.t(
        'Payment did not complete successfully.',
        'Ödeme başarıyla tamamlanmadı.',
      ),
      _ => app.t(
        'Payment flow finished. We are checking the result.',
        'Ödeme akışı tamamlandı. Sonuç kontrol ediliyor.',
      ),
    };

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runPostCloseSequence(int generation) async {
    if (!mounted || generation != _sessionGeneration) return;
    setState(() => _blockingSpinner = true);

    await Future<void>.delayed(const Duration(seconds: 5));
    if (!mounted || generation != _sessionGeneration) return;
    setState(() {
      _blockingSpinner = false;
      _checkingPopup = true;
    });

    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted || generation != _sessionGeneration) return;
    setState(() => _checkingPopup = false);

    await _pollBalanceWithin30s();
  }

  Future<void> _pollBalanceWithin30s() async {
    final baseline = _checkoutBaselineCents;
    final delta = _expectedTopupCents;
    if (baseline == null || delta == null) return;
    final app = context.read<AppState>();
    for (var i = 0; i < 60; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await app.refreshProfileFromServer();
      if (!mounted) return;
      final now = app.currentUser.demoBalanceCents;
      if (now >= baseline + delta) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              app.t(
                'Your demo balance has been updated.',
                'Demo bakiyeniz güncellendi.',
              ),
            ),
          ),
        );
        return;
      }
    }
  }

  void _invalidateSession() {
    _sessionGeneration++;
    _hostCloseTimer?.cancel();
    closeIyzicoPaymentWindow();
    setState(() {
      _blockingSpinner = false;
      _checkingPopup = false;
      _paymentPageUrl = null;
      _paymentSurfaceVisible = false;
      _webPaymentWindowOpened = false;
      _hostEndCloseArmed = false;
    });
  }

  Future<void> _startCheckout() async {
    if (!SupabaseConfig.isEnabled) return;
    final app = context.read<AppState>();
    final baseline = app.currentUser.demoBalanceCents;

    setState(() {
      _paying = true;
      _sessionGeneration++;
      _hostCloseTimer?.cancel();
      _hostEndCloseArmed = false;
      _blockingSpinner = false;
      _checkingPopup = false;
      _paymentPageUrl = null;
      _paymentSurfaceVisible = false;
      _webPaymentWindowOpened = false;
      _checkoutBaselineCents = baseline;
      _expectedTopupCents = _selectedCents;
    });
    final gen = _sessionGeneration;

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'iyzico-init-checkout',
        body: <String, dynamic>{'amount_cents': _selectedCents},
      );
      if (res.status != 200) {
        final raw = res.data;
        final err = raw is Map ? raw['error'] : null;
        final hint = raw is Map ? raw['hint'] : null;
        if (!mounted) return;
        _invalidateSession();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              app.t(
                'iyzico init failed (${res.status}): ${err ?? raw}${hint != null ? '\n$hint' : ''}',
                'iyzico başlatılamadı (${res.status}): ${err ?? raw}${hint != null ? '\n$hint' : ''}',
              ),
            ),
          ),
        );
        return;
      }
      final raw = res.data;
      if (raw is! Map) {
        throw Exception('bad_response');
      }
      final err = raw['error'] as String?;
      if (err != null) {
        if (!mounted) return;
        _invalidateSession();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              app.t(
                'iyzico: $err. See docs/IYZICO_SANDBOX.md',
                'iyzico: $err. docs/IYZICO_SANDBOX.md',
              ),
            ),
          ),
        );
        return;
      }
      final paymentPageUrl = raw['paymentPageUrl'] as String?;
      if (paymentPageUrl == null || paymentPageUrl.isEmpty) {
        throw Exception('no_payment_url');
      }
      if (!mounted) return;
      if (gen != _sessionGeneration) return;

      if (kIsWeb) {
        final opened = openIyzicoPaymentWindow(paymentPageUrl);
        if (!opened) {
          await launchUrl(
            Uri.parse(paymentPageUrl),
            mode: LaunchMode.externalApplication,
          );
        }
        if (!mounted) return;
        setState(() => _webPaymentWindowOpened = true);
      } else {
        setState(() {
          _paymentPageUrl = paymentPageUrl;
          _paymentSurfaceVisible = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _invalidateSession();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppState>().t(
              'Could not start iyzico checkout: $e',
              'iyzico ödemesi başlatılamadı: $e',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  void dispose() {
    _hostCloseTimer?.cancel();
    if (kIsWeb) {
      stopIyzicoPaymentResultListener();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();

    final hideList = _nativePaymentOpen;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: scheme.onSurface),
          onPressed: _checkoutBusy ? null : () => context.pop(),
        ),
        title: Text(
          app.t(
            'Add demo balance (iyzico sandbox)',
            'Bakiye ekle (iyzico sandbox)',
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        backgroundColor: scheme.surface,
      ),
      body: Stack(
        children: [
          if (!hideList)
            ListView(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        color: scheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          app.t(
                            'Sandbox only. No live charges. Amounts are in TRY.',
                            'Yalnızca test ortamı. Gerçek tahsilat yok. Tutarlar TRY.',
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.35,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),
                Text(
                  app.t('Amount', 'Tutar'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _presets)
                      ChoiceChip(
                        label: Text(p.$2),
                        selected: _selectedCents == p.$1,
                        onSelected: _checkoutBusy
                            ? null
                            : (_) => setState(() => _selectedCents = p.$1),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLg),
                FilledButton.icon(
                  onPressed: (!SupabaseConfig.isEnabled || _checkoutBusy)
                      ? null
                      : _startCheckout,
                  icon: _paying
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : const Icon(Iconsax.wallet_add),
                  label: Text(
                    app.t('Pay with iyzico (demo)', 'iyzico ile öde (demo)'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (kIsWeb && _webPaymentWindowOpened) ...[
                  const SizedBox(height: AppConstants.paddingLg),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMd),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          app.t(
                            'When you have finished paying in the other tab, tap below. The app cannot detect the bank tab automatically on web.',
                            'Diğer sekmede ödemeyi bitirdiğinizde aşağıya basın. Web’de banka sekmesi otomatik algılanamaz.',
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _hostEndCloseArmed
                              ? null
                              : _onIyzicoHostFlowEnded,
                          child: Text(
                            app.t('I finished paying', 'Ödemeyi tamamladım'),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          if (_nativePaymentOpen)
            Positioned.fill(
              child: _EmbeddedCheckoutWebView(
                key: ValueKey(_paymentPageUrl),
                url: _paymentPageUrl!,
                onHostFlowEnd: _onIyzicoHostFlowEnded,
              ),
            ),
          if (_blockingSpinner)
            Positioned.fill(
              child: ColoredBox(
                color: scheme.surface.withValues(alpha: 0.92),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        app.t('Please wait…', 'Lütfen bekleyin…'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_checkingPopup)
            Positioned.fill(
              child: Material(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          app.t(
                            'We are checking your payment information; your money will be reflected to your balance as soon as possible.',
                            'Ödeme bilgileriniz kontrol ediliyor; tutar en kısa sürede bakiyenize yansıyacaktır.',
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            height: 1.45,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmbeddedCheckoutWebView extends StatefulWidget {
  const _EmbeddedCheckoutWebView({
    super.key,
    required this.url,
    required this.onHostFlowEnd,
  });

  final String url;
  final VoidCallback onHostFlowEnd;

  @override
  State<_EmbeddedCheckoutWebView> createState() =>
      _EmbeddedCheckoutWebViewState();
}

class _EmbeddedCheckoutWebViewState extends State<_EmbeddedCheckoutWebView> {
  late final WebViewController _controller;

  void _maybeSignalHostEnd(String url) {
    if (_IyzicoTopupScreenState._isHostFlowEndUrl(url)) {
      widget.onHostFlowEnd();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _maybeSignalHostEnd,
          onNavigationRequest: (request) {
            _maybeSignalHostEnd(request.url);
            final u = Uri.tryParse(request.url);
            if (u != null &&
                u.scheme == 'io.prolance.app' &&
                u.host == 'iyzico-result') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                'iyzico',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
