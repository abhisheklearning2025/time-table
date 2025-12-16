import 'package:shared_preferences/shared_preferences.dart';

/// Repository for app settings using SharedPreferences
/// Stores user preferences like volume, theme, alert settings
class SettingsRepository {
  // Settings keys
  static const String _keyMasterAlertEnabled = 'master_alert_enabled';
  static const String _keyAlertVolume = 'alert_volume';
  static const String _keyFiveMinuteWarning = 'five_minute_warning';
  static const String _keyBackgroundAudio = 'background_audio';
  static const String _keyNotificationStyle = 'notification_style';
  static const String _keySnoozeDuration = 'snooze_duration';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyFirstLaunch = 'first_launch';

  /// Get master alert enabled state
  Future<bool> getMasterAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMasterAlertEnabled) ?? true;
  }

  /// Set master alert enabled state
  Future<void> setMasterAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMasterAlertEnabled, enabled);
  }

  /// Get alert volume (0.0 to 1.0)
  Future<double> getAlertVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyAlertVolume) ?? 0.8;
  }

  /// Set alert volume (0.0 to 1.0)
  Future<void> setAlertVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAlertVolume, volume);
  }

  /// Get 5-minute warning enabled state
  Future<bool> getFiveMinuteWarning() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFiveMinuteWarning) ?? true;
  }

  /// Set 5-minute warning enabled state
  Future<void> setFiveMinuteWarning(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFiveMinuteWarning, enabled);
  }

  /// Get background audio enabled state
  Future<bool> getBackgroundAudio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBackgroundAudio) ?? true;
  }

  /// Set background audio enabled state
  Future<void> setBackgroundAudio(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBackgroundAudio, enabled);
  }

  /// Get notification style (sound/vibrate/silent)
  Future<String> getNotificationStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNotificationStyle) ?? 'sound';
  }

  /// Set notification style
  Future<void> setNotificationStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotificationStyle, style);
  }

  /// Get snooze duration in minutes
  Future<int> getSnoozeDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySnoozeDuration) ?? 5;
  }

  /// Set snooze duration in minutes
  Future<void> setSnoozeDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySnoozeDuration, minutes);
  }

  /// Get theme mode (vibrant/pastel/neon)
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'vibrant';
  }

  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  /// Get dark mode enabled state
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? true; // Default to dark mode (Gen-Z style)
  }

  /// Set dark mode enabled state
  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, enabled);
  }

  /// Check if this is first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Mark first launch as complete
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  /// Clear all settings (for testing/reset)
  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
