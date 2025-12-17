import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling runtime permissions
/// Manages notification, camera, and exact alarm permissions
class PermissionService {
  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true; // iOS/Web don't need this permission
    }

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  /// Returns true if granted, false otherwise
  Future<bool> requestNotificationPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    // Note: SCHEDULE_EXACT_ALARM doesn't require runtime permission on Android 12
    // It's automatically granted, but we check if the app can schedule exact alarms
    final status = await Permission.scheduleExactAlarm.status;
    return status.isGranted;
  }

  /// Request exact alarm permission (Android 12+)
  /// On Android 12+, this opens system settings
  Future<bool> requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted (for QR scanning)
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if all critical permissions are granted
  /// Critical: Notifications, Exact Alarms
  Future<bool> hasAllCriticalPermissions() async {
    final notification = await hasNotificationPermission();
    final exactAlarm = await hasExactAlarmPermission();
    return notification && exactAlarm;
  }

  /// Request all critical permissions
  /// Returns true if all granted, false otherwise
  Future<bool> requestAllCriticalPermissions() async {
    final notification = await requestNotificationPermission();
    final exactAlarm = await requestExactAlarmPermission();
    return notification && exactAlarm;
  }

  /// Check if permission is permanently denied
  Future<bool> isNotificationPermissionPermanentlyDenied() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    final status = await Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  /// Check if camera permission is permanently denied
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings (for permanently denied permissions)
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get battery optimization status
  /// Some manufacturers kill background tasks aggressively
  Future<bool> isBatteryOptimizationIgnored() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Request to ignore battery optimization
  /// This helps ensure background alerts work reliably
  Future<bool> requestIgnoreBatteryOptimization() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(Permission permission, PermissionStatus status) {
    if (status.isGranted) {
      return 'Permission granted';
    } else if (status.isDenied) {
      return 'Permission denied. Tap to grant.';
    } else if (status.isPermanentlyDenied) {
      return 'Permission permanently denied. Please enable in settings.';
    } else if (status.isRestricted) {
      return 'Permission restricted by system';
    } else if (status.isLimited) {
      return 'Permission granted with limitations';
    }
    return 'Permission status unknown';
  }
}
