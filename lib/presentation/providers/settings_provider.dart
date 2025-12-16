import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/services/background_service.dart';

/// Provider for managing app settings
/// Handles alert settings, audio preferences, theme, and more
class SettingsProvider with ChangeNotifier {
  final SettingsRepository _settingsRepo;
  final AudioService _audioService;
  final BackgroundService _backgroundService;

  // Alert settings
  bool _masterAlertEnabled = true;
  double _alertVolume = 0.8;
  bool _fiveMinuteWarning = true;
  bool _backgroundAudio = true;

  // Notification settings
  String _notificationStyle = 'sound'; // sound, vibrate, silent
  int _snoozeDuration = 5; // minutes

  // App settings
  String _themeMode = 'vibrant'; // vibrant, pastel, neon
  bool _darkMode = true;

  bool _isLoading = false;
  String? _error;

  SettingsProvider({
    required SettingsRepository settingsRepo,
    required AudioService audioService,
    required BackgroundService backgroundService,
  })  : _settingsRepo = settingsRepo,
        _audioService = audioService,
        _backgroundService = backgroundService {
    _init();
  }

  /// Initialize provider - load all settings
  Future<void> _init() async {
    await loadAllSettings();
  }

  // Getters
  bool get masterAlertEnabled => _masterAlertEnabled;
  double get alertVolume => _alertVolume;
  bool get fiveMinuteWarning => _fiveMinuteWarning;
  bool get backgroundAudio => _backgroundAudio;
  String get notificationStyle => _notificationStyle;
  bool get notificationSound => _notificationStyle == 'sound';
  bool get notificationVibrate => _notificationStyle == 'vibrate';
  bool get notificationSilent => _notificationStyle == 'silent';
  int get snoozeDuration => _snoozeDuration;
  String get themeMode => _themeMode;
  bool get darkMode => _darkMode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get volume as percentage (0-100)
  int get volumePercent => (_alertVolume * 100).round();

  /// Load all settings from repository
  Future<void> loadAllSettings() async {
    _setLoading(true);
    _clearError();

    try {
      // Load alert settings
      _masterAlertEnabled = await _settingsRepo.getMasterAlertEnabled();
      _alertVolume = await _settingsRepo.getAlertVolume();
      _fiveMinuteWarning = await _settingsRepo.getFiveMinuteWarning();
      _backgroundAudio = await _settingsRepo.getBackgroundAudio();

      // Load notification settings
      _notificationStyle = await _settingsRepo.getNotificationStyle();
      _snoozeDuration = await _settingsRepo.getSnoozeDuration();

      // Load app settings
      _themeMode = await _settingsRepo.getThemeMode();
      _darkMode = await _settingsRepo.getDarkMode();

      debugPrint('SettingsProvider: Loaded all settings');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
      debugPrint('SettingsProvider: Load error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle master alerts on/off
  Future<void> toggleMasterAlerts(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setMasterAlertEnabled(enabled);
      _masterAlertEnabled = enabled;

      // Reschedule notifications
      await _backgroundService.rescheduleNotifications();

      debugPrint('SettingsProvider: Master alerts ${enabled ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle master alerts: $e');
      debugPrint('SettingsProvider: Toggle master alerts error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set alert volume (0.0 to 1.0)
  Future<void> setAlertVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);

    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setAlertVolume(volume);
      await _audioService.setVolume(volume);
      _alertVolume = volume;

      debugPrint('SettingsProvider: Volume set to ${(volume * 100).toInt()}%');
      notifyListeners();
    } catch (e) {
      _setError('Failed to set volume: $e');
      debugPrint('SettingsProvider: Set volume error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set volume by percentage (0-100)
  Future<void> setVolumePercent(int percent) async {
    final volume = (percent / 100).clamp(0.0, 1.0);
    await setAlertVolume(volume);
  }

  /// Toggle 5-minute warning
  Future<void> toggleFiveMinuteWarning(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setFiveMinuteWarning(enabled);
      _fiveMinuteWarning = enabled;

      // Reschedule notifications
      await _backgroundService.rescheduleNotifications();

      debugPrint('SettingsProvider: 5-min warning ${enabled ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle warning: $e');
      debugPrint('SettingsProvider: Toggle warning error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle background audio
  Future<void> toggleBackgroundAudio(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setBackgroundAudio(enabled);
      _backgroundAudio = enabled;

      debugPrint('SettingsProvider: Background audio ${enabled ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle background audio: $e');
      debugPrint('SettingsProvider: Toggle background audio error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set notification style (sound, vibrate, silent)
  Future<void> setNotificationStyle(String style) async {
    if (!['sound', 'vibrate', 'silent'].contains(style)) {
      _setError('Invalid notification style: $style');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setNotificationStyle(style);
      _notificationStyle = style;

      debugPrint('SettingsProvider: Notification style set to $style');
      notifyListeners();
    } catch (e) {
      _setError('Failed to set notification style: $e');
      debugPrint('SettingsProvider: Set notification style error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set snooze duration in minutes
  Future<void> setSnoozeDuration(int minutes) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setSnoozeDuration(minutes);
      _snoozeDuration = minutes;

      debugPrint('SettingsProvider: Snooze duration set to $minutes minutes');
      notifyListeners();
    } catch (e) {
      _setError('Failed to set snooze duration: $e');
      debugPrint('SettingsProvider: Set snooze duration error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set theme mode (vibrant, pastel, neon)
  Future<void> setThemeMode(String mode) async {
    if (!['vibrant', 'pastel', 'neon'].contains(mode)) {
      _setError('Invalid theme mode: $mode');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setThemeMode(mode);
      _themeMode = mode;

      debugPrint('SettingsProvider: Theme mode set to $mode');
      notifyListeners();
    } catch (e) {
      _setError('Failed to set theme mode: $e');
      debugPrint('SettingsProvider: Set theme mode error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsRepo.setDarkMode(enabled);
      _darkMode = enabled;

      debugPrint('SettingsProvider: Dark mode ${enabled ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle dark mode: $e');
      debugPrint('SettingsProvider: Toggle dark mode error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Test audio playback
  /// Plays the specified category sound at current volume
  Future<void> testAudio(String categoryId) async {
    _clearError();

    try {
      await _audioService.testAudio(categoryId);
      debugPrint('SettingsProvider: Testing audio for $categoryId');
    } catch (e) {
      _setError('Failed to test audio: $e');
      debugPrint('SettingsProvider: Test audio error - $e');
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _audioService.stop();
    } catch (e) {
      debugPrint('SettingsProvider: Stop audio error - $e');
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _setLoading(true);
    _clearError();

    try {
      // Reset alert settings
      await toggleMasterAlerts(true);
      await setAlertVolume(0.8);
      await toggleFiveMinuteWarning(true);
      await toggleBackgroundAudio(true);

      // Reset notification settings
      await setNotificationStyle('sound');
      await setSnoozeDuration(5);

      // Reset theme settings
      await setThemeMode('vibrant');
      await toggleDarkMode(true);

      debugPrint('SettingsProvider: Reset all settings to defaults');
    } catch (e) {
      _setError('Failed to reset settings: $e');
      debugPrint('SettingsProvider: Reset error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // Don't dispose services (managed by GetIt)
    super.dispose();
  }
}
