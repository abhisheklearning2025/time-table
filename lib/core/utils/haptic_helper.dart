import 'package:flutter/services.dart';

/// Helper class for haptic feedback
/// Provides consistent haptic feedback across the app
class HapticHelper {
  /// Light impact - for subtle interactions
  /// Use for: Tapping chips, toggling switches, minor selections
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for standard interactions
  /// Use for: Button taps, list item selections, confirmations
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for significant interactions
  /// Use for: Deletions, important confirmations, major actions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for picker/selector changes
  /// Use for: Scrolling through pickers, changing tabs, dropdown selections
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - standard vibration
  /// Use for: Errors, warnings, notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback - combination for positive outcomes
  /// Use for: Successful saves, imports, creations
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - for negative outcomes
  /// Use for: Failed operations, validation errors
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Delete feedback - for destructive actions
  /// Use for: Deletions, removing items
  static Future<void> delete() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }
}
