import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/services/permission_service.dart';
import '../../widgets/common/app_card.dart';

/// Widget for requesting critical app permissions
/// Shows user-friendly permission cards with request buttons
class PermissionRequestWidget extends StatefulWidget {
  final VoidCallback? onAllGranted;
  final VoidCallback? onSkip;
  final bool showSkipButton;

  const PermissionRequestWidget({
    super.key,
    this.onAllGranted,
    this.onSkip,
    this.showSkipButton = false,
  });

  @override
  State<PermissionRequestWidget> createState() => _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  final PermissionService _permissionService = PermissionService();

  bool _notificationGranted = false;
  bool _exactAlarmGranted = false;
  bool _batteryOptimizationIgnored = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    final notification = await _permissionService.hasNotificationPermission();
    final exactAlarm = await _permissionService.hasExactAlarmPermission();
    final battery = await _permissionService.isBatteryOptimizationIgnored();

    setState(() {
      _notificationGranted = notification;
      _exactAlarmGranted = exactAlarm;
      _batteryOptimizationIgnored = battery;
      _isChecking = false;
    });

    // Check if all granted
    if (_notificationGranted && _exactAlarmGranted) {
      widget.onAllGranted?.call();
    }
  }

  Future<void> _requestNotification() async {
    final granted = await _permissionService.requestNotificationPermission();
    setState(() => _notificationGranted = granted);

    if (!granted) {
      final isPermanentlyDenied = await _permissionService.isNotificationPermissionPermanentlyDenied();
      if (isPermanentlyDenied && mounted) {
        _showOpenSettingsDialog();
      }
    } else {
      _checkPermissions();
    }
  }

  Future<void> _requestExactAlarm() async {
    final granted = await _permissionService.requestExactAlarmPermission();
    setState(() => _exactAlarmGranted = granted);
    _checkPermissions();
  }

  Future<void> _requestBatteryOptimization() async {
    final granted = await _permissionService.requestIgnoreBatteryOptimization();
    setState(() => _batteryOptimizationIgnored = granted);
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This permission has been permanently denied. Please enable it in app settings to use alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _permissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          'Enable Alerts',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Grant these permissions to receive activity alerts',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Notification Permission
        _PermissionCard(
          icon: Icons.notifications,
          title: 'Notifications',
          description: 'Get notified when activities start',
          isGranted: _notificationGranted,
          onRequest: _requestNotification,
        ),

        const SizedBox(height: 16),

        // Exact Alarm Permission
        _PermissionCard(
          icon: Icons.alarm,
          title: 'Exact Alarms',
          description: 'Schedule precise activity alerts',
          isGranted: _exactAlarmGranted,
          onRequest: _requestExactAlarm,
        ),

        const SizedBox(height: 16),

        // Battery Optimization (Optional)
        _PermissionCard(
          icon: Icons.battery_charging_full,
          title: 'Background Alerts',
          description: 'Ensure alerts work when app is closed (optional)',
          isGranted: _batteryOptimizationIgnored,
          isOptional: true,
          onRequest: _requestBatteryOptimization,
        ),

        const SizedBox(height: 32),

        // Continue button (only show if critical permissions granted)
        if (_notificationGranted && _exactAlarmGranted)
          FilledButton(
            onPressed: widget.onAllGranted,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Skip button (if allowed)
        if (widget.showSkipButton && widget.onSkip != null)
          TextButton(
            onPressed: widget.onSkip,
            child: Text(
              'Skip for now',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
      ],
    );
  }
}

/// Individual permission card
class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final bool isOptional;
  final VoidCallback onRequest;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGranted ? Icons.check_circle : icon,
              color: isGranted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'OPTIONAL',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action button
          if (!isGranted)
            FilledButton(
              onPressed: onRequest,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Grant',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
