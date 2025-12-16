import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/timetable.dart';
import '../common/app_card.dart';

/// Timetable card widget for list/grid display
/// Shows emoji, name, stats, active badge, and alert status
class TimetableCard extends StatelessWidget {
  final Timetable timetable;
  final VoidCallback? onTap;
  final VoidCallback? onOptions;
  final bool showActiveBadge;
  final bool showAlertStatus;

  const TimetableCard({
    super.key,
    required this.timetable,
    this.onTap,
    this.onOptions,
    this.showActiveBadge = true,
    this.showAlertStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Emoji + Options
          Row(
            children: [
              // Emoji
              Text(
                timetable.emoji ?? '📅',
                style: const TextStyle(fontSize: 32),
              ),
              const Spacer(),
              // Badges
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active badge
                  if (showActiveBadge && timetable.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Alert status
                  if (showAlertStatus)
                    Icon(
                      timetable.alertsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      size: 18,
                      color: timetable.alertsEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  // Options menu button
                  if (onOptions != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onOptions,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            timetable.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (timetable.description?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              timetable.description!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Stats
          Row(
            children: [
              _StatChip(
                icon: Icons.event_note,
                label: '${timetable.activities.length} activities',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              if (timetable.type != TimetableType.own)
                _StatChip(
                  icon: Icons.cloud_download,
                  label: _getTypeLabel(timetable.type),
                  color: theme.colorScheme.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(TimetableType type) {
    switch (type) {
      case TimetableType.imported:
        return 'Imported';
      case TimetableType.template:
        return 'Template';
      default:
        return '';
    }
  }
}

/// Small stat chip with icon and label
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact timetable card for bottom sheet or small lists
class CompactTimetableCard extends StatelessWidget {
  final Timetable timetable;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactTimetableCard({
    super.key,
    required this.timetable,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              timetable.emoji ?? '📅',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timetable.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${timetable.activities.length} activities',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (timetable.isActive)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
