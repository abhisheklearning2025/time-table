import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'services/dependency_injection.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/timetable_service.dart';
import 'domain/services/sharing_service.dart';
import 'domain/services/audio_service.dart';
import 'domain/services/background_service.dart';
import 'domain/services/deep_link_service.dart';
import 'domain/services/analytics_service.dart';
import 'domain/services/performance_service.dart';
import 'data/repositories/settings_repository.dart';
import 'data/data_sources/templates/template_loader_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/timetable_provider.dart';
import 'presentation/providers/current_activity_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/sharing_provider.dart';
import 'presentation/widgets/deep_link/deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/constants/sentry_config.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry for error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      options.environment = SentryConfig.environment;
      options.release = SentryConfig.release;

      // Performance monitoring
      options.tracesSampleRate = SentryConfig.tracesSampleRate;

      // Only send errors in production
      options.beforeSend = (event, hint) {
        // Don't send debug print statements
        final message = event.message;
        if (message != null && message.formatted.contains('debugPrint')) {
          return null;
        }
        return event;
      };

      // Capture Flutter errors
      options.attachStacktrace = true;
      options.enableAutoSessionTracking = true;
    },
    appRunner: () async {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Setup dependency injection
      await setupDependencyInjection();

      // Initialize analytics and performance monitoring
      try {
        final analyticsService = getIt<AnalyticsService>();
        final performanceService = getIt<PerformanceService>();

        // Enable performance monitoring in production
        await performanceService.setPerformanceCollectionEnabled(true);

        // Log app open event
        await analyticsService.logAppOpen();

        debugPrint('Analytics and performance monitoring initialized');
      } catch (e) {
        debugPrint('Failed to initialize analytics: $e');
        Sentry.captureException(e, stackTrace: StackTrace.current);
      }

      // Auto sign-in anonymously (happens in background, no UI)
      try {
        final authService = getIt<AuthService>();
        await authService.signInAnonymously();

        // Set analytics user ID (anonymous)
        final analyticsService = getIt<AnalyticsService>();
        await analyticsService.setUserId(authService.currentUser?.uid);
      } catch (e) {
        // Log error to Sentry and console
        debugPrint('Auto sign-in failed: $e');
        Sentry.captureException(e, stackTrace: StackTrace.current);
      }

      // Start background service for notifications
      try {
        final backgroundService = getIt<BackgroundService>();
        await backgroundService.start();
        debugPrint('Background service started successfully');
      } catch (e) {
        debugPrint('Failed to start background service: $e');
        Sentry.captureException(e, stackTrace: StackTrace.current);
      }

      runApp(const TimeTableApp());
    },
  );
}

class TimeTableApp extends StatelessWidget {
  const TimeTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup MultiProvider with all app state providers
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: getIt<AuthService>(),
          ),
        ),

        // Timetable Provider
        ChangeNotifierProvider(
          create: (_) => TimetableProvider(
            timetableService: getIt<TimetableService>(),
            backgroundService: getIt<BackgroundService>(),
          ),
        ),

        // Current Activity Provider
        ChangeNotifierProvider(
          create: (_) => CurrentActivityProvider(),
        ),

        // Settings Provider
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsRepo: getIt<SettingsRepository>(),
            audioService: getIt<AudioService>(),
            backgroundService: getIt<BackgroundService>(),
          ),
        ),

        // Sharing Provider
        ChangeNotifierProvider(
          create: (_) => SharingProvider(
            sharingService: getIt<SharingService>(),
            timetableService: getIt<TimetableService>(),
            templateService: getIt<TemplateLoaderService>(),
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return DeepLinkHandler(
            deepLinkService: getIt<DeepLinkService>(),
            child: MaterialApp(
              title: 'TimeTable',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(settings.themeMode),
              darkTheme: AppTheme.getDarkTheme(settings.themeMode),
              themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
              navigatorObservers: [
                // Firebase Analytics observer for automatic screen tracking
                getIt<AnalyticsService>().getAnalyticsObserver(),
              ],
              home: const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
