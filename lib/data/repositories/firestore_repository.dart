import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/timetable.dart';
import '../models/activity.dart';
import '../models/category.dart';

/// Repository for Firebase Firestore operations
/// Handles timetable sharing and template browsing
class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _timetablesCollection = 'timetables';
  static const String _templatesCollection = 'templates';

  /// Export timetable to Firestore and generate share code
  Future<String> exportTimetable(Timetable timetable, String ownerId) async {
    // Generate unique 6-digit share code
    String shareCode = await _generateUniqueShareCode();

    // Convert timetable to Firestore-friendly format
    final data = {
      'id': timetable.id,
      'name': timetable.name,
      'description': timetable.description,
      'emoji': timetable.emoji,
      'ownerId': ownerId,
      'activities': timetable.activities.map((a) => _activityToMap(a)).toList(),
      'isPublic': timetable.isPublic,
      'createdAt': FieldValue.serverTimestamp(),
      'stats': {
        'viewCount': 0,
        'importCount': 0,
      },
    };

    // Save to Firestore
    await _firestore.collection(_timetablesCollection).doc(shareCode).set(data);

    return shareCode;
  }

  /// Import timetable from Firestore using share code
  Future<Timetable?> importTimetable(String shareCode) async {
    final doc = await _firestore
        .collection(_timetablesCollection)
        .doc(shareCode.toUpperCase())
        .get();

    if (!doc.exists) return null;

    // Increment view count
    await _incrementViewCount(shareCode);

    final data = doc.data()!;
    return _timetableFromFirestore(data, shareCode);
  }

  /// Browse public templates
  Future<List<Timetable>> browseTemplates({String? category}) async {
    Query query = _firestore.collection(_templatesCollection);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.limit(20).get();

    return snapshot.docs
        .map((doc) => _timetableFromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Increment import count for a shared timetable
  Future<void> incrementImportCount(String shareCode) async {
    await _firestore.collection(_timetablesCollection).doc(shareCode).update({
      'stats.importCount': FieldValue.increment(1),
    });
  }

  /// Check if share code exists
  Future<bool> shareCodeExists(String shareCode) async {
    final doc = await _firestore
        .collection(_timetablesCollection)
        .doc(shareCode.toUpperCase())
        .get();
    return doc.exists;
  }

  // Helper methods

  /// Generate unique 6-digit share code (A-Z, 0-9)
  Future<String> _generateUniqueShareCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    for (int attempt = 0; attempt < 10; attempt++) {
      // Try up to 10 times
      final code = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );

      // Check if code already exists
      final exists = await shareCodeExists(code);
      if (!exists) return code;
    }

    // Fallback: add timestamp to ensure uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return timestamp.substring(timestamp.length - 6);
  }

  /// Increment view count
  Future<void> _incrementViewCount(String shareCode) async {
    try {
      await _firestore.collection(_timetablesCollection).doc(shareCode).update({
        'stats.viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Ignore errors (analytics, not critical)
    }
  }

  /// Convert Firestore data to Timetable model
  Timetable _timetableFromFirestore(Map<String, dynamic> data, String shareCode) {
    final activitiesData = data['activities'] as List<dynamic>;
    final activities = activitiesData
        .map((a) => _activityFromMap(a as Map<String, dynamic>))
        .toList();

    return Timetable(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      emoji: data['emoji'] as String?,
      activities: activities,
      type: TimetableType.imported,
      isActive: false,
      alertsEnabled: false,
      ownerId: data['ownerId'] as String?,
      shareCode: shareCode,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isPublic: data['isPublic'] as bool? ?? false,
    );
  }

  /// Convert Activity to Firestore-friendly map
  Map<String, dynamic> _activityToMap(Activity activity) {
    return {
      'id': activity.id,
      'time': activity.time,
      'endTime': activity.endTime,
      'startMinutes': activity.startMinutes,
      'endMinutes': activity.endMinutes,
      'duration': activity.duration,
      'title': activity.title,
      'description': activity.description,
      'categoryId': activity.category.id,
      'icon': activity.icon,
      'isNextDay': activity.isNextDay,
    };
  }

  /// Convert Firestore map to Activity model
  Activity _activityFromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      time: map['time'] as String,
      endTime: map['endTime'] as String,
      startMinutes: map['startMinutes'] as int,
      endMinutes: map['endMinutes'] as int,
      duration: map['duration'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: _getCategoryById(map['categoryId'] as String),
      icon: map['icon'] as String,
      isNextDay: map['isNextDay'] as bool? ?? false,
      customAudioPath: null, // Custom audio is device-specific
      timetableId: '', // Will be set by repository
    );
  }

  /// Get category by ID from presets
  Category _getCategoryById(String id) {
    return PresetCategories.getById(id);
  }
}
