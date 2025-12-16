import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/dependency_injection.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/timetable_service.dart';
import 'domain/services/sharing_service.dart';
import 'domain/services/audio_service.dart';
import 'domain/services/background_service.dart';
import 'data/repositories/settings_repository.dart';
import 'data/data_sources/templates/template_loader_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/timetable_provider.dart';
import 'presentation/providers/current_activity_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/sharing_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup dependency injection
  await setupDependencyInjection();

  // Auto sign-in anonymously (happens in background, no UI)
  try {
    final authService = getIt<AuthService>();
    await authService.signInAnonymously();
  } catch (e) {
    // Log error but don't block app launch
    debugPrint('Auto sign-in failed: $e');
  }

  // Start background service for notifications
  try {
    final backgroundService = getIt<BackgroundService>();
    await backgroundService.start();
    debugPrint('Background service started successfully');
  } catch (e) {
    debugPrint('Failed to start background service: $e');
  }

  runApp(const TimeTableApp());
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
          return MaterialApp(
            title: 'TimeTable',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(settings.themeMode),
            darkTheme: AppTheme.getDarkTheme(settings.themeMode),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
