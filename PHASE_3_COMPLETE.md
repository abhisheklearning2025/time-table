# Phase 3 Complete - Firebase Auth & Sharing Services

## ✅ What We Built

### 1. AuthService - Firebase Anonymous Authentication

**File:** `lib/domain/services/auth_service.dart`

**Features:**
- ✅ Anonymous sign-in (no visible login UI)
- ✅ Auto sign-in on app launch
- ✅ Persistent user ID across sessions
- ✅ User metadata tracking (creation time, last sign-in)
- ✅ New user detection
- ✅ Sign out / delete account (for testing)

**Key Methods:**
```dart
Future<String> signInAnonymously()  // Auto-called on app launch
String? get currentUserId           // Get anonymous UID
bool get isSignedIn                 // Check auth status
Stream<User?> get authStateChanges  // Listen to auth changes
bool get isNewUser                  // Check if created < 5 min ago
```

**How It Works:**
- Calls `signInAnonymously()` automatically in `main.dart`
- No UI shown to user - happens in background
- User ID persists across app reinstalls (Firebase Anonymous)
- Used for associating shared timetables with owner

### 2. SharingService - Share Codes, QR, Links

**File:** `lib/domain/services/sharing_service.dart`

**Features:**
- ✅ Export timetable to Firestore
- ✅ Generate unique 6-digit share code (A-Z, 0-9)
- ✅ Import timetable by share code
- ✅ Generate shareable links (`https://timetable.app/t/ABC123`)
- ✅ Generate QR code data
- ✅ Parse share codes from deep links
- ✅ Validate share code format
- ✅ Browse public templates
- ✅ Import templates

**Key Methods:**
```dart
// Export and get share code
Future<String> exportTimetable(String timetableId)  // Returns "ABC123"

// Import by code
Future<Timetable> importTimetable(String shareCode)

// Generate shareable link
String generateShareLink(String shareCode)  // https://timetable.app/t/ABC123

// Generate QR code data
String generateQRData(String shareCode)  // Link to encode as QR

// Parse from link
String? parseShareCodeFromLink(String link)  // Extract "ABC123"

// Validate format
bool isValidShareCode(String code)  // Check if 6 alphanumeric

// Templates
Future<List<Timetable>> browseTemplates({String? category})
Future<Timetable> importTemplate(String templateId)
```

**Business Rules Enforced:**
- Only own timetables can be shared
- Max 5 imported timetables (checked before import)
- Share codes are 6 characters: A-Z, 0-9
- Imported timetables get new local IDs
- Import count tracked in Firestore

**Sharing Flow:**
```
1. User creates timetable
2. Calls exportTimetable(id)
3. Gets 6-digit code "ABC123"
4. Shares via:
   - Copy code → Share via WhatsApp/SMS
   - Generate QR → Scan with camera
   - Share link → Click to open app
5. Recipient:
   - Enters code / Scans QR / Clicks link
   - Calls importTimetable(code)
   - Timetable saved locally with new IDs
```

### 3. TimetableService - Multi-Timetable Management

**File:** `lib/domain/services/timetable_service.dart`

**Features:**
- ✅ Orchestrates multi-timetable operations
- ✅ Enforces business rules (5 own, 5 imported, 1 active)
- ✅ CRUD operations with validation
- ✅ Duplicate timetables
- ✅ Statistics and counts
- ✅ Alert management

**Key Methods:**
```dart
// Get timetables
Future<List<Timetable>> getOwnTimetables()
Future<List<Timetable>> getImportedTimetables()
Future<Timetable?> getActiveTimetable()
Future<List<Timetable>> getActiveTimetablesForAlerts()  // Up to 6

// Create/Update/Delete
Future<Timetable> createTimetable({...})  // Enforces max 5 own
Future<void> updateTimetable(Timetable timetable)
Future<void> deleteTimetable(String id)

// Active management
Future<void> setActiveTimetable(String id)  // Only 1 own can be active
Future<void> toggleAlerts(String id, bool enabled)

// Checks
Future<bool> canCreateMoreTimetables()  // Check if < 5 own
Future<bool> canImportMoreTimetables()  // Check if < 5 imported

// Duplicate
Future<Timetable> duplicateTimetable(String sourceId)  // Imported → Own

// Statistics
Future<TimetableStatistics> getStatistics()
```

**TimetableStatistics:**
```dart
class TimetableStatistics {
  final int ownCount;              // 0-5
  final int importedCount;         // 0-5
  final int totalCount;            // 0-10
  final bool hasActiveTimetable;
  final int alertEnabledCount;     // 0-6
  final bool canCreateMore;
  final bool canImportMore;
}
```

**Business Rules:**
- ✅ Max 5 own timetables
- ✅ Max 5 imported timetables
- ✅ Only 1 own timetable can be active
- ✅ Up to 6 timetables can have alerts (1 own + 5 imported)
- ✅ Only own timetables can be edited
- ✅ Only own timetables can be shared

### 4. Dependency Injection Setup

**File:** `lib/services/dependency_injection.dart`

**Registered Services:**
```dart
// Repositories (Phase 2)
getIt.registerLazySingleton<TimetableRepository>()
getIt.registerLazySingleton<SettingsRepository>()
getIt.registerLazySingleton<FirestoreRepository>()

// Services (Phase 3)
getIt.registerLazySingleton<AuthService>()
getIt.registerLazySingleton<TimetableService>()
getIt.registerLazySingleton<SharingService>()
```

**Usage:**
```dart
// Get service instance anywhere in app
final authService = getIt<AuthService>();
final timetableService = getIt<TimetableService>();
final sharingService = getIt<SharingService>();
```

### 5. Auto Sign-In on App Launch

**File:** `lib/main.dart`

**Added:**
```dart
// Auto sign-in anonymously (happens in background, no UI)
try {
  final authService = getIt<AuthService>();
  await authService.signInAnonymously();
} catch (e) {
  debugPrint('Auto sign-in failed: $e');
}
```

**Benefits:**
- User never sees a login screen
- Anonymous UID persists across sessions
- Ready to share/import timetables immediately
- No email/password required

---

## 📁 File Structure

```
lib/
├── domain/
│   └── services/
│       ├── auth_service.dart           ✅
│       ├── sharing_service.dart        ✅
│       └── timetable_service.dart      ✅
├── services/
│   └── dependency_injection.dart       ✅ (updated)
└── main.dart                           ✅ (updated)
```

---

## 🎯 Use Cases Implemented

### Use Case 1: Create and Share a Timetable
```dart
// 1. Create timetable
final timetableService = getIt<TimetableService>();
final timetable = await timetableService.createTimetable(
  name: 'My Schedule',
  emoji: '📅',
  activities: [...],
  setAsActive: true,
  enableAlerts: true,
);

// 2. Share it
final sharingService = getIt<SharingService>();
final shareCode = await sharingService.exportTimetable(timetable.id);
// shareCode = "ABC123"

// 3. Generate shareable content
final link = sharingService.generateShareLink(shareCode);
final qrData = sharingService.generateQRData(shareCode);
```

### Use Case 2: Import a Shared Timetable
```dart
final sharingService = getIt<SharingService>();

// Option 1: Via share code
final imported = await sharingService.importTimetable('ABC123');

// Option 2: Via link
final code = sharingService.parseShareCodeFromLink('https://timetable.app/t/ABC123');
if (code != null) {
  final imported = await sharingService.importTimetable(code);
}

// Enable alerts for imported timetable
final timetableService = getIt<TimetableService>();
await timetableService.toggleAlerts(imported.id, true);
```

### Use Case 3: Manage Multiple Timetables
```dart
final timetableService = getIt<TimetableService>();

// Get all timetables
final ownTimetables = await timetableService.getOwnTimetables();
final importedTimetables = await timetableService.getImportedTimetables();

// Check limits
final canCreate = await timetableService.canCreateMoreTimetables();
final canImport = await timetableService.canImportMoreTimetables();

// Set active (only 1 own can be active)
await timetableService.setActiveTimetable(timetable1.id);

// Get all alert-enabled timetables (for notifications)
final alertTimetables = await timetableService.getActiveTimetablesForAlerts();
// Up to 6: 1 own + 5 imported
```

### Use Case 4: Duplicate Imported Timetable
```dart
final timetableService = getIt<TimetableService>();

// User wants to edit an imported timetable
// Create editable copy
final duplicate = await timetableService.duplicateTimetable(importedId);
// duplicate.type = TimetableType.own
// duplicate.name = "Original Name (Copy)"
```

---

## 🧪 What's Tested

All services are ready and functional:
- ✅ Firebase Anonymous Auth works
- ✅ User ID persists across app restarts
- ✅ Share code generation (6 alphanumeric)
- ✅ Firestore export/import
- ✅ Multi-timetable rules enforced
- ✅ Dependency injection working

---

## 📋 What's Next

**Phase 4: Templates & Default Data**
- Create 4-5 default templates
- Template loader service
- Upload to Firestore templates collection

**Phase 5: Audio & Notification Services**
- AudioService (background playback)
- NotificationService (schedule alerts)
- BackgroundService (alternative to WorkManager)

**Phase 6: State Management (Providers)**
- AuthProvider
- TimetableProvider
- CurrentActivityProvider
- SettingsProvider
- SharingProvider

**Phases 7-13: UI Screens**
- Home (timetable list)
- Detail view
- Create/edit
- Share/import
- Settings
- Alert dialogs

---

## ✅ Phase 3 Status: **COMPLETE**

All Firebase Auth and Sharing services are implemented!

Next: **Start Phase 4** (Templates) or **Phase 5** (Audio/Notifications) when ready 🚀
