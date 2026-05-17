import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:device_frame/device_frame.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/main_nav_controller.dart';
import 'core/repositories/message_repository.dart';
import 'core/repositories/notification_repository.dart';
import 'core/repositories/proposal_repository.dart';
import 'core/repositories/review_repository.dart';
import 'core/repositories/supabase_message_repository.dart';
import 'core/services/auth_service.dart';
import 'core/services/location_catalog_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/skills_catalog_service.dart';
import 'core/state/app_state.dart';
import 'core/state/jobs_provider.dart';

/// Shared startup (used by `main` and tests).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isWidgetTest = WidgetsBinding.instance.runtimeType
      .toString()
      .contains('AutomatedTest');
  if (!isWidgetTest) {
    await AuthService.initializeIfEnabled();
    await PushNotificationService.initializeIfEnabled();
    if (!kIsWeb && SupabaseConfig.isEnabled) {
      await _listenForOAuthDeepLinks();
    }
    // Fire-and-forget: preload catalogs in parallel so screens don't wait
    unawaited(SkillsCatalogService.instance.ensureLoaded());
    unawaited(LocationCatalogService.instance.ensureLoaded());
  }
}

/// Web presentation frame. Enable with `--dart-define=DEVICE_FRAME=true`.
/// Default off: avoids Directionality issues with [DeviceFrame]'s internal Stack on web.
const bool _deviceFrameOnWeb = bool.fromEnvironment(
  'DEVICE_FRAME',
  defaultValue: false,
);

Widget _wrapWebDeviceFrame(Widget child) {
  if (!kIsWeb || !_deviceFrameOnWeb) return child;
  return Directionality(
    textDirection: TextDirection.ltr,
    child: DeviceFrame(
      device: Devices.ios.iPhone13ProMax,
      screen: child,
    ),
  );
}

Future<void> _listenForOAuthDeepLinks() async {
  final appLinks = AppLinks();
  try {
    final initial = await appLinks.getInitialLink();
    if (initial != null) {
      await _handleOAuthCallbackUri(initial);
    }
  } catch (_) {}

  appLinks.uriLinkStream.listen((uri) async {
    await _handleOAuthCallbackUri(uri);
  });
}

Future<void> _handleOAuthCallbackUri(Uri uri) async {
  if (uri.scheme != 'io.prolance.app') return;
  if (!SupabaseConfig.isEnabled) return;
  try {
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
  } catch (_) {}
}

Future<void> main() async {
  await bootstrap();
  runApp(const ProlanceApp());
}

class ProlanceApp extends StatelessWidget {
  const ProlanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsProvider = JobsProvider();
    final appState = AppState();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MultiProvider(
      providers: [
        ChangeNotifierProvider<JobsProvider>.value(value: jobsProvider),
        ChangeNotifierProvider<AppState>.value(
          value: appState..initialize(jobsProvider: jobsProvider),
        ),
        ChangeNotifierProvider(create: (_) => MainNavController()),
        ChangeNotifierProvider<MessageRepository>(
          create: (_) {
            if (SupabaseConfig.isEnabled) {
              return SupabaseMessageRepository(
                Supabase.instance.client,
              );
            }
            return LocalMessageRepository();
          },
        ),
        ChangeNotifierProvider<ProposalRepository>(
          create: (_) {
            final repo = ProposalRepository();
            repo.initialize();
            return repo;
          },
        ),
        ChangeNotifierProvider(create: (_) => NotificationRepository()),
        ChangeNotifierProvider(create: (_) => ReviewRepository()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return _wrapWebDeviceFrame(
            RoutedMaterialApp(
              lightDynamic: lightDynamic,
              darkDynamic: darkDynamic,
            ),
          );
        },
      ),
    ),
    );
  }
}
