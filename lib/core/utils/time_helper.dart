import 'dart:math';
import '../../data/models/activity.dart';
import '../../data/models/timetable.dart';

/// Time calculation utilities for timetable activities
/// Handles midnight crossing and multi-timetable support
class TimeHelper {
  /// Get current activity for a single timetable
  /// Ported from React code in data.md
  ///
  /// Handles:
  /// - Activities before midnight (11:00 AM - 11:59 PM)
  /// - Activities after midnight (12:00 AM - 10:59 AM) with isNextDay flag
  /// - Activities that span midnight (11:30 PM - 12:30 AM)
  static Activity? getCurrentActivity(
    DateTime now,
    List<Activity> schedule,
  ) {
    final hours = now.hour;
    final minutes = now.minute;
    final currentMinutes = hours * 60 + minutes;

    for (final activity in schedule) {
      if (activity.isNextDay) {
        // For activities after midnight (12:30 AM - 11:00 AM)
        if (currentMinutes >= activity.startMinutes &&
            currentMinutes < activity.endMinutes) {
          return activity;
        }
      } else {
        // For activities before midnight
        if (activity.endMinutes > 24 * 60) {
          // Activity spans midnight (11:30 PM - 12:30 AM)
          if (currentMinutes >= activity.startMinutes ||
              currentMinutes < (activity.endMinutes - 24 * 60)) {
            return activity;
          }
        } else {
          if (currentMinutes >= activity.startMinutes &&
              currentMinutes < activity.endMinutes) {
            return activity;
          }
        }
      }
    }

    // Default fallback to first activity
    return schedule.isNotEmpty ? schedule.first : null;
  }

  /// Calculate time remaining in minutes for an activity
  /// Handles midnight crossing edge cases
  static int getTimeRemaining(DateTime now, Activity activity) {
    final hours = now.hour;
    final minutes = now.minute;
    final currentMinutes = hours * 60 + minutes;

    int endMinutes = activity.endMinutes;

    // Handle midnight crossing
    if (activity.endMinutes > 24 * 60) {
      endMinutes = activity.endMinutes - 24 * 60;
      if (currentMinutes > 12 * 60) {
        // Before midnight
        return (24 * 60 - currentMinutes) + endMinutes;
      }
    }

    if (activity.isNextDay && currentMinutes > activity.endMinutes) {
      return 0;
    }

    return max(0, endMinutes - currentMinutes);
  }

  /// Get current activities across all active timetables
  /// Returns a map of timetable ID to current activity
  static Map<String, Activity?> getCurrentActivities(
    DateTime now,
    List<Timetable> activeTimetables,
  ) {
    final Map<String, Activity?> currentActivities = {};

    for (final timetable in activeTimetables) {
      currentActivities[timetable.id] =
          getCurrentActivity(now, timetable.activities);
    }

    return currentActivities;
  }

  /// Get upcoming alerts for all active timetables within a time window
  /// Used for scheduling background notifications
  static List<ActivityAlert> getUpcomingAlerts(
    List<Timetable> activeTimetables,
    Duration window,
  ) {
    final now = DateTime.now();
    final windowEnd = now.add(window);
    final List<ActivityAlert> alerts = [];

    for (final timetable in activeTimetables) {
      if (!timetable.alertsEnabled) continue;

      for (final activity in timetable.activities) {
        // Calculate next occurrence of this activity
        final activityTime = _getNextOccurrence(now, activity);

        // Check if activity starts within the window
        if (activityTime.isAfter(now) && activityTime.isBefore(windowEnd)) {
          // Add main alert
          alerts.add(ActivityAlert(
            timetable: timetable,
            activity: activity,
            scheduledTime: activityTime,
            isWarning: false,
          ));

          // Add 5-minute warning if settings enabled
          final warningTime = activityTime.subtract(const Duration(minutes: 5));
          if (warningTime.isAfter(now)) {
            alerts.add(ActivityAlert(
              timetable: timetable,
              activity: activity,
              scheduledTime: warningTime,
              isWarning: true,
            ));
          }
        }
      }
    }

    // Sort by scheduled time
    alerts.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return alerts;
  }

  /// Calculate next occurrence of an activity
  static DateTime _getNextOccurrence(DateTime now, Activity activity) {
    final today = DateTime(now.year, now.month, now.day);

    // Calculate activity time for today
    final activityHour = activity.startMinutes ~/ 60;
    final activityMinute = activity.startMinutes % 60;

    DateTime activityTime;

    if (activity.isNextDay) {
      // Activity is after midnight (e.g., 2:00 AM)
      // Check if we've already passed it today
      activityTime = DateTime(
        today.year,
        today.month,
        today.day,
        activityHour,
        activityMinute,
      );

      if (activityTime.isBefore(now)) {
        // Already passed, schedule for tomorrow
        activityTime = activityTime.add(const Duration(days: 1));
      }
    } else {
      // Activity is before midnight
      activityTime = DateTime(
        today.year,
        today.month,
        today.day,
        activityHour,
        activityMinute,
      );

      if (activityTime.isBefore(now)) {
        // Already passed today, schedule for tomorrow
        activityTime = activityTime.add(const Duration(days: 1));
      }
    }

    return activityTime;
  }

  /// Format duration as human-readable string
  /// Examples: "30 min", "1 hour", "2.5 hours"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return hours == 1 ? '1 hour' : '$hours hours';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)} hours';
    }
  }

  /// Format time remaining as display string
  /// Examples: "5m", "1h 30m", "2h"
  static String formatTimeRemaining(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  /// Convert 12-hour time string to minutes since midnight
  /// Example: "11:30 AM" -> 690
  static int timeStringToMinutes(String time) {
    // Parse time like "11:30 AM"
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final isPM = parts[1].toUpperCase() == 'PM';

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return hour * 60 + minute;
  }

  /// Convert minutes since midnight to 12-hour time string
  /// Example: 690 -> "11:30 AM"
  static String minutesToTimeString(int minutes) {
    final hour24 = minutes ~/ 60;
    final minute = minutes % 60;

    final isPM = hour24 >= 12;
    int hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr ${isPM ? 'PM' : 'AM'}';
  }
}

/// Activity alert data class
/// Used for scheduling background notifications
class ActivityAlert {
  final Timetable timetable;
  final Activity activity;
  final DateTime scheduledTime;
  final bool isWarning;

  ActivityAlert({
    required this.timetable,
    required this.activity,
    required this.scheduledTime,
    required this.isWarning,
  });
}
