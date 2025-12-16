import '../models/timetable.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../data_sources/local/database_helper.dart';

/// Repository for timetable CRUD operations
/// Enforces business rules: max 5 own, max 5 imported, only 1 active own
class TimetableRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Business rule constants
  static const int maxOwnTimetables = 5;
  static const int maxImportedTimetables = 5;

  /// Get all own timetables
  Future<List<Timetable>> getOwnTimetables() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'timetables',
      where: 'type = ?',
      whereArgs: ['own'],
      orderBy: 'created_at DESC',
    );

    final List<Timetable> timetables = [];
    for (final map in maps) {
      final activities = await _getActivitiesForTimetable(map['id'] as String);
      timetables.add(_timetableFromMap(map, activities));
    }
    return timetables;
  }

  /// Get all imported timetables
  Future<List<Timetable>> getImportedTimetables() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'timetables',
      where: 'type = ?',
      whereArgs: ['imported'],
      orderBy: 'created_at DESC',
    );

    final List<Timetable> timetables = [];
    for (final map in maps) {
      final activities = await _getActivitiesForTimetable(map['id'] as String);
      timetables.add(_timetableFromMap(map, activities));
    }
    return timetables;
  }

  /// Get the active own timetable (only 1 allowed)
  Future<Timetable?> getActiveTimetable() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'timetables',
      where: 'type = ? AND is_active = ?',
      whereArgs: ['own', 1],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final activities = await _getActivitiesForTimetable(maps.first['id'] as String);
    return _timetableFromMap(maps.first, activities);
  }

  /// Get all timetables with alerts enabled (for notification scheduling)
  Future<List<Timetable>> getActiveTimetablesForAlerts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'timetables',
      where: 'alerts_enabled = ?',
      whereArgs: [1],
    );

    final List<Timetable> timetables = [];
    for (final map in maps) {
      final activities = await _getActivitiesForTimetable(map['id'] as String);
      timetables.add(_timetableFromMap(map, activities));
    }
    return timetables;
  }

  /// Get timetable by ID
  Future<Timetable?> getTimetableById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'timetables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final activities = await _getActivitiesForTimetable(id);
    return _timetableFromMap(maps.first, activities);
  }

  /// Create a new timetable
  Future<void> createTimetable(Timetable timetable) async {
    // Enforce limits
    if (timetable.type == TimetableType.own) {
      final ownCount = (await getOwnTimetables()).length;
      if (ownCount >= maxOwnTimetables) {
        throw Exception('Cannot create more than $maxOwnTimetables own timetables');
      }

      // If creating an active timetable, deactivate others
      if (timetable.isActive) {
        await _deactivateAllOwnTimetables();
      }
    } else if (timetable.type == TimetableType.imported) {
      final importedCount = (await getImportedTimetables()).length;
      if (importedCount >= maxImportedTimetables) {
        throw Exception('Cannot import more than $maxImportedTimetables timetables');
      }
    }

    final db = await _dbHelper.database;

    // Insert timetable
    await db.insert('timetables', _timetableToMap(timetable));

    // Insert activities
    for (final activity in timetable.activities) {
      await db.insert('activities', _activityToMap(activity));
    }
  }

  /// Update timetable
  Future<void> updateTimetable(Timetable timetable) async {
    final db = await _dbHelper.database;

    // If activating this timetable, deactivate others
    if (timetable.isActive && timetable.type == TimetableType.own) {
      await _deactivateAllOwnTimetables();
    }

    await db.update(
      'timetables',
      _timetableToMap(timetable),
      where: 'id = ?',
      whereArgs: [timetable.id],
    );

    // Update activities (delete old, insert new)
    await db.delete('activities', where: 'timetable_id = ?', whereArgs: [timetable.id]);
    for (final activity in timetable.activities) {
      await db.insert('activities', _activityToMap(activity));
    }
  }

  /// Delete timetable (and all activities via CASCADE)
  Future<void> deleteTimetable(String id) async {
    final db = await _dbHelper.database;
    await db.delete('timetables', where: 'id = ?', whereArgs: [id]);
    // Activities are deleted automatically via CASCADE
  }

  /// Set a timetable as active (deactivates others)
  Future<void> setActiveTimetable(String id) async {
    final timetable = await getTimetableById(id);
    if (timetable == null) return;

    if (timetable.type != TimetableType.own) {
      throw Exception('Only own timetables can be set as active');
    }

    await _deactivateAllOwnTimetables();

    final db = await _dbHelper.database;
    await db.update(
      'timetables',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle alerts for a timetable
  Future<void> toggleAlerts(String id, bool enabled) async {
    final db = await _dbHelper.database;
    await db.update(
      'timetables',
      {'alerts_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if user can create more own timetables
  bool canCreateMoreTimetables(int currentCount) {
    return currentCount < maxOwnTimetables;
  }

  /// Check if user can import more timetables
  bool canImportMoreTimetables(int currentCount) {
    return currentCount < maxImportedTimetables;
  }

  // Helper methods

  Future<void> _deactivateAllOwnTimetables() async {
    final db = await _dbHelper.database;
    await db.update(
      'timetables',
      {'is_active': 0},
      where: 'type = ?',
      whereArgs: ['own'],
    );
  }

  Future<List<Activity>> _getActivitiesForTimetable(String timetableId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'timetable_id = ?',
      whereArgs: [timetableId],
      orderBy: 'start_minutes ASC',
    );

    return maps.map((map) => _activityFromMap(map)).toList();
  }

  Timetable _timetableFromMap(Map<String, dynamic> map, List<Activity> activities) {
    return Timetable(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      emoji: map['emoji'] as String?,
      activities: activities,
      type: TimetableType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      isActive: (map['is_active'] as int) == 1,
      alertsEnabled: (map['alerts_enabled'] as int) == 1,
      ownerId: map['owner_id'] as String?,
      shareCode: map['share_code'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isPublic: (map['is_public'] as int) == 1,
    );
  }

  Map<String, dynamic> _timetableToMap(Timetable timetable) {
    return {
      'id': timetable.id,
      'name': timetable.name,
      'description': timetable.description,
      'emoji': timetable.emoji,
      'type': timetable.type.toString().split('.').last,
      'is_active': timetable.isActive ? 1 : 0,
      'alerts_enabled': timetable.alertsEnabled ? 1 : 0,
      'owner_id': timetable.ownerId,
      'share_code': timetable.shareCode,
      'created_at': timetable.createdAt.millisecondsSinceEpoch,
      'updated_at': timetable.updatedAt.millisecondsSinceEpoch,
      'is_public': timetable.isPublic ? 1 : 0,
    };
  }

  Activity _activityFromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      time: map['time'] as String,
      endTime: map['end_time'] as String,
      startMinutes: map['start_minutes'] as int,
      endMinutes: map['end_minutes'] as int,
      duration: map['duration'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: PresetCategories.getById(map['category_id'] as String),
      icon: map['icon'] as String,
      isNextDay: (map['is_next_day'] as int) == 1,
      customAudioPath: map['custom_audio_path'] as String?,
      timetableId: map['timetable_id'] as String,
    );
  }

  Map<String, dynamic> _activityToMap(Activity activity) {
    return {
      'id': activity.id,
      'timetable_id': activity.timetableId,
      'time': activity.time,
      'end_time': activity.endTime,
      'start_minutes': activity.startMinutes,
      'end_minutes': activity.endMinutes,
      'duration': activity.duration,
      'title': activity.title,
      'description': activity.description,
      'category_id': activity.category.id,
      'icon': activity.icon,
      'is_next_day': activity.isNextDay ? 1 : 0,
      'custom_audio_path': activity.customAudioPath,
    };
  }
}
