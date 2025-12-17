import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

/// Service for handling deep links
/// Processes incoming share links (timetable.app/t/ABC123)
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  final StreamController<String> _shareCodeController = StreamController<String>.broadcast();

  /// Stream of incoming share codes from deep links
  Stream<String> get shareCodeStream => _shareCodeController.stream;

  /// Initialize deep link handling
  /// Call this in main() or app initialization
  Future<void> initialize() async {
    // Handle initial link (app opened via link)
    final initialUri = await _getInitialLink();
    if (initialUri != null) {
      final shareCode = _extractShareCode(initialUri);
      if (shareCode != null) {
        _shareCodeController.add(shareCode);
        debugPrint('DeepLinkService: Initial link share code: $shareCode');
      }
    }

    // Handle incoming links (app already running)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        final shareCode = _extractShareCode(uri);
        if (shareCode != null) {
          _shareCodeController.add(shareCode);
          debugPrint('DeepLinkService: Incoming link share code: $shareCode');
        }
      },
      onError: (err) {
        debugPrint('DeepLinkService: Error handling link - $err');
      },
    );

    debugPrint('DeepLinkService: Initialized');
  }

  /// Get initial link (when app is opened via link)
  Future<Uri?> _getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('DeepLinkService: Initial link: $uri');
      }
      return uri;
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link - $e');
      return null;
    }
  }

  /// Extract share code from URI
  /// Supports formats:
  /// - https://timetable.app/t/ABC123
  /// - http://timetable.app/t/ABC123
  /// - timetable://t/ABC123
  /// - timetable://ABC123
  String? _extractShareCode(Uri uri) {
    debugPrint('DeepLinkService: Processing URI: $uri');

    // Check scheme
    if (uri.scheme != 'https' && uri.scheme != 'http' && uri.scheme != 'timetable') {
      debugPrint('DeepLinkService: Invalid scheme: ${uri.scheme}');
      return null;
    }

    // For web links (https/http)
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      // Check host
      if (uri.host != 'timetable.app') {
        debugPrint('DeepLinkService: Invalid host: ${uri.host}');
        return null;
      }

      // Extract from path: /t/ABC123
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 't') {
        final shareCode = pathSegments[1];
        if (_isValidShareCode(shareCode)) {
          return shareCode;
        }
      }
    }

    // For custom scheme (timetable://)
    if (uri.scheme == 'timetable') {
      // Format: timetable://t/ABC123 or timetable://ABC123
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        // timetable://t/ABC123
        if (pathSegments.length >= 2 && pathSegments[0] == 't') {
          final shareCode = pathSegments[1];
          if (_isValidShareCode(shareCode)) {
            return shareCode;
          }
        }
        // timetable://ABC123 (direct code)
        else if (pathSegments.length == 1) {
          final shareCode = pathSegments[0];
          if (_isValidShareCode(shareCode)) {
            return shareCode;
          }
        }
      }

      // Also check host as share code (timetable://ABC123)
      if (uri.host.isNotEmpty && _isValidShareCode(uri.host)) {
        return uri.host;
      }
    }

    debugPrint('DeepLinkService: Could not extract share code from URI');
    return null;
  }

  /// Validate share code format
  /// Share codes are 6 characters: uppercase letters + numbers
  bool _isValidShareCode(String code) {
    if (code.length != 6) {
      return false;
    }

    // Must be alphanumeric (A-Z, 0-9)
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(code);
  }

  /// Generate share link for a given share code
  /// Returns: https://timetable.app/t/ABC123
  String generateShareLink(String shareCode) {
    return 'https://timetable.app/t/$shareCode';
  }

  /// Generate custom scheme link
  /// Returns: timetable://t/ABC123
  String generateCustomSchemeLink(String shareCode) {
    return 'timetable://t/$shareCode';
  }

  /// Check if a URI is a valid timetable share link
  bool isValidShareLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      return _extractShareCode(uri) != null;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _shareCodeController.close();
  }
}
