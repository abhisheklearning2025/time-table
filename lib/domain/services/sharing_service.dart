import '../../data/models/timetable.dart';
import '../../data/repositories/firestore_repository.dart';
import '../../data/repositories/timetable_repository.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';

/// Service for timetable sharing operations
/// Handles export/import via code, QR, and links
class SharingService {
  final FirestoreRepository _firestoreRepo;
  final TimetableRepository _timetableRepo;
  final AuthService _authService;

  SharingService({
    required FirestoreRepository firestoreRepo,
    required TimetableRepository timetableRepo,
    required AuthService authService,
  })  : _firestoreRepo = firestoreRepo,
        _timetableRepo = timetableRepo,
        _authService = authService;

  /// Base URL for deep links (update this with your actual domain)
  static const String _baseUrl = 'https://timetable.app';

  /// Export timetable to Firebase and get share code
  /// Returns 6-digit code (e.g., "ABC123")
  Future<String> exportTimetable(String timetableId) async {
    // Get timetable
    final timetable = await _timetableRepo.getTimetableById(timetableId);
    if (timetable == null) {
      throw Exception('Timetable not found');
    }

    // Check if user is signed in
    if (!_authService.isSignedIn) {
      throw Exception('User must be signed in to share timetables');
    }

    // Only own timetables can be shared
    if (timetable.type != TimetableType.own) {
      throw Exception('Only own timetables can be shared');
    }

    // Export to Firestore
    final shareCode = await _firestoreRepo.exportTimetable(
      timetable,
      _authService.currentUserId!,
    );

    // Update local timetable with share code
    final updatedTimetable = timetable.copyWith(
      shareCode: shareCode,
      ownerId: _authService.currentUserId,
    );
    await _timetableRepo.updateTimetable(updatedTimetable);

    return shareCode;
  }

  /// Import timetable from share code
  /// Downloads from Firestore and saves locally
  Future<Timetable> importTimetable(String shareCode) async {
    // Clean share code (remove spaces, uppercase)
    final cleanCode = shareCode.trim().toUpperCase();

    // Check if can import more
    final importedCount = (await _timetableRepo.getImportedTimetables()).length;
    if (!_timetableRepo.canImportMoreTimetables(importedCount)) {
      throw Exception(
        'Cannot import more than ${TimetableRepository.maxImportedTimetables} timetables',
      );
    }

    // Download from Firestore
    final timetable = await _firestoreRepo.importTimetable(cleanCode);
    if (timetable == null) {
      throw Exception('Timetable not found with code: $cleanCode');
    }

    // Generate new IDs for local storage
    final uuid = const Uuid();
    final newTimetableId = uuid.v4();

    // Update timetable for local storage
    final localTimetable = timetable.copyWith(
      id: newTimetableId,
      type: TimetableType.imported,
      isActive: false,
      alertsEnabled: false, // User can enable later
      shareCode: cleanCode,
    );

    // Update activity IDs to reference new timetable
    final updatedActivities = localTimetable.activities.map((activity) {
      return activity.copyWith(
        id: uuid.v4(),
        timetableId: newTimetableId,
      );
    }).toList();

    final finalTimetable = localTimetable.copyWith(activities: updatedActivities);

    // Save locally
    await _timetableRepo.createTimetable(finalTimetable);

    // Increment import count in Firestore
    await _firestoreRepo.incrementImportCount(cleanCode);

    return finalTimetable;
  }

  /// Generate shareable link
  /// Format: https://timetable.app/t/ABC123
  String generateShareLink(String shareCode) {
    return '$_baseUrl/t/${shareCode.toUpperCase()}';
  }

  /// Generate QR code data (the string to encode in QR)
  /// Returns the share link that can be encoded as QR code
  String generateQRData(String shareCode) {
    return generateShareLink(shareCode);
  }

  /// Parse share code from deep link
  /// Extracts "ABC123" from "https://timetable.app/t/ABC123"
  String? parseShareCodeFromLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;

    // Check if it's our domain
    if (!uri.host.contains('timetable.app')) return null;

    // Extract code from path
    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 't') {
      return pathSegments[1].toUpperCase();
    }

    return null;
  }

  /// Check if share code is valid format (6 alphanumeric characters)
  bool isValidShareCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(cleanCode);
  }

  /// Browse public templates
  Future<List<Timetable>> browseTemplates({String? category}) async {
    return await _firestoreRepo.browseTemplates(category: category);
  }

  /// Import a template (same as importing shared timetable)
  Future<Timetable> importTemplate(String templateId) async {
    return await importTimetable(templateId);
  }
}
