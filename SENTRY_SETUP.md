# Sentry Error Tracking - Setup Guide

## Overview
Sentry provides real-time error tracking and performance monitoring for the TimeTable app. This helps identify and fix bugs in production before users report them.

## What Sentry Captures

### Errors
- Unhandled exceptions (crashes)
- Handled errors logged via `Sentry.captureException()`
- Flutter framework errors
- Network errors
- Database errors

### Performance
- Screen load times
- Network request durations
- Database query performance
- Custom transaction monitoring

### Context
- Device information (model, OS version)
- App version and build number
- User ID (anonymous Firebase UID)
- Breadcrumbs (user actions leading to error)
- Stack traces with source maps

## Setup Instructions

### 1. Create Sentry Account

1. Go to [https://sentry.io](https://sentry.io)
2. Sign up (free tier available: 5K errors/month, 14-day retention)
3. Create new project:
   - Platform: **Flutter**
   - Project name: **TimeTable** (or your choice)
   - Alert frequency: **On every new issue** (recommended)

### 2. Get Your DSN

After creating the project:
1. Navigate to **Settings** → **Projects** → **TimeTable** → **Client Keys (DSN)**
2. Copy the DSN (looks like: `https://abc123@o123456.ingest.sentry.io/789012`)

### 3. Configure DSN in App

**Option A: Environment Variable (Recommended for CI/CD)**

```bash
# Build with DSN
flutter build apk --dart-define=SENTRY_DSN=https://your-dsn-here
```

Update [lib/core/constants/sentry_config.dart](lib/core/constants/sentry_config.dart):
```dart
static const String dsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: '',  // Empty = disabled for local dev
);
```

**Option B: Hardcode (Quick Setup)**

Update [lib/core/constants/sentry_config.dart](lib/core/constants/sentry_config.dart):
```dart
static const String dsn = 'https://your-dsn-here@sentry.io/your-project-id';
```

⚠️ **Warning**: Don't commit real DSN to public repositories! Use environment variables or secrets management.

### 4. Test Sentry Integration

Add a test button in settings (dev mode only):

```dart
// In settings_screen.dart (development only)
ElevatedButton(
  onPressed: () {
    // Test error
    throw Exception('Test Sentry error capture');
  },
  child: Text('Test Sentry'),
),

// Test performance
ElevatedButton(
  onPressed: () async {
    final transaction = Sentry.startTransaction('test-transaction', 'test');
    await Future.delayed(Duration(seconds: 2));
    await transaction.finish();
  },
  child: Text('Test Performance'),
),
```

After pressing the button, check Sentry dashboard for the error/transaction.

## Configuration Options

### Current Settings

See [lib/core/constants/sentry_config.dart](lib/core/constants/sentry_config.dart):

```dart
class SentryConfig {
  static const String dsn = '';  // Your DSN here
  static const String environment = 'development';  // or 'production'
  static const String release = 'timetable@0.1.0+1';
  static const double tracesSampleRate = 0.1;  // 10% of transactions
}
```

### Environment

Set environment based on build:

```bash
# Development
flutter run --dart-define=SENTRY_ENV=development

# Staging
flutter build apk --dart-define=SENTRY_ENV=staging

# Production
flutter build apk --dart-define=SENTRY_ENV=production --release
```

### Sample Rates

**Traces Sample Rate** (`tracesSampleRate`):
- `0.0` = No performance monitoring (free tier)
- `0.1` = Monitor 10% of transactions (recommended)
- `1.0` = Monitor 100% (expensive, use only in development)

**Why 10%?**
- Free tier: 10K transactions/month
- With 1K daily users × 10 screens = 10K transactions/day
- 10% sampling = 1K transactions/day ≈ 30K/month (over limit)
- Use 0.1 to stay within free tier

## Manual Error Logging

### Log Exceptions

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  // Log to Sentry
  Sentry.captureException(e, stackTrace: stackTrace);

  // Also log to console (development)
  debugPrint('Error: $e');
}
```

### Log Messages

```dart
// Info level
Sentry.captureMessage('User imported timetable', level: SentryLevel.info);

// Warning level
Sentry.captureMessage('API rate limit approaching', level: SentryLevel.warning);

// Error level
Sentry.captureMessage('Failed to sync data', level: SentryLevel.error);
```

### Add Context

```dart
Sentry.configureScope((scope) {
  // User context (anonymous ID only)
  scope.setUser(SentryUser(id: anonymousUid));

  // Custom tags
  scope.setTag('feature', 'timetable_import');
  scope.setTag('timetable_count', '3');

  // Extra data
  scope.setExtra('timetable_id', 'ABC123');
  scope.setExtra('share_code', 'XYZ789');
});
```

### Breadcrumbs (User Actions)

```dart
Sentry.addBreadcrumb(Breadcrumb(
  message: 'User tapped import button',
  category: 'user_action',
  level: SentryLevel.info,
  data: {'screen': 'import'},
));
```

## Performance Monitoring

### Automatic Tracking

Sentry automatically tracks:
- App start time
- Screen load times (via navigation)
- HTTP requests (if using `http` package with Sentry integration)

### Manual Transactions

Track custom operations:

```dart
// Start transaction
final transaction = Sentry.startTransaction(
  'import_timetable',
  'task',
);

try {
  // Your code here
  await importTimetableFromFirestore(shareCode);

  transaction.status = SpanStatus.ok();
} catch (e) {
  transaction.status = SpanStatus.internalError();
  Sentry.captureException(e);
} finally {
  await transaction.finish();
}
```

### Spans (Sub-operations)

```dart
final transaction = Sentry.startTransaction('create_timetable', 'task');

// Sub-operation 1: Validate
final validateSpan = transaction.startChild('validate');
await validateTimetableData(data);
await validateSpan.finish();

// Sub-operation 2: Save to DB
final saveSpan = transaction.startChild('save_to_db');
await saveTimetableToSqlite(timetable);
await saveSpan.finish();

await transaction.finish();
```

This gives you a detailed breakdown in Sentry:
```
create_timetable (500ms)
  ├─ validate (50ms)
  └─ save_to_db (450ms)
```

## Integration Examples

### In TimetableService

```dart
class TimetableService {
  Future<void> createTimetable(Timetable timetable) async {
    final transaction = Sentry.startTransaction('create_timetable', 'service');

    try {
      Sentry.addBreadcrumb(Breadcrumb(
        message: 'Creating timetable: ${timetable.name}',
        category: 'timetable',
      ));

      final span = transaction.startChild('save_to_sqlite');
      await _timetableRepo.create(timetable);
      await span.finish();

      transaction.status = SpanStatus.ok();
    } catch (e, stackTrace) {
      transaction.status = SpanStatus.internalError();
      Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    } finally {
      await transaction.finish();
    }
  }
}
```

### In SharingService

```dart
class SharingService {
  Future<Timetable?> importTimetable(String shareCode) async {
    final transaction = Sentry.startTransaction('import_timetable', 'service');

    Sentry.configureScope((scope) {
      scope.setTag('share_code', shareCode);
    });

    try {
      final fetchSpan = transaction.startChild('fetch_from_firestore');
      final doc = await _firestore.collection('timetables').doc(shareCode).get();
      await fetchSpan.finish();

      if (!doc.exists) {
        Sentry.captureMessage(
          'Share code not found: $shareCode',
          level: SentryLevel.warning,
        );
        return null;
      }

      final saveSpan = transaction.startChild('save_to_local');
      final timetable = Timetable.fromFirestore(doc);
      await _timetableRepo.create(timetable);
      await saveSpan.finish();

      transaction.status = SpanStatus.ok();
      return timetable;
    } catch (e, stackTrace) {
      transaction.status = SpanStatus.internalError();
      Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    } finally {
      await transaction.finish();
    }
  }
}
```

## Sentry Dashboard

### Issues Tab
- View all errors grouped by type
- See error frequency and affected users
- Stack traces with source maps
- Breadcrumbs showing user actions before crash

### Performance Tab
- View slowest transactions
- See p50, p75, p95, p99 latencies
- Identify performance bottlenecks
- Compare performance across versions

### Releases Tab
- Track errors by app version
- See which version introduced a bug
- Monitor adoption of new releases

## Alerts

Configure alerts in Sentry:

1. **Issues** → **Alert Rules** → **Create Alert**
2. Alert when:
   - New issue is created (first occurrence)
   - Issue frequency increases by 50% (regression)
   - Issue affects more than 100 users
3. Notification channels:
   - Email
   - Slack
   - Discord
   - Webhook

## Privacy Considerations

### What Sentry Collects
- ✅ Anonymous user IDs (Firebase anonymous UID)
- ✅ Device info (model, OS version)
- ✅ App version
- ✅ Error messages and stack traces
- ✅ User actions (breadcrumbs)

### What Sentry Does NOT Collect
- ❌ Personal names or emails (we use anonymous auth)
- ❌ Timetable content (activities, descriptions)
- ❌ Exact location (only timezone)

### Data Scrubbing

Sentry automatically scrubs sensitive data:
- Passwords
- Credit card numbers
- API keys

To scrub custom fields:

```dart
options.beforeSend = (event, hint) {
  // Remove sensitive data
  event.extra?.remove('password');
  event.extra?.remove('api_key');
  return event;
};
```

## Cost & Free Tier

### Free Tier Limits
- **Errors**: 5,000 events/month
- **Performance**: 10,000 transactions/month
- **Retention**: 14 days
- **Team Members**: Unlimited

### Estimated Usage (10K MAU)
- **Errors**: ~500/month (assuming 5% crash rate)
- **Performance** (10% sampling): ~30K/month ⚠️ **Over limit**

**Solution**: Use `tracesSampleRate: 0.03` (3%) to stay within 10K/month

### Paid Plans (if needed)
- **Team**: $26/month (50K errors, 100K transactions)
- **Business**: $80/month (100K errors, 500K transactions)

## Troubleshooting

### Errors Not Appearing in Sentry

1. **Check DSN is set**:
   ```dart
   print(SentryConfig.dsn);  // Should not be empty
   ```

2. **Check internet connection**:
   - Sentry requires network to send events
   - Events are queued offline and sent when online

3. **Check beforeSend filter**:
   - Ensure your `beforeSend` isn't filtering all events
   - Temporarily remove filter to test

4. **Check Sentry status**:
   - Visit [status.sentry.io](https://status.sentry.io)

### Performance Data Not Showing

1. **Check sample rate**:
   ```dart
   print(SentryConfig.tracesSampleRate);  // Should be > 0.0
   ```

2. **Wait for transactions to finish**:
   - Always call `await transaction.finish()`

3. **Check free tier quota**:
   - Sentry → Settings → Subscription
   - If over quota, reduce sample rate

### High Event Volume

If you're getting too many events:

1. **Filter noisy errors**:
   ```dart
   options.beforeSend = (event, hint) {
     // Ignore network errors
     if (event.message?.formatted.contains('SocketException') == true) {
       return null;
     }
     return event;
   };
   ```

2. **Reduce sample rate**:
   ```dart
   static const double tracesSampleRate = 0.01;  // 1% instead of 10%
   ```

3. **Use fingerprinting** to group similar errors:
   ```dart
   options.beforeSend = (event, hint) {
     event.fingerprint = ['custom-fingerprint-key'];
     return event;
   };
   ```

## Best Practices

### DO
- ✅ Use environment variables for DSN
- ✅ Add context (user ID, tags) to errors
- ✅ Use breadcrumbs to track user flow
- ✅ Test Sentry in development
- ✅ Set up alerts for critical errors
- ✅ Review Sentry dashboard weekly
- ✅ Update release version on each deploy

### DON'T
- ❌ Log sensitive data (passwords, tokens)
- ❌ Commit DSN to public repositories
- ❌ Use 100% sampling in production
- ❌ Ignore Sentry alerts
- ❌ Send every debug print to Sentry

## Production Checklist

Before launching:

- [ ] Sentry account created
- [ ] DSN configured (via environment variable)
- [ ] Environment set to 'production'
- [ ] Release version updated (matches pubspec.yaml)
- [ ] Sample rate optimized for free tier (0.03 or lower)
- [ ] Alerts configured (email/Slack)
- [ ] Privacy policy mentions error tracking
- [ ] Test error captured successfully
- [ ] Test performance transaction captured
- [ ] beforeSend filter tested
- [ ] Source maps uploaded (for ProGuard builds)

## Resources

- [Sentry Flutter Docs](https://docs.sentry.io/platforms/flutter/)
- [Sentry Performance Monitoring](https://docs.sentry.io/product/performance/)
- [Sentry Alerts Guide](https://docs.sentry.io/product/alerts/)
- [Sentry Discord Community](https://discord.gg/sentry)

## Support

If you encounter issues:
1. Check [Sentry Docs](https://docs.sentry.io)
2. Search [GitHub Issues](https://github.com/getsentry/sentry-dart/issues)
3. Ask in [Sentry Discord](https://discord.gg/sentry)
4. Contact Sentry support (paid plans only)
