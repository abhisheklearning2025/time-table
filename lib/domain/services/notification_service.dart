import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../data/models/timetable.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/settings_repository.dart';
import 'audio_service.dart';

/// Service for scheduling and displaying notifications
/// Handles activity alerts and 5-minute warnings across multiple timetables
class NotificationService {
  final SettingsRepository _settingsRepo;
  final AudioService _audioService;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService({
    required SettingsRepository settingsRepo,
    required AudioService audioService,
  })  : _settingsRepo = settingsRepo,
        _audioService = audioService;

  /// Initialize notification service
  /// Must be called before any other methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for notification taps
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels (Android)
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Activity alert channel
    const activityChannel = AndroidNotificationChannel(
      'activity_alerts',
      'Activity Alerts',
      description: 'Notifications for when activities start',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Warning alert channel (5-minute warnings)
    const warningChannel = AndroidNotificationChannel(
      'warning_alerts',
      'Warning Alerts',
      description: 'Notifications 5 minutes before activities',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(activityChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(warningChannel);
  }

  /// Request notification permissions (Android 13+, iOS)
  Future<bool> requestPermissions() async {
    // Android 13+
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidImplementation?.requestNotificationsPermission();

    // iOS
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? false;
  }

  /// Schedule notifications for all active timetables
  /// Cancels existing notifications and reschedules based on current state
  Future<void> scheduleAllNotifications(List<Timetable> activeTimetables) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if alerts are enabled
    final alertsEnabled = await _settingsRepo.getMasterAlertEnabled();
    if (!alertsEnabled) {
      await cancelAllNotifications();
      return;
    }

    // Cancel all existing notifications
    await cancelAllNotifications();

    // Schedule notifications for each active timetable
    for (final timetable in activeTimetables) {
      if (timetable.alertsEnabled) {
        await _scheduleTimetableNotifications(timetable);
      }
    }
  }

  /// Schedule notifications for a specific timetable
  Future<void> _scheduleTimetableNotifications(Timetable timetable) async {
    final now = DateTime.now();
    final warningsEnabled = await _settingsRepo.getFiveMinuteWarning();

    for (var i = 0; i < timetable.activities.length; i++) {
      final activity = timetable.activities[i];

      // Calculate next occurrence of this activity
      final scheduledTime = _getNextOccurrence(activity);

      // Only schedule if in the future
      if (scheduledTime.isAfter(now)) {
        // Generate unique ID for this notification
        // Format: timetableId hash + activity index
        final notificationId = _generateNotificationId(timetable.id, i);

        // Schedule activity start notification
        await _scheduleNotification(
          id: notificationId,
          title: '${activity.icon} ${activity.title}',
          body: 'Starting now from ${timetable.emoji ?? "📅"} ${timetable.name}',
          scheduledTime: scheduledTime,
          channelId: 'activity_alerts',
          payload: '${timetable.id}|${activity.id}',
        );

        // Schedule 5-minute warning if enabled
        if (warningsEnabled) {
          final warningTime = scheduledTime.subtract(const Duration(minutes: 5));
          if (warningTime.isAfter(now)) {
            final warningId = _generateNotificationId(timetable.id, i, isWarning: true);
            await _scheduleNotification(
              id: warningId,
              title: '⏰ Upcoming: ${activity.title}',
              body: 'Starting in 5 minutes from ${timetable.name}',
              scheduledTime: warningTime,
              channelId: 'warning_alerts',
              payload: '${timetable.id}|${activity.id}|warning',
            );
          }
        }
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    String? payload,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == 'activity_alerts' ? 'Activity Alerts' : 'Warning Alerts',
        channelDescription: channelId == 'activity_alerts'
            ? 'Notifications for when activities start'
            : 'Notifications 5 minutes before activities',
        importance: channelId == 'activity_alerts' ? Importance.high : Importance.defaultImportance,
        priority: channelId == 'activity_alerts' ? Priority.high : Priority.defaultPriority,
        playSound: true,
        enableVibration: channelId == 'activity_alerts',
        enableLights: true,
        color: const Color(0xFF9C27B0), // Purple accent
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Convert to TZDateTime for scheduling
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Show immediate notification (for testing or instant alerts)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'activity_alerts',
        'Activity Alerts',
        channelDescription: 'Notifications for when activities start',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: Color(0xFF9C27B0),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel notifications for a specific timetable
  Future<void> cancelTimetableNotifications(String timetableId) async {
    // Get all pending notifications
    final pendingNotifications = await _notifications.pendingNotificationRequests();

    // Cancel notifications that belong to this timetable
    for (final notification in pendingNotifications) {
      final id = notification.id;
      // Check if this notification belongs to the timetable
      // (IDs are generated from timetable ID hash)
      if (_belongsToTimetable(id, timetableId)) {
        await _notifications.cancel(id);
      }
    }
  }

  /// Get next occurrence of an activity
  /// Handles midnight crossing and calculates next scheduled time
  DateTime _getNextOccurrence(Activity activity) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Calculate target time today
    final targetHour = activity.startMinutes ~/ 60;
    final targetMinute = activity.startMinutes % 60;

    var targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    // Handle midnight crossing
    if (activity.isNextDay) {
      // Activity is past midnight (e.g., sleep 11 PM - 7 AM)
      if (currentMinutes < activity.startMinutes) {
        // We're before the start time, but it's marked as next day
        // So it starts today at this time
        targetTime = DateTime(
          now.year,
          now.month,
          now.day,
          targetHour,
          targetMinute,
        );
      } else {
        // We're past the start time, next occurrence is tomorrow
        targetTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          targetHour,
          targetMinute,
        );
      }
    } else {
      // Normal activity (doesn't cross midnight)
      if (targetTime.isBefore(now)) {
        // Already passed today, schedule for tomorrow
        targetTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          targetHour,
          targetMinute,
        );
      }
    }

    return targetTime;
  }

  /// Generate unique notification ID from timetable ID and activity index
  int _generateNotificationId(String timetableId, int activityIndex, {bool isWarning = false}) {
    // Use hashCode of timetable ID + activity index + warning flag
    final baseHash = timetableId.hashCode;
    final offset = isWarning ? 10000 : 0;
    return (baseHash % 100000) + (activityIndex * 100) + offset;
  }

  /// Check if notification ID belongs to a timetable
  bool _belongsToTimetable(int notificationId, String timetableId) {
    final timetableHash = timetableId.hashCode % 100000;
    final notificationHash = notificationId % 100000;
    // Extract the base hash (remove activity index)
    final notificationBase = notificationHash - (notificationHash % 100);
    return notificationBase == (timetableHash - (timetableHash % 100));
  }

  /// Handle notification tap
  /// Opens app and navigates to the relevant timetable/activity
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    // Parse payload: "timetableId|activityId" or "timetableId|activityId|warning"
    final parts = payload.split('|');
    if (parts.length >= 2) {
      final timetableId = parts[0];
      final activityId = parts[1];
      final isWarning = parts.length > 2 && parts[2] == 'warning';

      // TODO: Navigate to timetable detail screen (will be implemented in Phase 6 with providers)
      // For now, just play audio if it's not a warning
      if (!isWarning) {
        // Audio will be played by BackgroundService
      }
    }
  }

  /// Get pending notification count
  Future<int> getPendingNotificationCount() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.length;
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
