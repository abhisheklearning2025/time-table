import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking app analytics events
///
/// Uses Firebase Analytics to track user behavior, feature usage,
/// and app performance metrics
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get FirebaseAnalytics observer for route tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Set user properties (anonymous ID only)
  Future<void> setUserId(String? userId) async {
    if (!kIsWeb) {
      await _analytics.setUserId(id: userId);
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    if (!kIsWeb) {
      await _analytics.setUserProperty(name: name, value: value);
    }
  }

  // ========== App Lifecycle Events ==========

  /// Log app open event
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Log tutorial begin
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// Log tutorial complete
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  // ========== Timetable Events ==========

  /// Log timetable creation
  Future<void> logTimetableCreated({
    required String timetableId,
    required int activityCount,
    String? source,  // 'scratch' or 'template'
  }) async {
    await _analytics.logEvent(
      name: 'timetable_created',
      parameters: {
        'timetable_id': timetableId,
        'activity_count': activityCount,
        if (source != null) 'source': source,
      },
    );
  }

  /// Log timetable deleted
  Future<void> logTimetableDeleted({
    required String timetableId,
    required int activityCount,
  }) async {
    await _analytics.logEvent(
      name: 'timetable_deleted',
      parameters: {
        'timetable_id': timetableId,
        'activity_count': activityCount,
      },
    );
  }

  /// Log timetable edited
  Future<void> logTimetableEdited({
    required String timetableId,
    required String changeType,  // 'activity_added', 'activity_removed', 'renamed'
  }) async {
    await _analytics.logEvent(
      name: 'timetable_edited',
      parameters: {
        'timetable_id': timetableId,
        'change_type': changeType,
      },
    );
  }

  /// Log active timetable switched
  Future<void> logActiveTimetableSwitched({
    required String fromTimetableId,
    required String toTimetableId,
  }) async {
    await _analytics.logEvent(
      name: 'active_timetable_switched',
      parameters: {
        'from_timetable': fromTimetableId,
        'to_timetable': toTimetableId,
      },
    );
  }

  // ========== Sharing Events ==========

  /// Log timetable shared
  Future<void> logTimetableShared({
    required String timetableId,
    required String shareMethod,  // 'qr', 'code', 'link', 'native_share'
  }) async {
    await _analytics.logEvent(
      name: 'share',
      parameters: {
        'timetable_id': timetableId,
        'method': shareMethod,
        'content_type': 'timetable',
      },
    );
  }

  /// Log timetable imported
  Future<void> logTimetableImported({
    required String shareCode,
    required String importMethod,  // 'code', 'qr', 'link'
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: 'timetable_imported',
      parameters: {
        'share_code': shareCode,
        'import_method': importMethod,
        'success': success,
      },
    );
  }

  /// Log template browsed
  Future<void> logTemplateBrowsed({
    required String category,  // 'student', 'professional', etc.
  }) async {
    await _analytics.logEvent(
      name: 'template_browsed',
      parameters: {
        'category': category,
      },
    );
  }

  /// Log template used
  Future<void> logTemplateUsed({
    required String templateId,
    required String templateName,
  }) async {
    await _analytics.logEvent(
      name: 'template_used',
      parameters: {
        'template_id': templateId,
        'template_name': templateName,
      },
    );
  }

  // ========== Alert Events ==========

  /// Log alert enabled/disabled
  Future<void> logAlertToggled({
    required String timetableId,
    required bool enabled,
  }) async {
    await _analytics.logEvent(
      name: 'alert_toggled',
      parameters: {
        'timetable_id': timetableId,
        'enabled': enabled,
      },
    );
  }

  /// Log alert triggered
  Future<void> logAlertTriggered({
    required String timetableId,
    required String activityId,
    required String alertType,  // 'start', '5min_warning'
  }) async {
    await _analytics.logEvent(
      name: 'alert_triggered',
      parameters: {
        'timetable_id': timetableId,
        'activity_id': activityId,
        'alert_type': alertType,
      },
    );
  }

  /// Log alert snoozed
  Future<void> logAlertSnoozed({
    required String activityId,
    required int snoozeDurationMinutes,
  }) async {
    await _analytics.logEvent(
      name: 'alert_snoozed',
      parameters: {
        'activity_id': activityId,
        'snooze_duration': snoozeDurationMinutes,
      },
    );
  }

  /// Log alert dismissed
  Future<void> logAlertDismissed({
    required String activityId,
  }) async {
    await _analytics.logEvent(
      name: 'alert_dismissed',
      parameters: {
        'activity_id': activityId,
      },
    );
  }

  // ========== Settings Events ==========

  /// Log theme changed
  Future<void> logThemeChanged({
    required String themeMode,  // 'vibrant', 'pastel', 'neon'
    required bool darkMode,
  }) async {
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {
        'theme_mode': themeMode,
        'dark_mode': darkMode,
      },
    );
  }

  /// Log audio volume changed
  Future<void> logVolumeChanged({
    required double volume,
  }) async {
    await _analytics.logEvent(
      name: 'volume_changed',
      parameters: {
        'volume': volume,
      },
    );
  }

  /// Log custom audio file set
  Future<void> logCustomAudioSet({
    required String categoryId,
  }) async {
    await _analytics.logEvent(
      name: 'custom_audio_set',
      parameters: {
        'category_id': categoryId,
      },
    );
  }

  // ========== Error Events ==========

  /// Log error (in addition to Sentry)
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'has_stack_trace': true,
      },
    );
  }

  /// Log permission granted/denied
  Future<void> logPermissionResult({
    required String permissionType,  // 'notification', 'camera', 'exact_alarm'
    required bool granted,
  }) async {
    await _analytics.logEvent(
      name: 'permission_result',
      parameters: {
        'permission_type': permissionType,
        'granted': granted,
      },
    );
  }

  // ========== Engagement Events ==========

  /// Log screen view (called automatically by observer)
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    String? category,  // 'templates', 'activities'
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        if (category != null) 'category': category,
      },
    );
  }

  /// Log deep link opened
  Future<void> logDeepLinkOpened({
    required String shareCode,
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: 'deep_link_opened',
      parameters: {
        'share_code': shareCode,
        'success': success,
      },
    );
  }

  // ========== Retention Events ==========

  /// Log user engagement (daily)
  Future<void> logDailyEngagement({
    required int timetableCount,
    required int activeAlertsCount,
  }) async {
    await _analytics.logEvent(
      name: 'daily_engagement',
      parameters: {
        'timetable_count': timetableCount,
        'active_alerts_count': activeAlertsCount,
      },
    );
  }

  /// Log feature discovery
  Future<void> logFeatureDiscovered({
    required String featureName,  // 'qr_scan', 'templates', 'deep_link'
  }) async {
    await _analytics.logEvent(
      name: 'feature_discovered',
      parameters: {
        'feature_name': featureName,
      },
    );
  }
}
