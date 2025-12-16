import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/timetable_repository.dart';
import 'notification_service.dart';
import 'audio_service.dart';

/// Service for managing background tasks
/// Handles periodic checks, audio playback triggers, and notification rescheduling
class BackgroundService {
  final TimetableRepository _timetableRepo;
  final NotificationService _notificationService;
  final AudioService _audioService;

  Timer? _periodicTimer;
  bool _isRunning = false;

  BackgroundService({
    required TimetableRepository timetableRepo,
    required NotificationService notificationService,
    required AudioService audioService,
  })  : _timetableRepo = timetableRepo,
        _notificationService = notificationService,
        _audioService = audioService;

  /// Start background service
  /// Begins periodic checks every 15 minutes
  Future<void> start() async {
    if (_isRunning) {
      debugPrint('BackgroundService: Already running');
      return;
    }

    debugPrint('BackgroundService: Starting...');

    // Initialize notification service
    await _notificationService.initialize();

    // Do initial notification scheduling
    await _scheduleNotificationsForActiveTimetables();

    // Start periodic timer (every 15 minutes)
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _periodicCheck(),
    );

    _isRunning = true;
    debugPrint('BackgroundService: Started successfully');
  }

  /// Stop background service
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    debugPrint('BackgroundService: Stopping...');

    // Cancel periodic timer
    _periodicTimer?.cancel();
    _periodicTimer = null;

    _isRunning = false;
    debugPrint('BackgroundService: Stopped');
  }

  /// Periodic check for notifications
  /// Runs every 15 minutes to ensure notifications are up-to-date
  Future<void> _periodicCheck() async {
    try {
      debugPrint('BackgroundService: Running periodic check...');

      // Reschedule notifications for active timetables
      await _scheduleNotificationsForActiveTimetables();

      // Log pending notification count
      final pendingCount = await _notificationService.getPendingNotificationCount();
      debugPrint('BackgroundService: $pendingCount pending notifications');
    } catch (e) {
      debugPrint('BackgroundService: Error in periodic check: $e');
    }
  }

  /// Schedule notifications for all active timetables
  Future<void> _scheduleNotificationsForActiveTimetables() async {
    try {
      // Get all timetables with alerts enabled
      final activeTimetables = await _timetableRepo.getActiveTimetablesForAlerts();

      debugPrint('BackgroundService: Scheduling for ${activeTimetables.length} active timetables');

      // Schedule notifications
      await _notificationService.scheduleAllNotifications(activeTimetables);
    } catch (e) {
      debugPrint('BackgroundService: Error scheduling notifications: $e');
    }
  }

  /// Reschedule notifications (call after timetable changes)
  /// Should be called when:
  /// - User creates/updates/deletes a timetable
  /// - User enables/disables alerts for a timetable
  /// - User toggles master alerts setting
  Future<void> rescheduleNotifications() async {
    debugPrint('BackgroundService: Rescheduling notifications...');
    await _scheduleNotificationsForActiveTimetables();
  }

  /// Handle activity alert trigger
  /// Called when a notification fires and audio should play
  /// This would typically be called from a notification action or foreground service
  Future<void> handleActivityAlert(String timetableId, String activityId) async {
    try {
      debugPrint('BackgroundService: Handling alert for activity $activityId');

      // Get the timetable and activity
      final timetable = await _timetableRepo.getTimetableById(timetableId);
      if (timetable == null) {
        debugPrint('BackgroundService: Timetable not found');
        return;
      }

      final activity = timetable.activities.firstWhere(
        (a) => a.id == activityId,
        orElse: () => throw Exception('Activity not found'),
      );

      // Play audio alert
      await _audioService.playActivityAlert(activity);

      debugPrint('BackgroundService: Audio alert played for ${activity.title}');
    } catch (e) {
      debugPrint('BackgroundService: Error handling activity alert: $e');
    }
  }

  /// Handle 5-minute warning trigger
  Future<void> handleWarningAlert() async {
    try {
      debugPrint('BackgroundService: Handling 5-minute warning');
      await _audioService.playWarningAlert();
    } catch (e) {
      debugPrint('BackgroundService: Error handling warning: $e');
    }
  }

  /// Get service status
  bool get isRunning => _isRunning;

  /// Dispose and clean up resources
  Future<void> dispose() async {
    await stop();
    await _audioService.dispose();
  }
}

/// Background task handler for Android
/// This would be registered as a callback for WorkManager or AlarmManager
/// For now, it's a placeholder for future implementation
@pragma('vm:entry-point')
void backgroundTaskHandler() async {
  // This function runs in isolate, so it needs to initialize everything
  debugPrint('BackgroundService: Background task triggered');

  // TODO: Implement background task logic
  // This would:
  // 1. Initialize dependencies
  // 2. Get active timetables
  // 3. Check for upcoming activities
  // 4. Show notifications
  // 5. Play audio if needed

  // For now, notifications are handled by flutter_local_notifications
  // which schedules exact alarms without needing background tasks
}

/// Foreground service notification details
/// Used when audio is playing to keep app alive
class ForegroundServiceNotification {
  static const String channelId = 'foreground_service';
  static const String channelName = 'TimeTable Service';
  static const String channelDescription = 'Keeps the app running for activity alerts';
  static const int notificationId = 999999;

  static const String title = 'TimeTable Running';
  static const String body = 'Activity alerts are active';
}
