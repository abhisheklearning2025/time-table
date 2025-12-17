import 'package:flutter/foundation.dart';

/// Helper class for platform detection
/// Determines if app is running on web, Android, iOS, etc.
class PlatformHelper {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Check if running on desktop (not mobile, not web)
  static bool get isDesktop => !kIsWeb && !isMobile;

  /// Check if platform supports background audio alerts
  /// Web doesn't support background notifications reliably
  static bool get supportsBackgroundAlerts => isAndroid || isIOS;

  /// Check if platform supports full notification features
  static bool get supportsFullNotifications => !kIsWeb;

  /// Check if platform supports QR code scanning
  /// Web has limited camera access
  static bool get supportsQRScanning => isMobile;

  /// Check if platform supports file system access for custom audio
  static bool get supportsCustomAudio => !kIsWeb;

  /// Get platform name for display
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isDesktop) return 'Desktop';
    return 'Unknown';
  }

  /// Get user-friendly message for unsupported features
  static String getFeatureUnavailableMessage(String feature) {
    if (isWeb) {
      return '$feature is not available on web. Download the Android app for full functionality.';
    }
    return '$feature is not available on this platform.';
  }

  /// Show platform-specific guidance
  static String get downloadAppMessage {
    if (isWeb) {
      return 'For the best experience with alerts and notifications, download the Android app!';
    }
    return '';
  }
}
