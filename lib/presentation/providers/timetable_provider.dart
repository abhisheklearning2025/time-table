import 'package:flutter/foundation.dart';
import '../../data/models/timetable.dart';
import '../../data/models/activity.dart';
import '../../domain/services/timetable_service.dart';
import '../../domain/services/background_service.dart';

/// Provider for managing timetables
/// Handles CRUD operations, active timetable management, and alert toggles
class TimetableProvider with ChangeNotifier {
  final TimetableService _timetableService;
  final BackgroundService _backgroundService;

  List<Timetable> _ownTimetables = [];
  List<Timetable> _importedTimetables = [];
  Timetable? _activeTimetable;
  List<Timetable> _alertEnabledTimetables = [];

  bool _isLoading = false;
  String? _error;

  TimetableProvider({
    required TimetableService timetableService,
    required BackgroundService backgroundService,
  })  : _timetableService = timetableService,
        _backgroundService = backgroundService {
    _init();
  }

  /// Initialize provider - load all timetables
  Future<void> _init() async {
    await loadAllTimetables();
  }

  // Getters
  List<Timetable> get ownTimetables => _ownTimetables;
  List<Timetable> get importedTimetables => _importedTimetables;
  Timetable? get activeTimetable => _activeTimetable;
  List<Timetable> get alertEnabledTimetables => _alertEnabledTimetables;
  List<Timetable> get allTimetables => [..._ownTimetables, ..._importedTimetables];
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check if can create more own timetables
  bool get canCreateMore => _ownTimetables.length < TimetableService.maxOwnTimetables;

  /// Check if can import more timetables
  bool get canImportMore => _importedTimetables.length < TimetableService.maxImportedTimetables;

  /// Get counts
  int get ownCount => _ownTimetables.length;
  int get importedCount => _importedTimetables.length;
  int get totalCount => _ownTimetables.length + _importedTimetables.length;
  int get alertEnabledCount => _alertEnabledTimetables.length;
  bool get hasActiveTimetable => _activeTimetable != null;

  /// Load all timetables from database
  Future<void> loadAllTimetables() async {
    _setLoading(true);
    _clearError();

    try {
      // Load own timetables
      _ownTimetables = await _timetableService.getOwnTimetables();

      // Load imported timetables
      _importedTimetables = await _timetableService.getImportedTimetables();

      // Load active timetable
      _activeTimetable = await _timetableService.getActiveTimetable();

      // Load alert-enabled timetables
      _alertEnabledTimetables = await _timetableService.getActiveTimetablesForAlerts();

      debugPrint('TimetableProvider: Loaded ${_ownTimetables.length} own, ${_importedTimetables.length} imported');
    } catch (e) {
      _setError('Failed to load timetables: $e');
      debugPrint('TimetableProvider: Load error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new timetable
  Future<Timetable?> createTimetable({
    required String name,
    String? description,
    String? emoji,
    required List<Activity> activities,
    bool setAsActive = false,
    bool enableAlerts = false,
  }) async {
    if (!canCreateMore) {
      _setError('Cannot create more than ${TimetableService.maxOwnTimetables} timetables');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final timetable = await _timetableService.createTimetable(
        name: name,
        description: description,
        emoji: emoji,
        activities: activities,
        setAsActive: setAsActive,
        enableAlerts: enableAlerts,
      );

      // Reload timetables
      await loadAllTimetables();

      // Reschedule notifications
      await _backgroundService.rescheduleNotifications();

      debugPrint('TimetableProvider: Created timetable ${timetable.name}');
      return timetable;
    } catch (e) {
      _setError('Failed to create timetable: $e');
      debugPrint('TimetableProvider: Create error - $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a timetable
  Future<bool> updateTimetable(Timetable timetable) async {
    _setLoading(true);
    _clearError();

    try {
      await _timetableService.updateTimetable(timetable);

      // Reload timetables
      await loadAllTimetables();

      // Reschedule notifications if alerts changed
      await _backgroundService.rescheduleNotifications();

      debugPrint('TimetableProvider: Updated timetable ${timetable.name}');
      return true;
    } catch (e) {
      _setError('Failed to update timetable: $e');
      debugPrint('TimetableProvider: Update error - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a timetable
  Future<bool> deleteTimetable(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _timetableService.deleteTimetable(id);

      // Reload timetables
      await loadAllTimetables();

      // Reschedule notifications
      await _backgroundService.rescheduleNotifications();

      debugPrint('TimetableProvider: Deleted timetable $id');
      return true;
    } catch (e) {
      _setError('Failed to delete timetable: $e');
      debugPrint('TimetableProvider: Delete error - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set active timetable
  /// Only one own timetable can be active at a time
  Future<bool> setActiveTimetable(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _timetableService.setActiveTimetable(id);

      // Reload timetables
      await loadAllTimetables();

      debugPrint('TimetableProvider: Set active timetable $id');
      return true;
    } catch (e) {
      _setError('Failed to set active timetable: $e');
      debugPrint('TimetableProvider: Set active error - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle alerts for a timetable
  Future<bool> toggleAlerts(String id, bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _timetableService.toggleAlerts(id, enabled);

      // Reload timetables
      await loadAllTimetables();

      // Reschedule notifications
      await _backgroundService.rescheduleNotifications();

      debugPrint('TimetableProvider: Toggled alerts for $id to $enabled');
      return true;
    } catch (e) {
      _setError('Failed to toggle alerts: $e');
      debugPrint('TimetableProvider: Toggle alerts error - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Duplicate a timetable (imported → own, or own → own)
  Future<Timetable?> duplicateTimetable(String sourceId) async {
    if (!canCreateMore) {
      _setError('Cannot create more than ${TimetableService.maxOwnTimetables} timetables');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final duplicate = await _timetableService.duplicateTimetable(sourceId);

      // Reload timetables
      await loadAllTimetables();

      debugPrint('TimetableProvider: Duplicated timetable ${duplicate.name}');
      return duplicate;
    } catch (e) {
      _setError('Failed to duplicate timetable: $e');
      debugPrint('TimetableProvider: Duplicate error - $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get timetable by ID
  Timetable? getTimetableById(String id) {
    try {
      return allTimetables.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get statistics
  Future<TimetableStatistics> getStatistics() async {
    return await _timetableService.getStatistics();
  }

  /// Refresh timetables (pull-to-refresh)
  Future<void> refresh() async {
    await loadAllTimetables();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // Don't dispose services (managed by GetIt)
    super.dispose();
  }
}
