import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/favorites_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/home/screens/client_delivery_review_screen.dart';
import '../../features/home/screens/client_post_delivery_report_screen.dart';
import '../../features/home/screens/my_proposals_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/messages/screens/video_call_screen.dart';
import '../../features/post_job/screens/post_job_screen.dart';
import '../../features/profile/screens/edit_active_job_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/wallet/screens/iyzico_topup_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'routed_screens.dart';
import '../state/app_state.dart';
import '../widgets/approval_reveal_host.dart';

/// Central [GoRouter] with auth redirect.
class AppRouter {
  AppRouter._();

  static const Set<String> _publicPaths = {
    '/',
    '/onboarding',
    '/login',
    '/register',
    '/forgot-password',
  };

  static GoRouter create(AppState appState) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: appState,
      redirect: (BuildContext context, GoRouterState state) {
        final loc = state.uri.path;
        final loggedIn = appState.isLoggedIn;

        if (!loggedIn && !_publicPaths.contains(loc)) {
          return '/login';
        }
        if (loggedIn && (loc == '/login' || loc == '/register')) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigationScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/my-proposals',
          builder: (context, state) => const MyProposalsScreen(),
        ),
        GoRoute(
          path: '/review-delivery/:proposalId',
          builder: (context, state) => ClientDeliveryReviewScreen(
            proposalId: state.pathParameters['proposalId']!,
            openDisputeOnLoad: state.uri.queryParameters['dispute'] == '1',
          ),
        ),
        GoRoute(
          path: '/report-delivery-issue/:proposalId',
          builder: (context, state) => ClientPostDeliveryReportScreen(
            proposalId: state.pathParameters['proposalId']!,
          ),
        ),
        GoRoute(
          path: '/jobs/:id',
          builder: (context, state) =>
              RoutedJobDetailScreen(jobId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/chat/:id',
          builder: (context, state) => RoutedChatScreen(
            conversationId: state.pathParameters['id']!,
            query: state.uri.queryParameters,
          ),
        ),
        GoRoute(
          path: '/video-call/:id',
          builder: (context, state) {
            final voiceOnly = state.uri.queryParameters['voice'] == '1';
            return VideoCallScreen(
              conversationId: state.pathParameters['id']!,
              voiceOnly: voiceOnly,
            );
          },
        ),
        GoRoute(
          path: '/post-job',
          builder: (context, state) => const PostJobScreen(),
        ),
        GoRoute(
          path: '/escrow/:jobId',
          builder: (context, state) =>
              RoutedEscrowScreen(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(
          path: '/review/:jobId',
          builder: (context, state) => RoutedSubmitReviewScreen(
            jobId: state.pathParameters['jobId']!,
            query: state.uri.queryParameters,
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/edit-job/:jobId',
          builder: (context, state) =>
              EditActiveJobScreen(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(
          path: '/iyzico-topup',
          builder: (context, state) => const IyzicoTopupScreen(),
        ),
        GoRoute(
          path: '/user/:userId',
          builder: (context, state) =>
              UserProfileScreen(userId: state.pathParameters['userId']!),
        ),
      ],
    );
  }
}

/// Hosts [MaterialApp.router] after [GoRouter] is created once (see [didChangeDependencies]).
class RoutedMaterialApp extends StatefulWidget {
  const RoutedMaterialApp({super.key, this.lightDynamic, this.darkDynamic});

  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;

  @override
  State<RoutedMaterialApp> createState() => _RoutedMaterialAppState();
}

class _RoutedMaterialAppState extends State<RoutedMaterialApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= AppRouter.create(context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    appState.setDynamicColorSchemes(widget.lightDynamic, widget.darkDynamic);
    final router = _router;
    if (router == null) {
      return const SizedBox.shrink();
    }

    return MaterialApp.router(
      title: 'Prolance',
      debugShowCheckedModeBanner: false,
      theme: appState.lightTheme,
      darkTheme: appState.darkTheme,
      themeMode: appState.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        final brightness = theme.brightness;
        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
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
  }
}
