import 'package:json_annotation/json_annotation.dart';
import 'activity.dart';

part 'timetable.g.dart';

/// Type of timetable
enum TimetableType {
  own, // User's own timetable
  imported, // Imported from another user
  template, // Public template
}

/// Timetable containing multiple activities
@JsonSerializable(explicitToJson: true)
class Timetable {
  final String id;
  final String name;
  final String? description;
  final String? emoji;
  final List<Activity> activities;
  final TimetableType type;
  final bool isActive; // Only 1 own timetable can be active
  final bool alertsEnabled; // User can enable/disable alerts per timetable
  final String? ownerId; // Firebase Anonymous UID (for sharing)
  final String? shareCode; // 6-digit code (if shared)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic; // For template timetables

  const Timetable({
    required this.id,
    required this.name,
    this.description,
    this.emoji,
    required this.activities,
    this.type = TimetableType.own,
    this.isActive = false,
    this.alertsEnabled = false,
    this.ownerId,
    this.shareCode,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableToJson(this);

  /// Get total duration of all activities in minutes
  int getTotalDurationMinutes() {
    return activities.fold(0, (sum, activity) => sum + activity.getDurationMinutes());
  }

  /// Get activities count
  int get activityCount => activities.length;

  /// Check if this is a user's own timetable
  bool get isOwn => type == TimetableType.own;

  /// Check if this is an imported timetable
  bool get isImported => type == TimetableType.imported;

  /// Check if this is a template
  bool get isTemplate => type == TimetableType.template;

  /// Check if timetable can be edited (only own timetables)
  bool get canEdit => isOwn;

  /// Check if timetable can be shared
  bool get canShare => isOwn;

  /// Copy with modifications
  Timetable copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    List<Activity>? activities,
    TimetableType? type,
    bool? isActive,
    bool? alertsEnabled,
    String? ownerId,
    String? shareCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return Timetable(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      activities: activities ?? this.activities,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      ownerId: ownerId ?? this.ownerId,
      shareCode: shareCode ?? this.shareCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timetable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
