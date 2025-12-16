import 'package:flutter/foundation.dart';
import '../../data/models/timetable.dart';
import '../../domain/services/sharing_service.dart';
import '../../domain/services/timetable_service.dart';
import '../../data/data_sources/templates/template_loader_service.dart';

/// Provider for managing timetable sharing and templates
/// Handles export, import, QR codes, links, and template browsing
class SharingProvider with ChangeNotifier {
  final SharingService _sharingService;
  final TimetableService _timetableService;
  final TemplateLoaderService _templateService;

  List<Timetable> _templates = [];
  String? _lastShareCode;
  String? _lastShareLink;

  bool _isLoading = false;
  bool _isExporting = false;
  bool _isImporting = false;
  String? _error;

  SharingProvider({
    required SharingService sharingService,
    required TimetableService timetableService,
    required TemplateLoaderService templateService,
  })  : _sharingService = sharingService,
        _timetableService = timetableService,
        _templateService = templateService {
    _init();
  }

  /// Initialize provider - load templates
  Future<void> _init() async {
    await loadTemplates();
  }

  // Getters
  List<Timetable> get templates => _templates;
  String? get lastShareCode => _lastShareCode;
  String? get lastShareLink => _lastShareLink;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  bool get isImporting => _isImporting;
  String? get error => _error;

  /// Load all templates
  Future<void> loadTemplates() async {
    _setLoading(true);
    _clearError();

    try {
      _templates = _templateService.getAllTemplates();
      debugPrint('SharingProvider: Loaded ${_templates.length} templates');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load templates: $e');
      debugPrint('SharingProvider: Load templates error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export timetable and get share code
  Future<String?> exportTimetable(String timetableId) async {
    _setExporting(true);
    _clearError();

    try {
      final shareCode = await _sharingService.exportTimetable(timetableId);
      _lastShareCode = shareCode;
      _lastShareLink = _sharingService.generateShareLink(shareCode);

      debugPrint('SharingProvider: Exported timetable with code $shareCode');
      notifyListeners();
      return shareCode;
    } catch (e) {
      _setError('Failed to export timetable: $e');
      debugPrint('SharingProvider: Export error - $e');
      return null;
    } finally {
      _setExporting(false);
    }
  }

  /// Import timetable by share code
  Future<Timetable?> importTimetable(String shareCode) async {
    _setImporting(true);
    _clearError();

    try {
      // Validate share code format
      if (!_sharingService.isValidShareCode(shareCode)) {
        _setError('Invalid share code format');
        _setImporting(false);
        return null;
      }

      // Check if can import more
      if (!await _timetableService.canImportMoreTimetables()) {
        _setError('Cannot import more than ${TimetableService.maxImportedTimetables} timetables');
        _setImporting(false);
        return null;
      }

      // Import timetable
      final timetable = await _sharingService.importTimetable(shareCode);

      debugPrint('SharingProvider: Imported timetable ${timetable.name}');
      notifyListeners();
      return timetable;
    } catch (e) {
      _setError('Failed to import timetable: $e');
      debugPrint('SharingProvider: Import error - $e');
      return null;
    } finally {
      _setImporting(false);
    }
  }

  /// Import timetable from share link
  Future<Timetable?> importFromLink(String link) async {
    _setImporting(true);
    _clearError();

    try {
      // Parse share code from link
      final shareCode = _sharingService.parseShareCodeFromLink(link);
      if (shareCode == null) {
        _setError('Invalid share link');
        _setImporting(false);
        return null;
      }

      // Import using parsed code
      _setImporting(false); // Reset before calling importTimetable
      return await importTimetable(shareCode);
    } catch (e) {
      _setError('Failed to import from link: $e');
      debugPrint('SharingProvider: Import from link error - $e');
      _setImporting(false);
      return null;
    }
  }

  /// Import template as own timetable
  Future<Timetable?> importTemplate(String templateId, {String? customName}) async {
    _setImporting(true);
    _clearError();

    try {
      // Check if can create more
      if (!await _timetableService.canCreateMoreTimetables()) {
        _setError('Cannot create more than ${TimetableService.maxOwnTimetables} timetables');
        _setImporting(false);
        return null;
      }

      // Import template (creates own timetable with new IDs)
      final imported = _templateService.importTemplateAsOwn(
        templateId,
        customName: customName,
      );

      // Save to database via TimetableService
      final created = await _timetableService.createTimetable(
        name: imported.name,
        description: imported.description,
        emoji: imported.emoji,
        activities: imported.activities,
        setAsActive: false,
        enableAlerts: false,
      );

      debugPrint('SharingProvider: Imported template as ${created.name}');
      notifyListeners();
      return created;
    } catch (e) {
      _setError('Failed to import template: $e');
      debugPrint('SharingProvider: Import template error - $e');
      return null;
    } finally {
      _setImporting(false);
    }
  }

  /// Generate share link for a share code
  String generateShareLink(String shareCode) {
    final link = _sharingService.generateShareLink(shareCode);
    _lastShareLink = link;
    notifyListeners();
    return link;
  }

  /// Generate QR code data for a share code
  String generateQRData(String shareCode) {
    return _sharingService.generateQRData(shareCode);
  }

  /// Parse share code from a link
  String? parseShareCodeFromLink(String link) {
    return _sharingService.parseShareCodeFromLink(link);
  }

  /// Validate share code format
  bool isValidShareCode(String code) {
    return _sharingService.isValidShareCode(code);
  }

  /// Browse templates by category
  List<Timetable> getTemplatesByCategory(String category) {
    return _templateService.getTemplatesByCategory(category);
  }

  /// Get template preview
  TemplatePreview? getTemplatePreview(String templateId) {
    try {
      return _templateService.getTemplatePreview(templateId);
    } catch (e) {
      debugPrint('SharingProvider: Get template preview error - $e');
      return null;
    }
  }

  /// Get all template previews
  List<TemplatePreview> getAllTemplatePreviews() {
    return _templateService.getAllTemplatePreviews();
  }

  /// Clear last share data
  void clearLastShareData() {
    _lastShareCode = null;
    _lastShareLink = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set exporting state
  void _setExporting(bool exporting) {
    _isExporting = exporting;
    notifyListeners();
  }

  /// Set importing state
  void _setImporting(bool importing) {
    _isImporting = importing;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // Don't dispose services (managed by GetIt)
    super.dispose();
  }
}
