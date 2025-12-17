/// Sentry configuration for error tracking and performance monitoring
///
/// To use Sentry:
/// 1. Create account at https://sentry.io
/// 2. Create new Flutter project
/// 3. Copy DSN and update below
/// 4. Set environment based on build mode
class SentryConfig {
  /// Sentry DSN (Data Source Name)
  ///
  /// Get this from: https://sentry.io/settings/projects/your-project/keys/
  ///
  /// Format: https://public_key@sentry.io/project_id
  ///
  /// IMPORTANT: Replace with your actual DSN before deploying to production
  static const String dsn = '';  // Empty = Sentry disabled (for development)

  /// Environment (development, staging, production)
  ///
  /// Used to filter errors by environment in Sentry dashboard
  static const String environment = String.fromEnvironment(
    'SENTRY_ENV',
    defaultValue: 'development',
  );

  /// App version/release identifier
  ///
  /// Format: app_name@version+build
  /// Example: timetable@0.1.0+1
  static const String release = 'timetable@0.1.0+1';

  /// Traces sample rate (0.0 to 1.0)
  ///
  /// - 0.0 = No performance monitoring
  /// - 1.0 = Monitor 100% of transactions (can be expensive)
  /// - 0.1 = Monitor 10% of transactions (recommended for production)
  static const double tracesSampleRate = 0.1;

  /// Whether Sentry is enabled
  ///
  /// Only enabled if DSN is provided
  static bool get isEnabled => dsn.isNotEmpty;
}
