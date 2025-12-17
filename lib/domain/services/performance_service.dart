import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring app performance
///
/// Uses Firebase Performance Monitoring to track:
/// - Screen load times
/// - Network requests
/// - Custom traces for critical operations
class PerformanceService {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // Cache for active traces
  final Map<String, Trace> _activeTraces = {};

  /// Enable/disable performance monitoring
  ///
  /// Automatically disabled on web and in debug mode
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    if (!kIsWeb) {
      await _performance.setPerformanceCollectionEnabled(enabled);
    }
  }

  // ========== Custom Traces ==========

  /// Start a custom trace
  ///
  /// Returns trace ID for later stopping
  Future<String> startTrace(String traceName) async {
    if (kIsWeb) return traceName;

    final trace = _performance.newTrace(traceName);
    await trace.start();
    _activeTraces[traceName] = trace;
    return traceName;
  }

  /// Stop a custom trace
  Future<void> stopTrace(String traceName, {Map<String, String>? attributes}) async {
    if (kIsWeb) return;

    final trace = _activeTraces[traceName];
    if (trace != null) {
      // Add attributes
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      await trace.stop();
      _activeTraces.remove(traceName);
    }
  }

  /// Add metric to active trace
  Future<void> incrementMetric(String traceName, String metricName, int value) async {
    if (kIsWeb) return;

    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.incrementMetric(metricName, value);
    }
  }

  /// Add attribute to active trace
  Future<void> setTraceAttribute(String traceName, String attribute, String value) async {
    if (kIsWeb) return;

    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.putAttribute(attribute, value);
    }
  }

  // ========== Convenience Methods ==========

  /// Trace a function execution
  Future<T> traceOperation<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final traceId = await startTrace(traceName);

    try {
      final result = await operation();
      await stopTrace(traceId, attributes: attributes);
      return result;
    } catch (e) {
      await stopTrace(traceId, attributes: {
        ...?attributes,
        'error': 'true',
        'error_type': e.runtimeType.toString(),
      });
      rethrow;
    }
  }

  // ========== Timetable Operations ==========

  /// Trace timetable creation
  Future<T> traceTimetableCreation<T>(Future<T> Function() operation) async {
    return traceOperation('timetable_create', operation);
  }

  /// Trace timetable load
  Future<T> traceTimetableLoad<T>(Future<T> Function() operation) async {
    return traceOperation('timetable_load', operation);
  }

  /// Trace timetable update
  Future<T> traceTimetableUpdate<T>(Future<T> Function() operation) async {
    return traceOperation('timetable_update', operation);
  }

  /// Trace timetable delete
  Future<T> traceTimetableDelete<T>(Future<T> Function() operation) async {
    return traceOperation('timetable_delete', operation);
  }

  // ========== Database Operations ==========

  /// Trace SQLite query
  Future<T> traceDatabaseQuery<T>(
    String queryType,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'db_$queryType',
      operation,
      attributes: {'db_type': 'sqlite'},
    );
  }

  /// Trace database insert
  Future<T> traceDatabaseInsert<T>(Future<T> Function() operation) async {
    return traceDatabaseQuery('insert', operation);
  }

  /// Trace database update
  Future<T> traceDatabaseUpdate<T>(Future<T> Function() operation) async {
    return traceDatabaseQuery('update', operation);
  }

  /// Trace database delete
  Future<T> traceDatabaseDelete<T>(Future<T> Function() operation) async {
    return traceDatabaseQuery('delete', operation);
  }

  // ========== Firebase Operations ==========

  /// Trace Firestore read
  Future<T> traceFirestoreRead<T>(
    String collection,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'firestore_read',
      operation,
      attributes: {'collection': collection},
    );
  }

  /// Trace Firestore write
  Future<T> traceFirestoreWrite<T>(
    String collection,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'firestore_write',
      operation,
      attributes: {'collection': collection},
    );
  }

  /// Trace authentication
  Future<T> traceAuth<T>(
    String authType,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'auth_$authType',
      operation,
      attributes: {'auth_method': 'anonymous'},
    );
  }

  // ========== Sharing Operations ==========

  /// Trace timetable export
  Future<T> traceExport<T>(Future<T> Function() operation) async {
    return traceOperation('timetable_export', operation);
  }

  /// Trace timetable import
  Future<T> traceImport<T>(
    String importMethod,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'timetable_import',
      operation,
      attributes: {'import_method': importMethod},
    );
  }

  /// Trace QR code generation
  Future<T> traceQRGeneration<T>(Future<T> Function() operation) async {
    return traceOperation('qr_generation', operation);
  }

  /// Trace QR code scanning
  Future<T> traceQRScanning<T>(Future<T> Function() operation) async {
    return traceOperation('qr_scanning', operation);
  }

  // ========== UI Operations ==========

  /// Trace screen load
  Future<void> traceScreenLoad(String screenName) async {
    await startTrace('screen_$screenName');
    // Note: Call stopTrace when screen is fully loaded
  }

  /// Complete screen load trace
  Future<void> completeScreenLoad(String screenName) async {
    await stopTrace('screen_$screenName');
  }

  /// Trace list rendering
  Future<T> traceListRendering<T>(
    int itemCount,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'list_rendering',
      operation,
      attributes: {'item_count': itemCount.toString()},
    );
  }

  // ========== Audio Operations ==========

  /// Trace audio playback
  Future<T> traceAudioPlayback<T>(Future<T> Function() operation) async {
    return traceOperation('audio_playback', operation);
  }

  /// Trace audio load
  Future<T> traceAudioLoad<T>(Future<T> Function() operation) async {
    return traceOperation('audio_load', operation);
  }

  // ========== Background Operations ==========

  /// Trace background task
  Future<T> traceBackgroundTask<T>(
    String taskName,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'background_$taskName',
      operation,
      attributes: {'task_type': 'workmanager'},
    );
  }

  /// Trace notification scheduling
  Future<T> traceNotificationScheduling<T>(Future<T> Function() operation) async {
    return traceOperation('notification_scheduling', operation);
  }

  // ========== Utility Methods ==========

  /// Create an HTTP metric manually
  ///
  /// Firebase Performance automatically tracks HTTP requests,
  /// but this can be used for custom tracking
  HttpMetric createHttpMetric(String url, HttpMethod httpMethod) {
    return _performance.newHttpMetric(url, httpMethod);
  }

  /// Record successful HTTP request
  Future<void> recordHttpSuccess(
    String url,
    HttpMethod method,
    int statusCode,
    int requestPayloadSize,
    int responsePayloadSize,
  ) async {
    if (kIsWeb) return;

    final metric = createHttpMetric(url, method);
    await metric.start();

    metric
      ..httpResponseCode = statusCode
      ..requestPayloadSize = requestPayloadSize
      ..responsePayloadSize = responsePayloadSize;

    await metric.stop();
  }

  /// Record failed HTTP request
  Future<void> recordHttpFailure(
    String url,
    HttpMethod method,
    String errorMessage,
  ) async {
    if (kIsWeb) return;

    final metric = createHttpMetric(url, method);
    await metric.start();

    metric.putAttribute('error', errorMessage);

    await metric.stop();
  }

  /// Dispose all active traces (call on app dispose)
  Future<void> dispose() async {
    for (final trace in _activeTraces.values) {
      try {
        await trace.stop();
      } catch (e) {
        debugPrint('Error stopping trace: $e');
      }
    }
    _activeTraces.clear();
  }
}

// ========== Usage Examples ==========

/// Example: Trace timetable creation with metrics
///
/// ```dart
/// final perfService = getIt<PerformanceService>();
///
/// await perfService.traceTimetableCreation(() async {
///   final timetable = await timetableService.createTimetable(data);
///   return timetable;
/// });
/// ```

/// Example: Manual trace with custom metrics
///
/// ```dart
/// await perfService.startTrace('import_timetable');
///
/// try {
///   final doc = await firestore.collection('timetables').doc(code).get();
///   await perfService.incrementMetric('import_timetable', 'firestore_reads', 1);
///
///   final timetable = Timetable.fromFirestore(doc);
///   await db.insert(timetable);
///   await perfService.incrementMetric('import_timetable', 'db_inserts', 1);
///
///   await perfService.setTraceAttribute('import_timetable', 'success', 'true');
/// } finally {
///   await perfService.stopTrace('import_timetable');
/// }
/// ```

/// Example: Screen load timing
///
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   void initState() {
///     super.initState();
///     perfService.traceScreenLoad('my_screen');
///
///     // Load data
///     _loadData().then((_) {
///       perfService.completeScreenLoad('my_screen');
///     });
///   }
/// }
/// ```
