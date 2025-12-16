import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../common/app_card.dart';
import '../animated/pulse_dot.dart';

/// Activity card widget for timeline display
/// Shows time, icon, title, description with expand/collapse
class ActivityCard extends StatefulWidget {
  final Activity activity;
  final bool isCurrent;
  final bool showProgress;
  final double progress;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.isCurrent = false,
    this.showProgress = false,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppColors.getCategoryColor(widget.activity.category.id);

    return AppCard(
      onTap: widget.onTap ?? _toggleExpand,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time + icon column
                Column(
                  children: [
                    // Time
                    Text(
                      widget.activity.time,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.activity.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NOW badge (if current)
                      if (widget.isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PulseDotLabel(
                            text: 'NOW',
                            dotSize: 8,
                            dotColor: theme.colorScheme.error,
                          ),
                        ),
                      // Title
                      Text(
                        widget.activity.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Duration + category
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.activity.duration,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: categoryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.activity.category.name,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Description (if expanded)
                      if (_isExpanded && widget.activity.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.activity.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Expand icon
                if (widget.activity.description.isNotEmpty)
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
          // Progress bar (if current and showing progress)
          if (widget.isCurrent && widget.showProgress)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: LinearProgressIndicator(
                value: widget.progress,
                minHeight: 4,
                backgroundColor: categoryColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleExpand() {
    if (widget.activity.description.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }
}

/// Compact activity list item for preview
class CompactActivityItem extends StatelessWidget {
  final Activity activity;

  const CompactActivityItem({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppColors.getCategoryColor(activity.category.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 60,
            child: Text(
              activity.time,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Icon
          Text(
            activity.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          // Title + duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  activity.duration,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
