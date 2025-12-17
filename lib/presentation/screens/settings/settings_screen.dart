import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';

/// Settings screen with alert, notification, and app settings
/// Allows users to control all app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer3<SettingsProvider, TimetableProvider, AuthProvider>(
        builder: (context, settingsProvider, timetableProvider, authProvider, _) {
          if (timetableProvider.isLoading) {
            return const LoadingIndicator.medium(text: 'Loading settings...');
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Alert Settings Section
              _buildSectionHeader(context, 'Alert Settings'),
              _buildAlertSettings(context, settingsProvider),
              const SizedBox(height: 24),

              // Per-Timetable Alerts Section
              _buildSectionHeader(context, 'Timetable Alerts'),
              _buildTimetableAlerts(context, timetableProvider),
              const SizedBox(height: 24),

              // Notification Settings Section
              _buildSectionHeader(context, 'Notification Settings'),
              _buildNotificationSettings(context, settingsProvider),
              const SizedBox(height: 24),

              // App Settings Section
              _buildSectionHeader(context, 'App Settings'),
              _buildAppSettings(context, settingsProvider),
              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader(context, 'Account'),
              _buildAccountSettings(context, settingsProvider, authProvider),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAlertSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Master Alert Toggle',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              provider.masterAlertEnabled
                  ? 'All alerts enabled'
                  : 'All alerts disabled',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: provider.masterAlertEnabled,
            onChanged: (value) {
              provider.toggleMasterAlerts(value);
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Alert Volume',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(provider.alertVolume * 100).toInt()}%',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                Slider(
                  value: provider.alertVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: provider.masterAlertEnabled
                      ? (value) {
                          provider.setAlertVolume(value);
                        }
                      : null,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              '5-Minute Warning',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              'Alert 5 minutes before activity starts',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: provider.fiveMinuteWarning,
            onChanged: provider.masterAlertEnabled
                ? (value) {
                    provider.toggleFiveMinuteWarning(value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              'Background Audio',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              'Play alerts when app is closed',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: provider.backgroundAudio,
            onChanged: provider.masterAlertEnabled
                ? (value) {
                    provider.toggleBackgroundAudio(value);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableAlerts(
    BuildContext context,
    TimetableProvider provider,
  ) {
    final allTimetables = [
      ...provider.ownTimetables,
      ...provider.importedTimetables,
    ];

    if (allTimetables.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No timetables yet. Create one to enable alerts! 📅',
              style: GoogleFonts.inter(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: allTimetables
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final timetable = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 1),
                  SwitchListTile(
                    title: Row(
                      children: [
                        if (timetable.emoji != null) ...[
                          Text(
                            timetable.emoji!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            timetable.name,
                            style: GoogleFonts.poppins(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      timetable.type.name == 'own'
                          ? timetable.isActive
                              ? 'Active • ${timetable.activities.length} activities'
                              : 'Own • ${timetable.activities.length} activities'
                          : 'Imported • ${timetable.activities.length} activities',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    value: timetable.alertsEnabled,
                    onChanged: (value) {
                      provider.toggleAlerts(timetable.id, value);
                    },
                  ),
                ],
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Notification Style',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              _getNotificationStyleDisplayName(provider.notificationStyle),
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: DropdownButton<String>(
              value: provider.notificationStyle,
              underline: const SizedBox(),
              items: ['sound', 'vibrate', 'silent', 'soundAndVibrate']
                  .map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(
                    _getNotificationStyleDisplayName(style),
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setNotificationStyle(value);
                }
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Snooze Duration',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              '${provider.snoozeDuration} minutes',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: DropdownButton<int>(
              value: provider.snoozeDuration,
              underline: const SizedBox(),
              items: [5, 10, 15, 20, 30].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text(
                    '$minutes min',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSnoozeDuration(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              provider.darkMode ? 'Dark theme enabled' : 'Light theme enabled',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: provider.darkMode,
            onChanged: (value) {
              provider.toggleDarkMode(value);
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Theme Style',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              _getThemeStyleDisplayName(provider.themeMode),
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: DropdownButton<String>(
              value: provider.themeMode,
              underline: const SizedBox(),
              items: ['vibrant', 'pastel', 'neon'].map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(
                    _getThemeStyleDisplayName(style),
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(
    BuildContext context,
    SettingsProvider settingsProvider,
    AuthProvider authProvider,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'User ID',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              authProvider.currentUser?.uid ?? 'Not signed in',
              style: GoogleFonts.inter(fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () async {
                final userId = authProvider.currentUser?.uid;
                if (userId != null) {
                  await Clipboard.setData(ClipboardData(text: userId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID copied! ✨'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Clear All Data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            subtitle: Text(
              'Delete all timetables and reset settings',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () => _showClearDataDialog(context, settingsProvider),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'About',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            subtitle: Text(
              'TimeTable v1.0.0',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'TimeTable',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 TimeTable',
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Organize your day the Gen-Z way 🔥',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your timetables and reset all settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Clear all data - delete all timetables individually
              final timetableProvider = context.read<TimetableProvider>();
              final allTimetables = timetableProvider.allTimetables;
              for (final timetable in allTimetables) {
                await timetableProvider.deleteTimetable(timetable.id);
              }
              await settingsProvider.resetToDefaults();

              if (context.mounted) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared! 🧹'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  String _getNotificationStyleDisplayName(String style) {
    switch (style) {
      case 'sound':
        return 'Sound';
      case 'vibrate':
        return 'Vibrate';
      case 'silent':
        return 'Silent';
      case 'soundAndVibrate':
        return 'Sound & Vibrate';
      default:
        return 'Sound';
    }
  }

  String _getThemeStyleDisplayName(String style) {
    switch (style) {
      case 'vibrant':
        return 'Vibrant 🔥';
      case 'pastel':
        return 'Pastel 🌸';
      case 'neon':
        return 'Neon ⚡';
      default:
        return 'Vibrant 🔥';
    }
  }
}
