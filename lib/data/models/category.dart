import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Category for activities with Gen-Z themed names
@JsonSerializable()
class Category {
  final String id;
  final String name;
  @ColorConverter()
  final Color color;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Custom JSON converter for Color
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.toARGB32();
}

/// Preset categories with Gen-Z vibes
/// Used for quick category selection when creating activities
class PresetCategories {
  static const study = Category(
    id: 'study',
    name: 'Study Sesh',
    color: Color(0xFF9C27B0), // Purple
    description: 'Grind time for academics',
  );

  static const work = Category(
    id: 'work',
    name: 'Grind Time',
    color: Color(0xFF2196F3), // Blue
    description: 'Hustle and work',
  );

  static const chill = Category(
    id: 'chill',
    name: 'Chill Vibes',
    color: Color(0xFF4CAF50), // Green
    description: 'Relaxation and downtime',
  );

  static const family = Category(
    id: 'family',
    name: 'Fam Time',
    color: Color(0xFFE91E63), // Pink
    description: 'Quality time with family',
  );

  static const fitness = Category(
    id: 'fitness',
    name: 'Get Fit',
    color: Color(0xFFFF9800), // Orange
    description: 'Workout and health',
  );

  static const sleep = Category(
    id: 'sleep',
    name: 'Sleep Mode',
    color: Color(0xFF3F51B5), // Indigo
    description: 'Rest and recovery',
  );

  static const personal = Category(
    id: 'personal',
    name: 'Me Time',
    color: Color(0xFF00BCD4), // Cyan
    description: 'Personal care and activities',
  );

  static const food = Category(
    id: 'food',
    name: 'Food Break',
    color: Color(0xFFFF5722), // Deep Orange
    description: 'Meals and snacks',
  );

  static const social = Category(
    id: 'social',
    name: 'Squad Time',
    color: Color(0xFF8BC34A), // Light Green
    description: 'Hanging with friends',
  );

  static const creative = Category(
    id: 'creative',
    name: 'Create Mode',
    color: Color(0xFF673AB7), // Deep Purple
    description: 'Creative projects and hobbies',
  );

  static const commute = Category(
    id: 'commute',
    name: 'On The Move',
    color: Color(0xFF607D8B), // Blue Grey
    description: 'Travel and commute',
  );

  static const entertainment = Category(
    id: 'entertainment',
    name: 'Vibe Check',
    color: Color(0xFFE91E63), // Pink
    description: 'Movies, games, entertainment',
  );

  /// All preset categories
  static List<Category> get all => [
        study,
        work,
        chill,
        family,
        fitness,
        sleep,
        personal,
        food,
        social,
        creative,
        commute,
        entertainment,
      ];

  /// Get category by ID, fallback to 'personal' if not found
  static Category getById(String id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => personal,
    );
  }

  /// Get category by name (case-insensitive)
  static Category? getByName(String name) {
    try {
      return all.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
