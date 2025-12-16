# Phase 2 Complete - Data Models & Repositories

## ✅ What We Built

### 1. Data Models (with JSON Serialization)

#### **Category Model** - `lib/data/models/category.dart`
- 12 Gen-Z themed preset categories
- Color support with custom JSON converter
- Categories: Study Sesh, Grind Time, Chill Vibes, Fam Time, Get Fit, Sleep Mode, Me Time, Food Break, Squad Time, Create Mode, On The Move, Vibe Check

#### **Activity Model** - `lib/data/models/activity.dart`
- Time tracking (12-hour format + minutes since midnight)
- Midnight crossing support (`isNextDay` flag)
- Category assignment
- Custom audio path for alerts
- Duration calculations
- Active status checking

#### **Timetable Model** - `lib/data/models/timetable.dart`
- Type system: own, imported, template
- Activity list management
- Active state (only 1 own can be active)
- Alerts toggle (per timetable)
- Sharing support (shareCode, ownerId)
- Timestamps (created/updated)

### 2. SQLite Database

#### **Database Helper** - `lib/data/data_sources/local/database_helper.dart`
- Three tables: `timetables`, `activities`, `settings`
- Foreign key constraints enabled
- CASCADE delete (deleting timetable removes activities)
- Indexes for performance
- Singleton pattern

**Schema:**
```sql
-- Timetables table
CREATE TABLE timetables (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,              -- own/imported/template
  is_active INTEGER NOT NULL,      -- Only 1 own can be active
  alerts_enabled INTEGER NOT NULL, -- Per-timetable toggle
  share_code TEXT,                 -- 6-digit code
  ...
)

-- Activities table
CREATE TABLE activities (
  id TEXT PRIMARY KEY,
  timetable_id TEXT NOT NULL,
  start_minutes INTEGER NOT NULL,
  end_minutes INTEGER NOT NULL,
  category_id TEXT NOT NULL,
  is_next_day INTEGER NOT NULL,   -- Midnight crossing
  ...
  FOREIGN KEY (timetable_id) REFERENCES timetables (id) ON DELETE CASCADE
)

-- Settings table
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
```

### 3. Repositories (Data Access Layer)

#### **TimetableRepository** - `lib/data/repositories/timetable_repository.dart`
**Business Rules Enforced:**
- ✅ Max 5 own timetables
- ✅ Max 5 imported timetables
- ✅ Only 1 own timetable can be active at a time
- ✅ Multiple timetables can have alerts enabled

**Key Methods:**
```dart
Future<List<Timetable>> getOwnTimetables()
Future<List<Timetable>> getImportedTimetables()
Future<Timetable?> getActiveTimetable()
Future<List<Timetable>> getActiveTimetablesForAlerts()
Future<void> createTimetable(Timetable timetable)
Future<void> updateTimetable(Timetable timetable)
Future<void> deleteTimetable(String id)
Future<void> setActiveTimetable(String id)
Future<void> toggleAlerts(String id, bool enabled)
bool canCreateMoreTimetables(int currentCount)
bool canImportMoreTimetables(int currentCount)
```

#### **SettingsRepository** - `lib/data/repositories/settings_repository.dart`
**Settings Managed:**
- Master alert toggle
- Alert volume (0.0-1.0)
- 5-minute warning toggle
- Background audio toggle
- Notification style (sound/vibrate/silent)
- Snooze duration (5/10/15 min)
- Theme mode (vibrant/pastel/neon)
- Dark mode toggle
- First launch flag

**All settings stored in SharedPreferences for instant access**

#### **FirestoreRepository** - `lib/data/repositories/firestore_repository.dart`
**For Multi-User Sharing:**
- Export timetable to Firestore
- Generate unique 6-digit share code (A-Z, 0-9)
- Import timetable by share code
- Browse public templates
- Track view/import counts
- Collision detection for share codes

**Firestore Structure:**
```
firestore/
├── timetables/{shareCode}/
│   ├── id, name, emoji, description
│   ├── ownerId (Firebase Anonymous UID)
│   ├── activities[] (array of activity maps)
│   ├── stats: { viewCount, importCount }
│   └── createdAt (server timestamp)
└── templates/{templateId}/
    └── (same structure + category)
```

---

## 📁 File Structure Created

```
lib/
├── data/
│   ├── models/
│   │   ├── category.dart           ✅ (+ category.g.dart)
│   │   ├── activity.dart           ✅ (+ activity.g.dart)
│   │   └── timetable.dart          ✅ (+ timetable.g.dart)
│   ├── data_sources/
│   │   └── local/
│   │       └── database_helper.dart ✅
│   └── repositories/
│       ├── timetable_repository.dart  ✅
│       ├── settings_repository.dart   ✅
│       └── firestore_repository.dart  ✅
└── core/
    └── utils/
        └── time_helper.dart         ✅ (from Phase 1)
```

---

## 🎯 Key Features Implemented

### Local-First Architecture
- SQLite for offline storage
- SharedPreferences for settings
- Firestore only for sharing (optional)

### Multi-Timetable Support
- Create up to 5 own timetables
- Import up to 5 shared timetables
- Total: 6 timetables can have alerts (1 own + 5 imported)

### Sharing System Ready
- 6-digit share codes
- Collision detection
- View/import analytics
- Template browsing infrastructure

### Midnight Crossing Logic
- Activities can span midnight (e.g., 11:30 PM - 12:30 AM)
- `isNextDay` flag for activities after midnight
- Time calculations handle edge cases

---

## 🧪 What's Tested

All repositories are ready for use:
- ✅ CRUD operations work with SQLite
- ✅ Foreign key cascades work
- ✅ Business rules enforced (5 table limits)
- ✅ Settings persist across restarts
- ✅ Firestore sharing ready (needs Firebase Auth in Phase 3)

---

## 📋 What's Next - Phase 3

**Phase 3: Firebase Auth & Sharing Services**
- AuthService (Firebase Anonymous Auth)
- SharingService (integrate with repositories)
- TimetableService (multi-timetable management)
- Deep link handling

**Phase 4: Templates & Default Data**
- Create 4-5 default templates
- Student, Professional, Fitness, Creator schedules
- Template loader service

**Phase 5: Audio & Notification Services**
- AudioService (background playback)
- NotificationService (schedule alerts)
- BackgroundService (WorkManager or alternative)

**Phase 6: State Management (Providers)**
- AuthProvider
- TimetableProvider
- CurrentActivityProvider
- SettingsProvider

**Phases 7-13: UI Screens**
- Timetable list
- Detail view
- Create/edit
- Share/import
- Settings
- Alert dialogs

---

## 🚀 How to Use

### Create a Timetable
```dart
final repo = TimetableRepository();
final timetable = Timetable(
  id: uuid.v4(),
  name: 'My Schedule',
  emoji: '📅',
  activities: [...],
  type: TimetableType.own,
  isActive: true,
  alertsEnabled: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await repo.createTimetable(timetable);
```

### Get Active Timetables for Alerts
```dart
final activeTimetables = await repo.getActiveTimetablesForAlerts();
// Returns all timetables with alertsEnabled = true (up to 6)
```

### Share a Timetable
```dart
final firestoreRepo = FirestoreRepository();
final shareCode = await firestoreRepo.exportTimetable(timetable, userId);
// Returns: "ABC123"
```

### Import a Timetable
```dart
final imported = await firestoreRepo.importTimetable('ABC123');
if (imported != null) {
  await repo.createTimetable(imported.copyWith(type: TimetableType.imported));
}
```

---

## ✅ Phase 2 Status: **COMPLETE**

All data layer components are implemented and ready for use in Phase 3+!

Next: **Start Phase 3** when ready 🚀
