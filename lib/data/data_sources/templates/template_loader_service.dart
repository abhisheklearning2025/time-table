import 'package:uuid/uuid.dart';
import '../../models/timetable.dart';
import 'default_templates.dart';

/// Service for loading and managing timetable templates
/// Handles template discovery, loading, and importing into user's timetables
class TemplateLoaderService {
  final Uuid _uuid = const Uuid();

  /// Get all available default templates
  /// Returns list of template timetables
  List<Timetable> getAllTemplates() {
    return DefaultTemplates.all;
  }

  /// Get template by name
  /// Returns null if not found
  Timetable? getTemplateByName(String name) {
    return DefaultTemplates.getByName(name);
  }

  /// Get templates filtered by category
  /// Example: getTemplatesByCategory('Student')
  List<Timetable> getTemplatesByCategory(String category) {
    return DefaultTemplates.getByCategory(category);
  }

  /// Import a template as a new own timetable
  /// Creates a copy with new IDs and type changed to 'own'
  ///
  /// Parameters:
  /// - templateId: ID of the template to import
  /// - customName: Optional custom name (defaults to template name + ' (Copy)')
  ///
  /// Returns new Timetable with:
  /// - New ID for timetable
  /// - New IDs for all activities
  /// - Type set to TimetableType.own
  /// - isActive set to false (user can activate later)
  /// - alertsEnabled set to false (user can enable later)
  /// - shareCode cleared (not shared yet)
  /// - ownerId cleared (will be set when user saves)
  ///
  /// Throws Exception if template not found
  Timetable importTemplateAsOwn(String templateId, {String? customName}) {
    // Find the template
    final template = getAllTemplates().firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw Exception('Template not found: $templateId'),
    );

    return _convertTemplateToOwn(template, customName: customName);
  }

  /// Import template by name
  /// Convenience method that finds template by name and imports it
  Timetable importTemplateByName(String templateName, {String? customName}) {
    final template = getTemplateByName(templateName);
    if (template == null) {
      throw Exception('Template not found: $templateName');
    }

    return _convertTemplateToOwn(template, customName: customName);
  }

  /// Convert a template timetable to an own timetable
  /// Internal helper method
  Timetable _convertTemplateToOwn(Timetable template, {String? customName}) {
    final now = DateTime.now();
    final newTimetableId = _uuid.v4();

    // Generate new activities with new IDs
    final newActivities = template.activities.map((activity) {
      return activity.copyWith(
        id: _uuid.v4(),
        timetableId: newTimetableId,
        customAudioPath: null, // Don't copy custom audio paths from templates
      );
    }).toList();

    // Create new timetable
    return Timetable(
      id: newTimetableId,
      name: customName ?? '${template.name} (Copy)',
      description: template.description,
      emoji: template.emoji,
      activities: newActivities,
      type: TimetableType.own, // Change to own type
      isActive: false, // User can activate later
      alertsEnabled: false, // User can enable later
      ownerId: null, // Will be set when saved to repository
      shareCode: null, // Not shared yet
      createdAt: now,
      updatedAt: now,
      isPublic: false, // Own timetables are private by default
    );
  }

  /// Get template statistics
  /// Returns count of templates by category
  Map<String, int> getTemplateStatistics() {
    final templates = getAllTemplates();
    final stats = <String, int>{};

    for (final template in templates) {
      final categoryName = template.activities.isNotEmpty
          ? template.activities.first.category.name
          : 'Uncategorized';
      stats[categoryName] = (stats[categoryName] ?? 0) + 1;
    }

    return stats;
  }

  /// Get template preview
  /// Returns summary information about a template
  TemplatePreview getTemplatePreview(String templateId) {
    final template = getAllTemplates().firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw Exception('Template not found: $templateId'),
    );

    return TemplatePreview(
      id: template.id,
      name: template.name,
      emoji: template.emoji ?? '📅',
      description: template.description ?? '',
      activityCount: template.activities.length,
      categories: _getUniqueCategories(template),
      estimatedDailyHours: _calculateTotalHours(template),
    );
  }

  /// Get all template previews
  List<TemplatePreview> getAllTemplatePreviews() {
    return getAllTemplates().map((t) => getTemplatePreview(t.id)).toList();
  }

  /// Get unique categories in a template
  List<String> _getUniqueCategories(Timetable template) {
    final categories = <String>{};
    for (final activity in template.activities) {
      categories.add(activity.category.name);
    }
    return categories.toList();
  }

  /// Calculate total hours in a template
  double _calculateTotalHours(Timetable template) {
    var totalMinutes = 0;
    for (final activity in template.activities) {
      final duration = activity.endMinutes - activity.startMinutes;
      totalMinutes += duration > 0 ? duration : (duration + 24 * 60);
    }
    return totalMinutes / 60.0;
  }
}

/// Template preview information
/// Used for displaying template cards in UI
class TemplatePreview {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int activityCount;
  final List<String> categories;
  final double estimatedDailyHours;

  TemplatePreview({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.activityCount,
    required this.categories,
    required this.estimatedDailyHours,
  });

  @override
  String toString() {
    return 'TemplatePreview($name: $activityCount activities, ${estimatedDailyHours.toStringAsFixed(1)}h/day)';
  }
}
