import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/services/deep_link_service.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../providers/sharing_provider.dart';
import '../../providers/timetable_provider.dart';
import '../common/loading_indicator.dart';
import '../animated/confetti_overlay.dart';

/// Widget that handles incoming deep links
/// Wraps child widget and listens for share codes
class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final DeepLinkService deepLinkService;

  const DeepLinkHandler({
    super.key,
    required this.child,
    required this.deepLinkService,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  StreamSubscription<String>? _shareCodeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinkHandling();
  }

  @override
  void dispose() {
    _shareCodeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeDeepLinkHandling() async {
    // Initialize deep link service
    await widget.deepLinkService.initialize();

    // Listen to incoming share codes
    _shareCodeSubscription = widget.deepLinkService.shareCodeStream.listen(
      (shareCode) {
        debugPrint('DeepLinkHandler: Received share code: $shareCode');
        _handleShareCode(shareCode);
      },
      onError: (error) {
        debugPrint('DeepLinkHandler: Error in share code stream - $error');
      },
    );
  }

  Future<void> _handleShareCode(String shareCode) async {
    if (!mounted) return;

    final sharingProvider = context.read<SharingProvider>();
    final timetableProvider = context.read<TimetableProvider>();

    // Check if can import more
    if (!timetableProvider.canImportMore) {
      _showErrorDialog(
        'Import Limit Reached',
        'You\'ve hit the max! Delete an imported timetable first. 📊',
      );
      return;
    }

    // Show importing dialog
    _showImportingDialog(shareCode);

    try {
      // Import timetable
      final timetable = await sharingProvider.importTimetable(shareCode);

      if (!mounted) return;

      // Close importing dialog
      Navigator.pop(context);

      if (timetable != null) {
        // Success haptic feedback
        await HapticHelper.success();

        // Show confetti
        if (mounted) {
          ConfettiOverlay.show(context);
        }

        // Show success dialog
        _showSuccessDialog(timetable.name);
      } else {
        // Error haptic feedback
        await HapticHelper.error();

        // Show error
        _showErrorDialog(
          'Import Failed',
          sharingProvider.error ?? 'Could not import timetable. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close importing dialog
      Navigator.pop(context);

      // Error haptic feedback
      await HapticHelper.error();

      // Show error
      _showErrorDialog(
        'Import Error',
        'Failed to import: $e',
      );
    }
  }

  void _showImportingDialog(String shareCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator.small(),
              const SizedBox(height: 16),
              Text(
                'Importing timetable...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Code: $shareCode',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String timetableName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imported Successfully!'),
        content: Text(
          'Timetable "$timetableName" has been added to your imported schedules. ✨',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
