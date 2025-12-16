import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'activity_form_modal.dart';

/// Activity list editor with drag-to-reorder, edit, and delete
/// Used in create/edit timetable screen
class ActivityListEditor extends StatelessWidget {
  final List<Activity> activities;
  final ValueChanged<List<Activity>> onChanged;

  const ActivityListEditor({
    super.key,
    required this.activities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return EmptyState(
        icon: Icons.event_note,
        title: 'No activities yet!',
        subtitle: 'Tap the + button below to add your first activity',
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      onReorder: (oldIndex, newIndex) {
        final newActivities = List<Activity>.from(activities);
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = newActivities.removeAt(oldIndex);
        newActivities.insert(newIndex, item);
        onChanged(newActivities);
      },
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityListItem(
          key: ValueKey(activity.id),
          activity: activity,
          index: index,
          onEdit: () => _editActivity(context, index),
          onDelete: () => _deleteActivity(context, index),
        );
      },
    );
  }

  Future<void> _editActivity(BuildContext context, int index) async {
    final activity = activities[index];
    final edited = await showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityFormModal(
        activity: activity,
        existingActivities: activities,
      ),
    );

    if (edited != null) {
      final newActivities = List<Activity>.from(activities);
      newActivities[index] = edited;
      onChanged(newActivities);
    }
  }

  void _deleteActivity(BuildContext context, int index) {
    final activity = activities[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text(
          'Are you sure you want to delete "${activity.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final newActivities = List<Activity>.from(activities);
              newActivities.removeAt(index);
              onChanged(newActivities);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Activity list item card
class _ActivityListItem extends StatelessWidget {
  final Activity activity;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityListItem({
    super.key,
    required this.activity,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppColors.getCategoryColor(activity.category.id);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.drag_handle,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${activity.time} - ${activity.endTime}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activity.duration,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}
