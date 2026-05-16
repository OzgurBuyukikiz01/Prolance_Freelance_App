import 'package:dynamic_color/dynamic_color.dart';
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
  }
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

    return MultiProvider(
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
          return RoutedMaterialApp(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
          );
        },
      ),
    );
  }
}
