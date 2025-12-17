import '../../data/models/timetable.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/timetable_repository.dart';
import 'package:uuid/uuid.dart';

/// Service for multi-timetable management
/// Orchestrates business logic and enforces rules
class TimetableService {
  final TimetableRepository _repository;

  TimetableService({required TimetableRepository repository})
      : _repository = repository;

  // Business rule constants
  static const int maxOwnTimetables = TimetableRepository.maxOwnTimetables;
  static const int maxImportedTimetables = TimetableRepository.maxImportedTimetables;

  /// Get all own timetables
  Future<List<Timetable>> getOwnTimetables() async {
    return await _repository.getOwnTimetables();
  }

  /// Get all imported timetables
  Future<List<Timetable>> getImportedTimetables() async {
    return await _repository.getImportedTimetables();
  }

  /// Get the active own timetable (only 1 allowed)
  Future<Timetable?> getActiveTimetable() async {
    return await _repository.getActiveTimetable();
  }

  /// Get all timetables with alerts enabled
  /// These are the timetables that will trigger notifications
  /// Can be up to 6 (1 own + 5 imported)
  Future<List<Timetable>> getActiveTimetablesForAlerts() async {
    return await _repository.getActiveTimetablesForAlerts();
  }

  /// Get timetable by ID
  Future<Timetable?> getTimetableById(String id) async {
    return await _repository.getTimetableById(id);
  }

  /// Create a new timetable
  /// Enforces max 5 own timetables rule
  Future<Timetable> createTimetable({
    required String name,
    String? description,
    String? emoji,
    required List<Activity> activities,
    bool setAsActive = false,
    bool enableAlerts = false,
  }) async {
    // Check if can create more
    final ownTimetables = await getOwnTimetables();
    if (ownTimetables.length >= maxOwnTimetables) {
      throw Exception(
        'Cannot create more than $maxOwnTimetables own timetables. Delete one first.',
      );
    }

    // Create timetable
    final uuid = const Uuid();
    final now = DateTime.now();
    final timetableId = uuid.v4();

    // Update activities with the new timetable ID
    final activitiesWithTimetableId = activities.map((activity) {
      return activity.copyWith(
        timetableId: timetableId,
      );
    }).toList();

    final timetable = Timetable(
      id: timetableId,
      name: name,
      description: description,
      emoji: emoji,
      activities: activitiesWithTimetableId,
      type: TimetableType.own,
      isActive: setAsActive,
      alertsEnabled: enableAlerts,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createTimetable(timetable);
    return timetable;
  }

  /// Update timetable
  Future<void> updateTimetable(Timetable timetable) async {
    // Only own timetables can be edited
    if (timetable.type != TimetableType.own) {
      throw Exception('Only own timetables can be edited');
    }

    // Ensure all activities have the correct timetable ID
    final activitiesWithTimetableId = timetable.activities.map((activity) {
      return activity.copyWith(
        timetableId: timetable.id,
      );
    }).toList();

    final updated = timetable.copyWith(
      activities: activitiesWithTimetableId,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTimetable(updated);
  }

  /// Delete timetable
  Future<void> deleteTimetable(String id) async {
    await _repository.deleteTimetable(id);
  }

  /// Set a timetable as active
  /// Deactivates all other own timetables
  /// Only own timetables can be set as active
  Future<void> setActiveTimetable(String id) async {
    await _repository.setActiveTimetable(id);
  }

  /// Toggle alerts for a timetable
  /// Any timetable (own or imported) can have alerts enabled
  Future<void> toggleAlerts(String id, bool enabled) async {
    await _repository.toggleAlerts(id, enabled);
  }

  /// Check if user can create more own timetables
  Future<bool> canCreateMoreTimetables() async {
    final ownTimetables = await getOwnTimetables();
    return ownTimetables.length < maxOwnTimetables;
  }

  /// Check if user can import more timetables
  Future<bool> canImportMoreTimetables() async {
    final importedTimetables = await getImportedTimetables();
    return importedTimetables.length < maxImportedTimetables;
  }

  /// Get count of own timetables
  Future<int> getOwnTimetablesCount() async {
    final timetables = await getOwnTimetables();
    return timetables.length;
  }

  /// Get count of imported timetables
  Future<int> getImportedTimetablesCount() async {
    final timetables = await getImportedTimetables();
    return timetables.length;
  }

  /// Duplicate a timetable (imported → own, or own → own)
  /// Useful for making editable copy of imported timetable
  Future<Timetable> duplicateTimetable(String sourceId) async {
    final source = await getTimetableById(sourceId);
    if (source == null) {
      throw Exception('Source timetable not found');
    }

    // Check if can create more
    if (!await canCreateMoreTimetables()) {
      throw Exception(
        'Cannot create more than $maxOwnTimetables own timetables',
      );
    }

    // Create duplicate
    final uuid = const Uuid();
    final now = DateTime.now();

    // Duplicate activities with new IDs
    final newTimetableId = uuid.v4();
    final duplicatedActivities = source.activities.map((activity) {
      return activity.copyWith(
        id: uuid.v4(),
        timetableId: newTimetableId,
        customAudioPath: null, // Don't copy custom audio paths
      );
    }).toList();

    final duplicate = Timetable(
      id: newTimetableId,
      name: '${source.name} (Copy)',
      description: source.description,
      emoji: source.emoji,
      activities: duplicatedActivities,
      type: TimetableType.own, // Always make it own type
      isActive: false,
      alertsEnabled: false,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createTimetable(duplicate);
    return duplicate;
  }

  /// Get summary statistics
  Future<TimetableStatistics> getStatistics() async {
    final ownTimetables = await getOwnTimetables();
    final importedTimetables = await getImportedTimetables();
    final activeTimetable = await getActiveTimetable();
    final alertEnabledTimetables = await getActiveTimetablesForAlerts();

    return TimetableStatistics(
      ownCount: ownTimetables.length,
      importedCount: importedTimetables.length,
      totalCount: ownTimetables.length + importedTimetables.length,
      hasActiveTimetable: activeTimetable != null,
      alertEnabledCount: alertEnabledTimetables.length,
      canCreateMore: ownTimetables.length < maxOwnTimetables,
      canImportMore: importedTimetables.length < maxImportedTimetables,
    );
  }
}

/// Timetable statistics
class TimetableStatistics {
  final int ownCount;
  final int importedCount;
  final int totalCount;
  final bool hasActiveTimetable;
  final int alertEnabledCount;
  final bool canCreateMore;
  final bool canImportMore;

  TimetableStatistics({
    required this.ownCount,
    required this.importedCount,
    required this.totalCount,
    required this.hasActiveTimetable,
    required this.alertEnabledCount,
    required this.canCreateMore,
    required this.canImportMore,
  });
}
