import 'package:flutter/material.dart';

/// Gen-Z themed color palettes
/// Vibrant, bold, and eye-catching colors with high saturation
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // VIBRANT THEME (Default) - Bold and energetic
  // ============================================================================

  static const vibrantPrimary = Color(0xFF9C27B0); // Deep Purple
  static const vibrantSecondary = Color(0xFFE91E63); // Pink
  static const vibrantAccent = Color(0xFF00BCD4); // Cyan
  static const vibrantSuccess = Color(0xFF4CAF50); // Green
  static const vibrantWarning = Color(0xFFFF9800); // Orange
  static const vibrantError = Color(0xFFF44336); // Red
  static const vibrantInfo = Color(0xFF2196F3); // Blue

  // Gradient colors for vibrant theme
  static const vibrantGradient1 = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const vibrantGradient2 = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const vibrantGradient3 = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF44336)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // PASTEL THEME - Soft and calm
  // ============================================================================

  static const pastelPrimary = Color(0xFFBB86FC); // Light Purple
  static const pastelSecondary = Color(0xFFF48FB1); // Light Pink
  static const pastelAccent = Color(0xFF80DEEA); // Light Cyan
  static const pastelSuccess = Color(0xFF81C784); // Light Green
  static const pastelWarning = Color(0xFFFFB74D); // Light Orange
  static const pastelError = Color(0xFFE57373); // Light Red
  static const pastelInfo = Color(0xFF64B5F6); // Light Blue

  // Gradient colors for pastel theme
  static const pastelGradient1 = LinearGradient(
    colors: [Color(0xFFBB86FC), Color(0xFFF48FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pastelGradient2 = LinearGradient(
    colors: [Color(0xFF80DEEA), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pastelGradient3 = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // NEON THEME - Electric and bold
  // ============================================================================

  static const neonPrimary = Color(0xFFFF00FF); // Magenta
  static const neonSecondary = Color(0xFF00FFFF); // Cyan
  static const neonAccent = Color(0xFF00FF00); // Lime
  static const neonSuccess = Color(0xFF39FF14); // Neon Green
  static const neonWarning = Color(0xFFFFFF00); // Yellow
  static const neonError = Color(0xFFFF0080); // Hot Pink
  static const neonInfo = Color(0xFF00FFFF); // Electric Cyan

  // Gradient colors for neon theme
  static const neonGradient1 = LinearGradient(
    colors: [Color(0xFFFF00FF), Color(0xFF00FFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const neonGradient2 = LinearGradient(
    colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const neonGradient3 = LinearGradient(
    colors: [Color(0xFFFFFF00), Color(0xFFFF0080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // NEUTRAL COLORS - Used across all themes
  // ============================================================================

  // Dark mode
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkCard = Color(0xFF2C2C2C);
  static const darkBorder = Color(0xFF3A3A3A);

  // Light mode
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E0E0);

  // Text colors
  static const textPrimary = Color(0xFFFFFFFF); // White (dark mode)
  static const textSecondary = Color(0xFFB0B0B0); // Grey (dark mode)
  static const textTertiary = Color(0xFF808080); // Light Grey (dark mode)

  static const textPrimaryLight = Color(0xFF212121); // Black (light mode)
  static const textSecondaryLight = Color(0xFF757575); // Grey (light mode)
  static const textTertiaryLight = Color(0xFF9E9E9E); // Light Grey (light mode)

  // Overlay colors
  static const overlay = Color(0x80000000); // Semi-transparent black
  static const shimmer = Color(0x33FFFFFF); // Shimmer effect

  // ============================================================================
  // CATEGORY COLORS - For activity categories
  // ============================================================================

  static const categoryStudy = Color(0xFF9C27B0); // Purple
  static const categoryWork = Color(0xFF2196F3); // Blue
  static const categoryChill = Color(0xFF4CAF50); // Green
  static const categoryFamily = Color(0xFFE91E63); // Pink
  static const categoryFitness = Color(0xFFFF9800); // Orange
  static const categorySleep = Color(0xFF673AB7); // Deep Purple
  static const categoryFood = Color(0xFFFF5722); // Deep Orange
  static const categoryPersonal = Color(0xFF00BCD4); // Cyan
  static const categorySocial = Color(0xFFFF4081); // Pink Accent
  static const categoryCreative = Color(0xFFAB47BC); // Purple Accent
  static const categoryLearning = Color(0xFF7C4DFF); // Deep Purple Accent
  static const categoryHealth = Color(0xFF26A69A); // Teal

  // ============================================================================
  // STATUS COLORS - For alerts, notifications, badges
  // ============================================================================

  static const statusActive = Color(0xFF4CAF50); // Green
  static const statusInactive = Color(0xFF9E9E9E); // Grey
  static const statusWarning = Color(0xFFFF9800); // Orange
  static const statusError = Color(0xFFF44336); // Red
  static const statusInfo = Color(0xFF2196F3); // Blue

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get primary color for theme mode
  static Color getPrimaryColor(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'pastel':
        return pastelPrimary;
      case 'neon':
        return neonPrimary;
      case 'vibrant':
      default:
        return vibrantPrimary;
    }
  }

  /// Get secondary color for theme mode
  static Color getSecondaryColor(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'pastel':
        return pastelSecondary;
      case 'neon':
        return neonSecondary;
      case 'vibrant':
      default:
        return vibrantSecondary;
    }
  }

  /// Get accent color for theme mode
  static Color getAccentColor(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'pastel':
        return pastelAccent;
      case 'neon':
        return neonAccent;
      case 'vibrant':
      default:
        return vibrantAccent;
    }
  }

  /// Get gradient for theme mode
  static LinearGradient getGradient1(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'pastel':
        return pastelGradient1;
      case 'neon':
        return neonGradient1;
      case 'vibrant':
      default:
        return vibrantGradient1;
    }
  }

  /// Get category color by ID
  static Color getCategoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'study':
        return categoryStudy;
      case 'work':
        return categoryWork;
      case 'chill':
        return categoryChill;
      case 'family':
        return categoryFamily;
      case 'fitness':
        return categoryFitness;
      case 'sleep':
        return categorySleep;
      case 'food':
        return categoryFood;
      case 'personal':
        return categoryPersonal;
      case 'social':
        return categorySocial;
      case 'creative':
        return categoryCreative;
      case 'learning':
        return categoryLearning;
      case 'health':
        return categoryHealth;
      default:
        return vibrantPrimary;
    }
  }
}
