import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/timetable.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

/// Activity alert dialog shown when an activity starts
/// Full-screen overlay with activity details, countdown, and snooze options
class ActivityAlertDialog extends StatefulWidget {
  final Timetable timetable;
  final Activity activity;
  final VoidCallback? onDismiss;
  final Function(int minutes)? onSnooze;

  const ActivityAlertDialog({
    super.key,
    required this.timetable,
    required this.activity,
    this.onDismiss,
    this.onSnooze,
  });

  /// Show the alert dialog
  static Future<void> show(
    BuildContext context, {
    required Timetable timetable,
    required Activity activity,
    VoidCallback? onDismiss,
    Function(int minutes)? onSnooze,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityAlertDialog(
        timetable: timetable,
        activity: activity,
        onDismiss: onDismiss,
        onSnooze: onSnooze,
      ),
    );
  }

  @override
  State<ActivityAlertDialog> createState() => _ActivityAlertDialogState();
}

class _ActivityAlertDialogState extends State<ActivityAlertDialog> {
  Timer? _autoDismissTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 30; // Auto-dismiss after 30 seconds
  int? _timeRemaining; // Activity time remaining

  @override
  void initState() {
    super.initState();
    _startAutoDismissTimer();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _startCountdownTimer() {
    // Calculate initial time remaining
    _updateTimeRemaining();

    // Update every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          }
          _updateTimeRemaining();
        });
      }
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final activityEndMinutes = widget.activity.endMinutes;

    int remaining;
    if (widget.activity.isNextDay && activityEndMinutes < currentMinutes) {
      // Activity ends tomorrow
      remaining = (1440 - currentMinutes) + activityEndMinutes;
    } else {
      remaining = activityEndMinutes - currentMinutes;
    }

    _timeRemaining = remaining > 0 ? remaining : 0;
  }

  void _dismiss() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  void _snooze(int minutes) {
    widget.onSnooze?.call(minutes);
    Navigator.of(context).pop();
  }

  String _formatTimeRemaining() {
    if (_timeRemaining == null || _timeRemaining! <= 0) {
      return 'Ending soon';
    }

    final hours = _timeRemaining! ~/ 60;
    final minutes = _timeRemaining! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    } else {
      return '${minutes}m left';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppColors.getCategoryColor(widget.activity.category.id);

    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timetable name badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.timetable.emoji != null) ...[
                          Text(
                            widget.timetable.emoji!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            widget.timetable.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activity icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.activity.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Activity title
                  Text(
                    widget.activity.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Time range
                  Text(
                    '${widget.activity.time} - ${widget.activity.endTime}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time remaining with pulsing indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing dot
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeRemaining(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar
                  if (_timeRemaining != null && _timeRemaining! > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 1 - (_timeRemaining! / widget.activity.endMinutes),
                        minHeight: 6,
                        backgroundColor: categoryColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(categoryColor),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Description (if available)
                  if (widget.activity.description.isNotEmpty) ...[
                    Text(
                      widget.activity.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Snooze options
                  Text(
                    'Snooze for',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      final snoozeOptions = [5, 10, 15];
                      return Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: snoozeOptions.map((minutes) {
                          return ActionChip(
                            label: Text(
                              '$minutes min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () => _snooze(minutes),
                            backgroundColor: categoryColor.withValues(alpha: 0.1),
                            side: BorderSide(
                              color: categoryColor.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Dismiss button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _dismiss,
                      style: FilledButton.styleFrom(
                        backgroundColor: categoryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Got it!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Auto-dismiss countdown
                  Text(
                    'Auto-dismiss in ${_remainingSeconds}s',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
