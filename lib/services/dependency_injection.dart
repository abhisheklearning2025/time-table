import 'package:get_it/get_it.dart';

// Repositories
import '../data/repositories/timetable_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/firestore_repository.dart';

// Services
import '../domain/services/auth_service.dart';
import '../domain/services/sharing_service.dart';
import '../domain/services/timetable_service.dart';
import '../domain/services/audio_service.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/background_service.dart';

// Data Sources
import '../data/data_sources/templates/template_loader_service.dart';

// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Setup dependency injection
/// Registers all repositories and services
Future<void> setupDependencyInjection() async {
  // Phase 2: Register repositories
  getIt.registerLazySingleton<TimetableRepository>(() => TimetableRepository());
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepository());
  getIt.registerLazySingleton<FirestoreRepository>(() => FirestoreRepository());

  // Phase 3: Register services
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  getIt.registerLazySingleton<TimetableService>(
    () => TimetableService(
      repository: getIt<TimetableRepository>(),
    ),
  );

  getIt.registerLazySingleton<SharingService>(
    () => SharingService(
      firestoreRepo: getIt<FirestoreRepository>(),
      timetableRepo: getIt<TimetableRepository>(),
      authService: getIt<AuthService>(),
    ),
  );

  // Phase 4: Register template service
  getIt.registerLazySingleton<TemplateLoaderService>(() => TemplateLoaderService());

  // Phase 5: Register audio, notification, and background services
  getIt.registerLazySingleton<AudioService>(
    () => AudioService(
      settingsRepo: getIt<SettingsRepository>(),
    ),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      settingsRepo: getIt<SettingsRepository>(),
      audioService: getIt<AudioService>(),
    ),
  );

  getIt.registerLazySingleton<BackgroundService>(
    () => BackgroundService(
      timetableRepo: getIt<TimetableRepository>(),
      notificationService: getIt<NotificationService>(),
      audioService: getIt<AudioService>(),
    ),
  );
}
