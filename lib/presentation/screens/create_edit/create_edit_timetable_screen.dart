import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/timetable_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../../data/models/activity.dart';
import 'activity_list_editor.dart';
import 'activity_form_modal.dart';

/// Create/Edit timetable screen with multi-step flow
/// Step 1: Timetable info (name, emoji, description)
/// Step 2: Activities (add, edit, reorder, delete)
class CreateEditTimetableScreen extends StatefulWidget {
  final String? timetableId; // null for create, id for edit

  const CreateEditTimetableScreen({
    super.key,
    this.timetableId,
  });

  @override
  State<CreateEditTimetableScreen> createState() =>
      _CreateEditTimetableScreenState();
}

class _CreateEditTimetableScreenState extends State<CreateEditTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedEmoji = '📅';
  List<Activity> _activities = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    if (widget.timetableId != null) {
      setState(() {
        _isLoading = true;
      });

      final provider = context.read<TimetableProvider>();
      final timetable = provider.getTimetableById(widget.timetableId!);

      if (timetable != null) {
        _nameController.text = timetable.name;
        _descriptionController.text = timetable.description ?? '';
        _selectedEmoji = timetable.emoji ?? '📅';
        _activities = List.from(timetable.activities);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.timetableId == null ? 'New Timetable' : 'Edit Timetable',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator.medium(text: 'Loading...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Section 1: Timetable Info
                  Text(
                    'Timetable Info',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Emoji selector
                  _EmojiSelector(
                    selectedEmoji: _selectedEmoji,
                    onSelected: (emoji) {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g., My Daily Routine',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add a quick note about this schedule',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  // Section 2: Activities
                  Row(
                    children: [
                      Text(
                        'Activities',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addActivity,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Activity list
                  ActivityListEditor(
                    activities: _activities,
                    onChanged: (activities) {
                      setState(() {
                        _activities = activities;
                      });
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: _isSaving
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveTimetable,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
    );
  }

  Future<void> _addActivity() async {
    final activity = await showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityFormModal(
        existingActivities: _activities,
      ),
    );

    if (activity != null) {
      setState(() {
        _activities.add(activity);
      });
    }
  }

  Future<void> _saveTimetable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one activity'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TimetableProvider>();

    try {
      if (widget.timetableId == null) {
        // Create new timetable
        final created = await provider.createTimetable(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          emoji: _selectedEmoji,
          activities: _activities,
          setAsActive: false,
          enableAlerts: false,
        );

        if (created != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Locked in! Timetable created ✨'),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing timetable
        final timetable = provider.getTimetableById(widget.timetableId!);
        if (timetable != null) {
          final updated = timetable.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            emoji: _selectedEmoji,
            activities: _activities,
          );

          final success = await provider.updateTimetable(updated);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Locked in! Timetable updated ✨'),
              ),
            );
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Emoji selector widget
class _EmojiSelector extends StatelessWidget {
  final String selectedEmoji;
  final ValueChanged<String> onSelected;

  const _EmojiSelector({
    required this.selectedEmoji,
    required this.onSelected,
  });

  static const _commonEmojis = [
    '📅', '📚', '💼', '🏋️', '🍽️', '😴',
    '☕', '📖', '⚡', '🎯', '🎨', '🎵',
    '🏃', '🧘', '👨‍👩‍👧', '🎓', '💻', '📱',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Emoji',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonEmojis.map((emoji) {
            final isSelected = emoji == selectedEmoji;
            return InkWell(
              onTap: () => onSelected(emoji),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
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
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
