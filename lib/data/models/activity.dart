import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'activity.g.dart';

/// Activity representing a scheduled task in a timetable
@JsonSerializable(explicitToJson: true)
class Activity {
  final String id;
  final String time; // "11:00 AM"
  final String endTime; // "11:30 AM"
  final int startMinutes; // Minutes since midnight (660 for 11:00 AM)
  final int endMinutes; // Minutes since midnight (690 for 11:30 AM)
  final String duration; // "30 min"
  final String title;
  final String description;
  final Category category;
  final String icon; // Emoji icon
  final bool isNextDay; // True if activity crosses midnight
  final String? customAudioPath; // Local file path for custom alert sound
  final String timetableId; // Parent timetable ID

  const Activity({
    required this.id,
    required this.time,
    required this.endTime,
    required this.startMinutes,
    required this.endMinutes,
    required this.duration,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.isNextDay = false,
    this.customAudioPath,
    required this.timetableId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  /// Calculate duration in minutes
  int getDurationMinutes() {
    if (endMinutes > startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Crosses midnight
      return (24 * 60 - startMinutes) + endMinutes;
    }
  }

  /// Check if activity is currently active
  bool isActive(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;

    if (isNextDay) {
      // Activity is after midnight (e.g., 2:00 AM)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      if (endMinutes > 24 * 60) {
        // Activity spans midnight
        return currentMinutes >= startMinutes ||
            currentMinutes < (endMinutes - 24 * 60);
      } else {
        return currentMinutes >= startMinutes && currentMinutes < endMinutes;
      }
    }
  }

  /// Copy with modifications
  Activity copyWith({
    String? id,
    String? time,
    String? endTime,
    int? startMinutes,
    int? endMinutes,
    String? duration,
    String? title,
    String? description,
    Category? category,
    String? icon,
    bool? isNextDay,
    String? customAudioPath,
    String? timetableId,
  }) {
    return Activity(
      id: id ?? this.id,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isNextDay: isNextDay ?? this.isNextDay,
      customAudioPath: customAudioPath ?? this.customAudioPath,
      timetableId: timetableId ?? this.timetableId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
