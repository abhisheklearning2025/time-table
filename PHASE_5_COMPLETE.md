# Phase 5 Complete - Audio & Notification Services

## ✅ What We Built

### 1. AudioService - Background Audio Playback

**File:** `lib/domain/services/audio_service.dart`

**Features:**
- ✅ Background audio playback with proper audio context
- ✅ Category-specific alert sounds
- ✅ Custom audio file support (device storage)
- ✅ Volume control integration with settings
- ✅ 5-minute warning alerts (softer volume)
- ✅ Test audio playback for settings screen
- ✅ Audio validation on startup
- ✅ Pause/resume/stop controls

**Key Methods:**
```dart
Future<void> playActivityAlert(Activity activity)  // Play alert for activity
Future<void> playWarningAlert()                   // Play 5-min warning
Future<void> testAudio(String categoryId)         // Test sound in settings
Future<void> stop()                                // Stop playback
Future<void> setVolume(double volume)              // Set volume (0.0-1.0)
Future<bool> validateAudioAssets()                 // Check if audio files exist
```

**Audio Context Configuration:**
- **iOS**: `AVAudioSessionCategory.playback` with mix and duck options
- **Android**: `AndroidUsageType.alarm` with audio focus and stay awake

**Category-to-Audio Mapping:**
```dart
study    → audio/default/study.mp3
work     → audio/default/work.mp3
chill    → audio/default/chill.mp3
family   → audio/default/family.mp3
fitness  → audio/default/fitness.mp3
sleep    → audio/default/sleep.mp3
food     → audio/default/food.mp3
personal → audio/default/personal.mp3
social   → audio/default/social.mp3
creative → audio/default/creative.mp3
learning → audio/default/learning.mp3
health   → audio/default/health.mp3
*fallback* → audio/default/general.mp3
warning  → audio/default/warning.mp3
```

### 2. NotificationService - Activity Alerts

**File:** `lib/domain/services/notification_service.dart`

**Features:**
- ✅ Schedule exact alarm notifications
- ✅ Multi-timetable notification support (up to 6 timetables)
- ✅ Activity start notifications
- ✅ 5-minute warning notifications
- ✅ Notification channels (Android)
- ✅ Permission requests (Android 13+, iOS)
- ✅ Notification tap handling with payload
- ✅ Midnight crossing support for scheduling
- ✅ Cancel/reschedule notifications

**Notification Channels:**
1. **activity_alerts** - High importance, sound + vibration + lights
2. **warning_alerts** - Default importance, sound only

**Key Methods:**
```dart
Future<void> initialize()                                    // Setup notifications
Future<bool> requestPermissions()                            // Request permissions
Future<void> scheduleAllNotifications(List<Timetable> timetables)  // Schedule for active tables
Future<void> showNotification({...})                         // Show immediate notification
Future<void> cancelAllNotifications()                        // Cancel all
Future<void> cancelTimetableNotifications(String id)         // Cancel for specific table
Future<int> getPendingNotificationCount()                    // Get pending count
```

**Scheduling Logic:**
- Calculates next occurrence of each activity
- Handles midnight crossing (e.g., sleep 11 PM - 7 AM)
- Generates unique notification IDs from timetable hash + activity index
- Schedules both activity start + 5-minute warning
- Uses `AndroidScheduleMode.exactAllowWhileIdle` for reliability

**Notification Payload Format:**
```
"timetableId|activityId"           // For activity start
"timetableId|activityId|warning"   // For 5-min warning
```

### 3. BackgroundService - Orchestration

**File:** `lib/domain/services/background_service.dart`

**Features:**
- ✅ Periodic notification rescheduling (every 15 minutes)
- ✅ Coordinate audio and notification services
- ✅ Handle activity alert triggers
- ✅ Handle warning alert triggers
- ✅ Auto-reschedule on timetable changes
- ✅ Service start/stop controls
- ✅ Debug logging

**Key Methods:**
```dart
Future<void> start()                                      // Start background service
Future<void> stop()                                       // Stop background service
Future<void> rescheduleNotifications()                    // Reschedule after changes
Future<void> handleActivityAlert(String timetableId, String activityId)  // Trigger audio
Future<void> handleWarningAlert()                         // Trigger warning
bool get isRunning                                        // Check if running
```

**How It Works:**
```
App Launch
  ↓
BackgroundService.start()
  ↓
Initialize NotificationService
  ↓
Schedule notifications for all active timetables (up to 6)
  ↓
Start 15-minute periodic timer
  ↓
Every 15 minutes:
  - Get active timetables
  - Reschedule notifications
  - Log pending count
  ↓
When notification fires:
  - System shows notification
  - User taps → Payload parsed → Navigate to timetable
  - (Audio handled by notification sound or foreground service)
```

**Foreground Service (for audio):**
- Service name: `com.ryanheise.audioservice.AudioService`
- Type: `mediaPlayback`
- Used when audio needs to play in background

### 4. Dependency Injection Updates

**File:** `lib/services/dependency_injection.dart`

**Added:**
```dart
// Phase 5: Register audio, notification, and background services
getIt.registerLazySingleton<AudioService>(
  () => AudioService(settingsRepo: getIt<SettingsRepository>()),
);

getIt.registerLazySingleton<NotificationService>(
  () => NotificationService(
    settingsRepo: getIt<SettingsRepository>(),
    audioService: getIt<AudioService>(),
  ),
);

getIt.registerLazySingleton<BackgroundService>(
  () => BackgroundService(
    timetableRepo: getIt<TimetableRepository>(),
    notificationService: getIt<NotificationService>(),
    audioService: getIt<AudioService>(),
  ),
);
```

**Usage:**
```dart
final audioService = getIt<AudioService>();
final notificationService = getIt<NotificationService>();
final backgroundService = getIt<BackgroundService>();
```

### 5. Android Permissions & Manifest

**File:** `android/app/src/main/AndroidManifest.xml`

**Added Permissions:**
```xml
<!-- Audio playback and background alerts -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

**Foreground Service Declaration:**
```xml
<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false">
</service>
```

### 6. Audio Asset Structure

**Directory:** `assets/audio/default/`

**Required Files:** (See `assets/audio/default/README.md` for details)
- 12 category sounds (study, work, chill, family, fitness, sleep, food, personal, social, creative, learning, health)
- 1 general fallback sound
- 1 warning sound (5-minute alerts)

**Total:** 14 MP3 files needed

**📝 Note:** Audio files are NOT included in the codebase. See [README.md](../../../assets/audio/default/README.md) for instructions on adding audio files.

---

## 📁 File Structure

```
lib/
├── domain/
│   └── services/
│       ├── audio_service.dart              ✅ NEW
│       ├── notification_service.dart       ✅ NEW
│       └── background_service.dart         ✅ NEW
├── services/
│   └── dependency_injection.dart           ✅ UPDATED
android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml         ✅ UPDATED
assets/
└── audio/
    └── default/
        ├── README.md                       ✅ NEW
        └── .gitkeep                        ✅ NEW
```

---

## 🎯 Use Cases Implemented

### Use Case 1: Start Background Service
```dart
final backgroundService = getIt<BackgroundService>();

// Start service (schedules notifications for all active timetables)
await backgroundService.start();

// Service will:
// 1. Initialize notifications
// 2. Get all timetables with alerts enabled (up to 6)
// 3. Schedule notifications for each activity
// 4. Start 15-minute periodic timer for rescheduling
```

### Use Case 2: Request Notification Permissions
```dart
final notificationService = getIt<NotificationService>();

// Request permissions (Android 13+, iOS)
final granted = await notificationService.requestPermissions();

if (granted) {
  print('Notification permissions granted!');
} else {
  print('Notification permissions denied');
}
```

### Use Case 3: Play Activity Alert
```dart
final audioService = getIt<AudioService>();

// Play alert for an activity
await audioService.playActivityAlert(activity);

// Uses category-specific sound or custom audio path
// Volume controlled by settings
```

### Use Case 4: Schedule Notifications After Timetable Change
```dart
final backgroundService = getIt<BackgroundService>();
final timetableService = getIt<TimetableService>();

// User creates a new timetable
await timetableService.createTimetable(...);

// Reschedule notifications
await backgroundService.rescheduleNotifications();
```

### Use Case 5: Test Audio in Settings
```dart
final audioService = getIt<AudioService>();

// Test a category sound
await audioService.testAudio('study');  // Plays study.mp3

// Set volume
await audioService.setVolume(0.7);  // 70% volume
```

### Use Case 6: Check Pending Notifications
```dart
final notificationService = getIt<NotificationService>();

// Get count of pending notifications
final count = await notificationService.getPendingNotificationCount();
print('$count notifications scheduled');

// Get all pending notifications (for debugging)
final pending = await notificationService.getPendingNotifications();
for (final notification in pending) {
  print('${notification.id}: ${notification.title} at ${notification.payload}');
}
```

### Use Case 7: Handle Notification Tap
```dart
// When user taps notification, the payload is parsed:
// "timetableId|activityId" or "timetableId|activityId|warning"

// NotificationService automatically handles this in _onNotificationTapped
// TODO: In Phase 6, this will navigate to timetable detail screen
```

---

## 🧪 What's Ready

All audio and notification features are implemented:
- ✅ AudioService with background playback
- ✅ NotificationService with exact alarm scheduling
- ✅ BackgroundService with periodic checks
- ✅ Multi-timetable support (up to 6 simultaneous)
- ✅ Permission handling
- ✅ Foreground service configuration
- ✅ Dependency injection configured

**⚠️ What's NOT Ready:**
- ❌ Audio files not included (user must add 14 MP3 files)
- ❌ Navigation on notification tap (will be added in Phase 6)
- ❌ Foreground service implementation (placeholder only)
- ❌ Boot receiver for rescheduling after device restart

---

## 📋 What's Next

**Before Testing Phase 5:**
1. Add audio files to `assets/audio/default/` (see README.md)
2. Request notification permissions on first launch
3. Start BackgroundService in main.dart

**Phase 6: State Management (Providers)**
- AuthProvider
- TimetableProvider
- CurrentActivityProvider
- SettingsProvider
- AudioProvider (real-time audio state)
- NotificationProvider (permission state)
- Setup MultiProvider in main.dart
- Start BackgroundService on app launch

**Phases 7-13: UI Screens**
- Home screen (timetable list)
- Detail view (current activity banner)
- Create/edit screens
- Share/import screens
- Settings screen (volume slider, test audio, permissions)
- Alert dialogs (with snooze/dismiss)

---

## ✅ Phase 5 Status: **COMPLETE** (Code-wise)

All services are implemented and ready for integration!

**Action Items:**
1. **Add audio files** - See `assets/audio/default/README.md`
2. **Test permissions** - Request notification permissions in UI
3. **Start service** - Call `backgroundService.start()` in main.dart

Next: **Start Phase 6** (State Management with Providers) when ready 🚀

---

## 📝 Technical Notes

### Notification Scheduling
- Uses `flutter_local_notifications` with `zonedSchedule`
- Android: `AndroidScheduleMode.exactAllowWhileIdle` for reliability
- Requires `SCHEDULE_EXACT_ALARM` permission (Android 12+)
- Unique IDs generated from timetable hash + activity index

### Audio Playback
- Uses `audioplayers` package
- Background playback via `AudioContext` configuration
- iOS: `AVAudioSessionCategory.playback`
- Android: `AndroidUsageType.alarm` with audio focus

### Midnight Crossing
- Activities spanning midnight (e.g., sleep 11 PM - 7 AM) handled correctly
- Notification scheduling accounts for `isNextDay` flag
- Next occurrence calculation considers current time vs activity time

### Multi-Timetable Support
- Up to 6 timetables can have alerts enabled
- Each timetable's activities get unique notification IDs
- Notifications rescheduled every 15 minutes to stay current
- Handles overlapping activities from different timetables

### Performance Considerations
- Periodic timer runs every 15 minutes (not every minute)
- Notifications scheduled in advance (not real-time checks)
- Audio files should be under 500 KB each
- Foreground service only runs during audio playback

### Future Enhancements
- Boot receiver to reschedule after device restart
- Foreground service for actual audio playback
- Snooze functionality in notifications
- Multiple notification actions (Snooze/Dismiss/Open)
- Notification grouping for multiple timetables
