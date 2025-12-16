import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/settings_repository.dart';

/// Service for audio playback of activity alerts
/// Handles background audio, volume control, and custom sounds
class AudioService {
  final SettingsRepository _settingsRepo;
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;

  AudioService({required SettingsRepository settingsRepo})
      : _settingsRepo = settingsRepo {
    _initializePlayer();
  }

  /// Initialize audio player with settings
  void _initializePlayer() {
    // Set audio context for background playback (Android)
    _player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  /// Check if audio is currently playing
  bool get isPlaying => _isPlaying;

  /// Play alert sound for an activity
  /// Uses category-specific sound or custom audio if available
  Future<void> playActivityAlert(Activity activity) async {
    // Check if alerts are enabled
    final alertsEnabled = await _settingsRepo.getMasterAlertEnabled();
    if (!alertsEnabled) {
      return;
    }

    try {
      // Stop any currently playing audio
      if (_isPlaying) {
        await stop();
      }

      // Get volume setting
      final volume = await _settingsRepo.getAlertVolume();
      await _player.setVolume(volume);

      // Determine audio source
      String audioPath;

      if (activity.customAudioPath != null && activity.customAudioPath!.isNotEmpty) {
        // Use custom audio file from device storage
        audioPath = activity.customAudioPath!;
        await _player.play(DeviceFileSource(audioPath));
      } else {
        // Use default category-based audio from assets
        audioPath = _getCategoryAudioPath(activity.category.id);
        await _player.play(AssetSource(audioPath));
      }

      _isPlaying = true;

      // Listen for completion
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      throw Exception('Failed to play audio: $e');
    }
  }

  /// Play 5-minute warning sound
  /// Softer, different sound to indicate upcoming activity
  Future<void> playWarningAlert() async {
    // Check if warnings are enabled
    final warningsEnabled = await _settingsRepo.getFiveMinuteWarning();
    if (!warningsEnabled) {
      return;
    }

    try {
      // Stop any currently playing audio
      if (_isPlaying) {
        await stop();
      }

      // Get volume setting (50% of normal for warnings)
      final volume = await _settingsRepo.getAlertVolume();
      await _player.setVolume(volume * 0.5);

      // Play warning sound
      await _player.play(AssetSource('audio/default/warning.mp3'));
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      throw Exception('Failed to play warning: $e');
    }
  }

  /// Test audio playback
  /// Used in settings screen to preview sounds
  Future<void> testAudio(String categoryId) async {
    try {
      if (_isPlaying) {
        await stop();
      }

      final volume = await _settingsRepo.getAlertVolume();
      await _player.setVolume(volume);

      final audioPath = _getCategoryAudioPath(categoryId);
      await _player.play(AssetSource(audioPath));
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      throw Exception('Failed to test audio: $e');
    }
  }

  /// Stop currently playing audio
  Future<void> stop() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
    }
  }

  /// Pause audio (for snooze functionality)
  Future<void> pause() async {
    if (_isPlaying) {
      await _player.pause();
    }
  }

  /// Resume paused audio
  Future<void> resume() async {
    if (!_isPlaying) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _settingsRepo.setAlertVolume(volume);
    await _player.setVolume(volume);
  }

  /// Get current volume
  Future<double> getVolume() async {
    return await _settingsRepo.getAlertVolume();
  }

  /// Get category-specific audio path from assets
  /// Maps category IDs to audio files
  String _getCategoryAudioPath(String categoryId) {
    // Map of category IDs to audio file paths
    const categoryAudioMap = {
      'study': 'audio/default/study.mp3',
      'work': 'audio/default/work.mp3',
      'chill': 'audio/default/chill.mp3',
      'family': 'audio/default/family.mp3',
      'fitness': 'audio/default/fitness.mp3',
      'sleep': 'audio/default/sleep.mp3',
      'food': 'audio/default/food.mp3',
      'personal': 'audio/default/personal.mp3',
      'social': 'audio/default/social.mp3',
      'creative': 'audio/default/creative.mp3',
      'learning': 'audio/default/learning.mp3',
      'health': 'audio/default/health.mp3',
    };

    // Return category-specific audio or fallback to general
    return categoryAudioMap[categoryId] ?? 'audio/default/general.mp3';
  }

  /// Check if audio assets exist
  /// Used for validation during app startup
  Future<bool> validateAudioAssets() async {
    try {
      final assets = [
        'audio/default/study.mp3',
        'audio/default/work.mp3',
        'audio/default/chill.mp3',
        'audio/default/family.mp3',
        'audio/default/fitness.mp3',
        'audio/default/sleep.mp3',
        'audio/default/food.mp3',
        'audio/default/personal.mp3',
        'audio/default/social.mp3',
        'audio/default/creative.mp3',
        'audio/default/learning.mp3',
        'audio/default/health.mp3',
        'audio/default/general.mp3',
        'audio/default/warning.mp3',
      ];

      // Try to load each asset to verify it exists
      for (final asset in assets) {
        try {
          await rootBundle.load('assets/$asset');
        } catch (e) {
          // Asset doesn't exist, return false
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose audio player
  /// Clean up resources when service is no longer needed
  Future<void> dispose() async {
    await _player.dispose();
  }
}
