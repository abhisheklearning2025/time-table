import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/platform_helper.dart';

/// Banner shown on web to encourage downloading Android app
class WebDownloadBanner extends StatelessWidget {
  final bool showCloseButton;

  const WebDownloadBanner({
    super.key,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show on web platform
    if (!PlatformHelper.isWeb) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Web version is view-only. Download Android app for alerts & full features!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                // Could implement persistent dismissal with SharedPreferences
              },
              color: theme.colorScheme.onPrimaryContainer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Dialog shown when user tries restricted action on web
class WebRestrictionDialog extends StatelessWidget {
  final String feature;

  const WebRestrictionDialog({
    super.key,
    required this.feature,
  });

  static Future<void> show(BuildContext context, String feature) {
    return showDialog(
      context: context,
      builder: (context) => WebRestrictionDialog(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.web,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Web Limitation'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PlatformHelper.getFeatureUnavailableMessage(feature),
            style: GoogleFonts.inter(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.android,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get Full Access',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Download Android app for alerts, notifications, and more',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
