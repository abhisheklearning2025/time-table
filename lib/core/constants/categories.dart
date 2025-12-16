import 'package:flutter/material.dart';
import '../../data/models/category.dart';

/// App-wide category constants
/// Provides preset categories for activities
class AppCategories {
  // Prevent instantiation
  AppCategories._();

  /// Preset categories with Gen-Z vibes
  static final List<Category> presetCategories = [
    Category(
      id: 'study',
      name: 'Study Sesh',
      color: const Color(0xFF9C27B0), // Purple
      description: 'Learning and studying',
    ),
    Category(
      id: 'work',
      name: 'Grind Time',
      color: const Color(0xFF2196F3), // Blue
      description: 'Work and professional tasks',
    ),
    Category(
      id: 'chill',
      name: 'Chill Vibes',
      color: const Color(0xFF4CAF50), // Green
      description: 'Relaxation and leisure',
    ),
    Category(
      id: 'family',
      name: 'Fam Time',
      color: const Color(0xFFE91E63), // Pink
      description: 'Family activities',
    ),
    Category(
      id: 'fitness',
      name: 'Get Fit',
      color: const Color(0xFFFF9800), // Orange
      description: 'Exercise and fitness',
    ),
    Category(
      id: 'sleep',
      name: 'Sleep Mode',
      color: const Color(0xFF3F51B5), // Indigo
      description: 'Rest and sleep',
    ),
    Category(
      id: 'personal',
      name: 'Me Time',
      color: const Color(0xFF009688), // Teal
      description: 'Personal care and hygiene',
    ),
    Category(
      id: 'health',
      name: 'Health Check',
      color: const Color(0xFFF44336), // Red
      description: 'Health and medical',
    ),
    Category(
      id: 'creative',
      name: 'Create Mode',
      color: const Color(0xFFFF5722), // Deep Orange
      description: 'Creative activities',
    ),
    Category(
      id: 'social',
      name: 'Squad Time',
      color: const Color(0xFF03A9F4), // Light Blue
      description: 'Social activities',
    ),
    Category(
      id: 'learning',
      name: 'Brain Gains',
      color: const Color(0xFF673AB7), // Deep Purple
      description: 'Learning new skills',
    ),
    Category(
      id: 'other',
      name: 'Other Stuff',
      color: const Color(0xFF607D8B), // Blue Grey
      description: 'Other activities',
    ),
  ];

  /// Get category by ID
  static Category? getCategoryById(String id) {
    try {
      return presetCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default category (first in list)
  static Category get defaultCategory => presetCategories[0];
}
