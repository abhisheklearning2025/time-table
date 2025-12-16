import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/timetable.dart';
import '../../data/models/activity.dart';
import '../../core/utils/time_helper.dart';

/// Provider for real-time current activity tracking
/// Tracks current activities across all active timetables with alerts enabled
class CurrentActivityProvider with ChangeNotifier {
  Timer? _timer;

  // Map of timetable ID → current activity
  final Map<String, Activity?> _currentActivities = {};

  // Map of timetable ID → time remaining in minutes
  final Map<String, int> _timeRemaining = {};

  // Currently selected timetable for viewing
  Timetable? _selectedTimetable;

  // List of timetables being tracked
  List<Timetable> _trackedTimetables = [];

  bool _isTracking = false;

  CurrentActivityProvider();

  // Getters
  Map<String, Activity?> get currentActivities => _currentActivities;
  Map<String, int> get timeRemaining => _timeRemaining;
  Timetable? get selectedTimetable => _selectedTimetable;
  List<Timetable> get trackedTimetables => _trackedTimetables;
  bool get isTracking => _isTracking;

  /// Get current activity for selected timetable
  Activity? get selectedCurrentActivity =>
      _selectedTimetable != null ? _currentActivities[_selectedTimetable!.id] : null;

  /// Get time remaining for selected timetable
  int get selectedTimeRemaining =>
      _selectedTimetable != null ? _timeRemaining[_selectedTimetable!.id] ?? 0 : 0;

  /// Start tracking timetables
  /// Pass list of timetables with alerts enabled
  void startTracking(List<Timetable> timetables) {
    if (_isTracking) {
      debugPrint('CurrentActivityProvider: Already tracking');
      return;
    }

    _trackedTimetables = timetables;
    debugPrint('CurrentActivityProvider: Starting tracking for ${timetables.length} timetables');

    // Initial update
    _updateAllActivities();

    // Start periodic timer (update every second)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateAllActivities();
    });

    _isTracking = true;
    notifyListeners();
  }

  /// Stop tracking
  void stopTracking() {
    if (!_isTracking) return;

    debugPrint('CurrentActivityProvider: Stopping tracking');
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _currentActivities.clear();
    _timeRemaining.clear();
    notifyListeners();
  }

  /// Update tracked timetables (when timetables change)
  void updateTrackedTimetables(List<Timetable> timetables) {
    _trackedTimetables = timetables;
    _updateAllActivities();
  }

  /// Update all current activities
  void _updateAllActivities() {
    final now = DateTime.now();
    bool hasChanges = false;

    for (final timetable in _trackedTimetables) {
      // Get current activity
      final currentActivity = TimeHelper.getCurrentActivity(now, timetable.activities);

      // Check if activity changed
      if (_currentActivities[timetable.id] != currentActivity) {
        _currentActivities[timetable.id] = currentActivity;
        hasChanges = true;

        // Log activity change
        if (currentActivity != null) {
          debugPrint('CurrentActivityProvider: ${timetable.name} → ${currentActivity.title}');
        }
      }

      // Update time remaining
      if (currentActivity != null) {
        final remaining = TimeHelper.getTimeRemaining(now, currentActivity);
        if (_timeRemaining[timetable.id] != remaining) {
          _timeRemaining[timetable.id] = remaining;
          hasChanges = true;
        }
      } else {
        _timeRemaining[timetable.id] = 0;
      }
    }

    // Notify listeners if anything changed
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Set selected timetable (for viewing in detail screen)
  void setSelectedTimetable(Timetable? timetable) {
    if (_selectedTimetable?.id != timetable?.id) {
      _selectedTimetable = timetable;
      debugPrint('CurrentActivityProvider: Selected timetable ${timetable?.name}');
      notifyListeners();
    }
  }

  /// Get current activity for a specific timetable
  Activity? getCurrentActivityFor(String timetableId) {
    return _currentActivities[timetableId];
  }

  /// Get time remaining for a specific timetable
  int getTimeRemainingFor(String timetableId) {
    return _timeRemaining[timetableId] ?? 0;
  }

  /// Get progress percentage (0.0 to 1.0) for current activity
  double getProgressFor(String timetableId) {
    final activity = _currentActivities[timetableId];
    if (activity == null) return 0.0;

    final totalMinutes = activity.endMinutes - activity.startMinutes;
    if (totalMinutes <= 0) return 0.0;

    final remaining = _timeRemaining[timetableId] ?? 0;
    final elapsed = totalMinutes - remaining;

    return (elapsed / totalMinutes).clamp(0.0, 1.0);
  }

  /// Format time remaining as string (e.g., "1h 23m", "45m", "2m")
  String formatTimeRemaining(int minutes) {
    if (minutes <= 0) return '0m';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  /// Get formatted time remaining for selected timetable
  String get selectedFormattedTimeRemaining =>
      formatTimeRemaining(selectedTimeRemaining);

  /// Get formatted time remaining for a specific timetable
  String getFormattedTimeRemainingFor(String timetableId) {
    return formatTimeRemaining(getTimeRemainingFor(timetableId));
  }

  /// Check if activity is about to end (< 5 minutes remaining)
  bool isActivityEndingSoon(String timetableId) {
    final remaining = _timeRemaining[timetableId] ?? 0;
    return remaining > 0 && remaining <= 5;
  }

  /// Get all active activities (map of timetable name → activity)
  Map<String, Activity> getAllActiveActivities() {
    final activeActivities = <String, Activity>{};

    for (final timetable in _trackedTimetables) {
      final activity = _currentActivities[timetable.id];
      if (activity != null) {
        activeActivities[timetable.name] = activity;
      }
    }

    return activeActivities;
  }

  /// Get count of active activities
  int get activeActivityCount {
    return _currentActivities.values.where((a) => a != null).length;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
