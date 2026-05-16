import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/navigation/main_nav_controller.dart';
import 'core/repositories/message_repository.dart';
import 'core/repositories/proposal_repository.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/favorites_screen.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'features/home/screens/my_proposals_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProlanceApp());
}

/// Shows a blocking dialog when a user-posted job clears moderation; Home stays hidden until dismissed.
class ApprovalRevealHost extends StatefulWidget {
  const ApprovalRevealHost({super.key, required this.child});

  final Widget child;

  @override
  State<ApprovalRevealHost> createState() => _ApprovalRevealHostState();
}

class _ApprovalRevealHostState extends State<ApprovalRevealHost> {
  bool _dialogScheduled = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final head = app.pendingApprovalPopupHead;

    if (head != null && !_dialogScheduled) {
      _dialogScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final appStateNotifier = context.read<AppState>();
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final scheme = Theme.of(dialogContext).colorScheme;
            final appState = dialogContext.read<AppState>();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: scheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appState.t('Listing approved', 'İlanınız onaylandı'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  appState.t(
                    '"${head.title}" passed review and is ready on Home.',
                    '"${head.title}" incelamayı geçti; ana sayfada görüntülenebilir.',
                  ),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(appState.t('Continue', 'Devam')),
                ),
              ],
            );
          },
        );
        if (!mounted) return;
        appStateNotifier.dismissPendingApprovalPopup();
        setState(() => _dialogScheduled = false);
      });
    }

    return widget.child;
  }
}

class ProlanceApp extends StatelessWidget {
  const ProlanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..initialize()),
        ChangeNotifierProvider(create: (_) => MainNavController()),
        ChangeNotifierProvider<MessageRepository>(
          create: (_) => LocalMessageRepository(),
        ),
        ChangeNotifierProvider<ProposalRepository>(
          create: (_) {
            final repo = ProposalRepository();
            repo.initialize();
            return repo;
          },
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MaterialApp(
                title: 'Prolance',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(dynamicScheme: lightDynamic),
                darkTheme: AppTheme.darkTheme(dynamicScheme: darkDynamic),
                themeMode: appState.themeMode,
                initialRoute: '/',
                routes: {
                  '/': (context) => const SplashScreen(),
                  '/onboarding': (context) => const OnboardingScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => const RegisterScreen(),
                  '/forgot-password': (context) => const ForgotPasswordScreen(),
                  '/home': (context) => const MainNavigationScreen(),
                  '/notifications': (context) => const NotificationsScreen(),
                  '/favorites': (context) => const FavoritesScreen(),
                  '/my-proposals': (context) => const MyProposalsScreen(),
                },
                builder: (context, child) {
                  final theme = Theme.of(context);
                  final brightness = theme.brightness;
                  final overlayStyle = SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                    systemNavigationBarColor: theme.colorScheme.surface,
                    systemNavigationBarIconBrightness:
                        brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                  );

                  final themedChild = AnnotatedRegion<SystemUiOverlayStyle>(
                    value: overlayStyle,
                    child: AnimatedTheme(
                      data: theme,
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );

                  return ApprovalRevealHost(child: themedChild);
                },
              );
            },
          );
        },
      ),
    );
  }
}
