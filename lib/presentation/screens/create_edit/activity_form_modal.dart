import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/categories.dart';
import '../../widgets/common/app_button.dart';

/// Modal bottom sheet for adding/editing an activity
/// Features: Time pickers, category selector, emoji picker, validation
class ActivityFormModal extends StatefulWidget {
  final Activity? activity; // null for new, existing for edit
  final List<Activity> existingActivities; // For validation (no overlaps)

  const ActivityFormModal({
    super.key,
    this.activity,
    this.existingActivities = const [],
  });

  @override
  State<ActivityFormModal> createState() => _ActivityFormModalState();
}

class _ActivityFormModalState extends State<ActivityFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  Category _selectedCategory = AppCategories.presetCategories[0];
  String _selectedIcon = '📅';

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _loadExistingActivity();
    }
  }

  void _loadExistingActivity() {
    final activity = widget.activity!;
    _titleController.text = activity.title;
    _descriptionController.text = activity.description;

    // Convert minutes to TimeOfDay
    _startTime = TimeOfDay(
      hour: activity.startMinutes ~/ 60,
      minute: activity.startMinutes % 60,
    );
    _endTime = TimeOfDay(
      hour: activity.endMinutes ~/ 60,
      minute: activity.endMinutes % 60,
    );

    _selectedCategory = activity.category;
    _selectedIcon = activity.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      widget.activity == null ? 'Add Activity' : 'Edit Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Morning Workout',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Time selectors
                      Row(
                        children: [
                          Expanded(
                            child: _TimeSelector(
                              label: 'Start Time',
                              time: _startTime,
                              onTap: () => _selectStartTime(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TimeSelector(
                              label: 'End Time',
                              time: _endTime,
                              onTap: () => _selectEndTime(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Duration display
                      _DurationDisplay(
                        startTime: _startTime,
                        endTime: _endTime,
                      ),
                      const SizedBox(height: 16),
                      // Category selector
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CategorySelector(
                        selectedCategory: _selectedCategory,
                        onSelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Icon selector
                      Text(
                        'Icon',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _IconSelector(
                        selectedIcon: _selectedIcon,
                        onSelected: (icon) {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add details about this activity',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    text: widget.activity == null ? 'Add Activity' : 'Save Changes',
                    icon: Icons.check,
                    onPressed: _saveActivity,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        // Auto-adjust end time if it's before start time
        if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _calculateDuration() {
    final startMinutes = _timeToMinutes(_startTime);
    final endMinutes = _timeToMinutes(_endTime);

    int duration;
    if (endMinutes >= startMinutes) {
      duration = endMinutes - startMinutes;
    } else {
      // Crosses midnight
      duration = (24 * 60) - startMinutes + endMinutes;
    }

    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  bool _validateTimes() {
    final startMinutes = _timeToMinutes(_startTime);
    final endMinutes = _timeToMinutes(_endTime);

    // Check if end is before start (same day)
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
        ),
      );
      return false;
    }

    // Check for overlaps with existing activities (excluding current activity being edited)
    for (final existing in widget.existingActivities) {
      if (widget.activity != null && existing.id == widget.activity!.id) {
        continue; // Skip the activity being edited
      }

      final existingStart = existing.startMinutes;
      final existingEnd = existing.endMinutes;

      // Check overlap
      if ((startMinutes >= existingStart && startMinutes < existingEnd) ||
          (endMinutes > existingStart && endMinutes <= existingEnd) ||
          (startMinutes <= existingStart && endMinutes >= existingEnd)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time overlaps with "${existing.title}"'),
          ),
        );
        return false;
      }
    }

    return true;
  }

  void _saveActivity() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validateTimes()) {
      return;
    }

    final startMinutes = _timeToMinutes(_startTime);
    final endMinutes = _timeToMinutes(_endTime);

    final activity = Activity(
      id: widget.activity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      duration: _calculateDuration(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      icon: _selectedIcon,
      isNextDay: endMinutes <= startMinutes,
      timetableId: widget.activity?.timetableId ?? '',
    );

    Navigator.pop(context, activity);
  }
}

/// Time selector widget
class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$hour:$minute',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  period,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Duration display widget
class _DurationDisplay extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const _DurationDisplay({
    required this.startTime,
    required this.endTime,
  });

  String _calculateDuration() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    int duration;
    if (endMinutes >= startMinutes) {
      duration = endMinutes - startMinutes;
    } else {
      duration = (24 * 60) - startMinutes + endMinutes;
    }

    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Duration: ${_calculateDuration()}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category selector widget
class _CategorySelector extends StatelessWidget {
  final Category selectedCategory;
  final ValueChanged<Category> onSelected;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppCategories.presetCategories.map((category) {
        final isSelected = category.id == selectedCategory.id;
        final color = AppColors.getCategoryColor(category.id);

        return InkWell(
          onTap: () => onSelected(category),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Icon selector widget
class _IconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onSelected;

  const _IconSelector({
    required this.selectedIcon,
    required this.onSelected,
  });

  static const _commonIcons = [
    '📅', '📚', '💼', '🏋️', '🍽️', '😴',
    '☕', '🎮', '📺', '🎵', '🎨', '✍️',
    '🚗', '🏃', '🧘', '👨‍👩‍👧', '🛒', '🧹',
    '📖', '💻', '📞', '✉️', '🎯', '⚡',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _commonIcons.length,
      itemBuilder: (context, index) {
        final icon = _commonIcons[index];
        final isSelected = icon == selectedIcon;

        return InkWell(
          onTap: () => onSelected(icon),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}
