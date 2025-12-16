// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String,
  time: json['time'] as String,
  endTime: json['endTime'] as String,
  startMinutes: (json['startMinutes'] as num).toInt(),
  endMinutes: (json['endMinutes'] as num).toInt(),
  duration: json['duration'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
  icon: json['icon'] as String,
  isNextDay: json['isNextDay'] as bool? ?? false,
  customAudioPath: json['customAudioPath'] as String?,
  timetableId: json['timetableId'] as String,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'time': instance.time,
  'endTime': instance.endTime,
  'startMinutes': instance.startMinutes,
  'endMinutes': instance.endMinutes,
  'duration': instance.duration,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category.toJson(),
  'icon': instance.icon,
  'isNextDay': instance.isNextDay,
  'customAudioPath': instance.customAudioPath,
  'timetableId': instance.timetableId,
};
