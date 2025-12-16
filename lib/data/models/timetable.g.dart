// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetable _$TimetableFromJson(Map<String, dynamic> json) => Timetable(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
  activities: (json['activities'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  type:
      $enumDecodeNullable(_$TimetableTypeEnumMap, json['type']) ??
      TimetableType.own,
  isActive: json['isActive'] as bool? ?? false,
  alertsEnabled: json['alertsEnabled'] as bool? ?? false,
  ownerId: json['ownerId'] as String?,
  shareCode: json['shareCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isPublic: json['isPublic'] as bool? ?? false,
);

Map<String, dynamic> _$TimetableToJson(Timetable instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'emoji': instance.emoji,
  'activities': instance.activities.map((e) => e.toJson()).toList(),
  'type': _$TimetableTypeEnumMap[instance.type]!,
  'isActive': instance.isActive,
  'alertsEnabled': instance.alertsEnabled,
  'ownerId': instance.ownerId,
  'shareCode': instance.shareCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isPublic': instance.isPublic,
};

const _$TimetableTypeEnumMap = {
  TimetableType.own: 'own',
  TimetableType.imported: 'imported',
  TimetableType.template: 'template',
};
