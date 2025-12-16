# Phase 8 Complete - Timetable List Screen (Home)

## ✅ What We Built

### 1. TimetableCard Widget

**File:** [lib/presentation/widgets/timetable/timetable_card.dart](lib/presentation/widgets/timetable/timetable_card.dart)

**Features:**
- ✅ Card layout for timetable display
- ✅ Emoji + name + description
- ✅ Active badge for active timetables
- ✅ Alert status indicator (bell icon)
- ✅ Activity count chip
- ✅ Type badge (Imported/Template)
- ✅ Options menu button
- ✅ Tap handling
- ✅ Compact variant for bottom sheets

**TimetableCard (Standard):**
```dart
TimetableCard(
  timetable: timetable,
  onTap: () => openDetail(timetable),
  onOptions: () => showOptions(timetable),
  showActiveBadge: true,
  showAlertStatus: true,
)
```

**Visual Elements:**
- **Header:** Emoji (32px) + Active badge + Alert icon + Options button
- **Name:** Poppins 18px bold (2 line max)
- **Description:** Inter 12px (2 line max, optional)
- **Stats:** Activity count chip + Type badge (if imported/template)

**Active Badge:**
- Star icon + "Active" text
- Primary color background (20% opacity)
- Only shown for own timetables

**Alert Status:**
- Bell icon (on/off state)
- Primary color if enabled, grey if disabled

**CompactTimetableCard:**
```dart
CompactTimetableCard(
  timetable: timetable,
  onTap: () {},
  isSelected: true,
)
```
- Horizontal layout (emoji + name + check)
- Used in bottom sheets and quick selectors
- Shows selected state with border and background

### 2. HomeScreen - Main App Screen

**File:** [lib/presentation/screens/home/home_screen.dart](lib/presentation/screens/home/home_screen.dart)

**Features:**
- ✅ Tab bar with 3 tabs (My Tables, Imported, Templates)
- ✅ AppBar with settings button
- ✅ Pull-to-refresh on all tabs
- ✅ Empty states with Gen-Z slang
- ✅ Loading states with shimmer
- ✅ Error states with retry
- ✅ Grid layout for cards (2 columns)
- ✅ Staggered fade-in animations
- ✅ Dynamic FAB based on tab

**App Structure:**
```
HomeScreen
├── AppBar
│   ├── Title ("TimeTable")
│   └── Settings icon
├── TabBar
│   ├── My Tables
│   ├── Imported
│   └── Templates
├── TabBarView
│   ├── _MyTablesTab
│   ├── _ImportedTab
│   └── _TemplatesTab
└── FAB (dynamic)
```

**Lifecycle:**
1. `initState`: Create TabController, load data on first frame
2. `_loadData`: Load timetables + templates + start activity tracking
3. `_onRefresh`: Refresh data on pull-down
4. `dispose`: Clean up TabController

**Tab Bar:**
- 3 tabs with Poppins font
- Bold when selected, normal when not
- Material 3 indicator

**Dynamic FAB:**
- **My Tables tab:** "New Table" button (if < 5 own)
- **Imported tab:** "Import" button (if < 5 imported)
- **Templates tab:** No FAB
- Uses `Consumer<TimetableProvider>` to check limits

### 3. My Tables Tab

**Class:** `_MyTablesTab`

**Features:**
- ✅ Grid of own timetables (2 columns)
- ✅ Pull-to-refresh
- ✅ Loading state ("Loading your vibes... 📅")
- ✅ Error state with retry
- ✅ Empty state ("No vibes here yet!")
- ✅ Staggered fade-in animations
- ✅ Options menu on card tap
- ✅ Detail view on card tap

**Grid Layout:**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
  ),
  itemCount: timetables.length,
  itemBuilder: (context, index) {
    return FadeInCard(
      delay: Duration(milliseconds: index * 100),
      child: TimetableCard(...),
    );
  },
)
```

**Empty State:**
- Icon: schedule
- Title: "No vibes here yet!"
- Subtitle: "Create your first schedule 🎯"
- Action: "New Table ✨" button

**Actions:**
- Tap card → Open detail view (TODO)
- Tap options → Show options bottom sheet

### 4. Imported Tab

**Class:** `_ImportedTab`

**Features:**
- ✅ Grid of imported timetables
- ✅ Same layout as My Tables
- ✅ No active badge (imported can't be active)
- ✅ Empty state ("Haven't imported any schedules yet")
- ✅ Different options menu (no edit, no share)

**Empty State:**
- Icon: cloud_download
- Title: "Haven't imported any schedules yet"
- Subtitle: "Check out templates or import via share code! 👀"
- Action: "Import Table" button

**Differences from My Tables:**
- `showActiveBadge: false` on cards
- Different options menu (duplicate instead of edit)

### 5. Templates Tab

**Class:** `_TemplatesTab`

**Features:**
- ✅ Grid of curated templates
- ✅ Pull-to-refresh
- ✅ Loading state ("Loading templates... 📋")
- ✅ Empty state ("No templates available")
- ✅ Preview on tap
- ✅ Import functionality

**Empty State:**
- Icon: library_books
- Title: "No templates available"
- Subtitle: "Check back later for curated schedules!"
- No action button

**Template Card:**
- `showActiveBadge: false`
- `showAlertStatus: false`
- Tap opens preview sheet

### 6. Options Menu Bottom Sheet

**Class:** `_TimetableOptionsSheet`

**Features:**
- ✅ Header with emoji + name + close button
- ✅ Different options for own vs imported
- ✅ Edit (own only)
- ✅ Set as Active (own only)
- ✅ Share (own only)
- ✅ Toggle Alerts (both)
- ✅ Duplicate to My Tables (imported only)
- ✅ Delete (both) with confirmation dialog
- ✅ Integrates with TimetableProvider

**Own Timetable Options:**
1. **Edit** → Navigate to edit screen (TODO)
2. **Active** → Star icon, shows "Active" if already active
3. **Share** → Navigate to share screen (TODO)
4. **Toggle Alerts** → Enable/disable notifications
5. **Delete** → Show confirmation dialog

**Imported Timetable Options:**
1. **Toggle Alerts** → Enable/disable notifications
2. **Duplicate to My Tables** → Create own copy
3. **Delete** → Show confirmation dialog

**Delete Confirmation:**
```dart
AlertDialog(
  title: 'Delete Timetable?',
  content: 'Are you sure you want to delete "{name}"? This cannot be undone.',
  actions: [Cancel, Delete],
)
```
- Uses `showDialog` with bool result
- Red color for delete button
- Calls `provider.deleteTimetable(id)`

### 7. Template Preview Bottom Sheet

**Class:** `_TemplatePreviewSheet`

**Features:**
- ✅ Draggable scrollable sheet
- ✅ Header with emoji + name + description
- ✅ List of activities with preview
- ✅ "Use This Template" button
- ✅ Import functionality with limit check
- ✅ Success feedback

**Layout:**
```
DraggableScrollableSheet (70% → 95%)
├── Handle (drag indicator)
├── Header
│   ├── Emoji (32px)
│   └── Name + Description
├── Activity List (scrollable)
│   └── ListTile per activity
│       ├── Icon
│       ├── Title
│       └── Time range
└── Import Button
```

**Import Flow:**
1. Check if can create more (< 5 own)
2. If full, show "You've hit the max (5 tables)" snackbar
3. Otherwise, call `provider.importTemplate(id)`
4. Show success snackbar: "Locked in! Template imported ✨"
5. Close sheet

### 8. Main.dart Integration

**File:** [lib/main.dart](lib/main.dart)

**Updated:**
```dart
import 'presentation/screens/home/home_screen.dart';

// In MaterialApp
home: const HomeScreen(),
```

**Old (Phase 7):**
- Placeholder scaffold with icon and text
- "Ready to go! 🚀"

**New (Phase 8):**
- Full home screen with tabs
- Loads data on init
- Starts activity tracking

---

## 📁 File Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   └── home/
│   │       └── home_screen.dart          ✅ NEW
│   └── widgets/
│       └── timetable/
│           └── timetable_card.dart       ✅ NEW
└── main.dart                              ✅ UPDATED
```

---

## 🎯 Use Cases Implemented

### Use Case 1: First App Launch

**Flow:**
1. App launches → `main()` runs
2. Firebase initializes
3. Dependency injection setup
4. Auto sign-in anonymously
5. Background service starts
6. MultiProvider creates providers
7. HomeScreen renders
8. `_loadData()` runs on first frame:
   - Loads timetables (empty)
   - Loads templates (from local JSON)
   - Starts activity tracking (if any alerts enabled)
9. Shows empty state: "No vibes here yet!"
10. FAB shows "New Table" button

**User sees:**
- Home screen with 3 tabs
- My Tables tab (active)
- Empty state with friendly message
- FAB to create first timetable

### Use Case 2: Create First Timetable

**Flow:**
1. User taps "New Table ✨" button
2. TODO: Navigate to create screen (Phase 10)
3. User fills out timetable details
4. User adds activities
5. Taps "Save & Activate"
6. Returns to home screen
7. Grid shows 1 timetable card
8. Card has active badge + alert icon

**Card shows:**
- Emoji + name
- "Active" badge (star icon)
- Bell icon (alerts on)
- "5 activities" chip
- Options button

### Use Case 3: Browse Templates

**Flow:**
1. User taps "Templates" tab
2. Grid shows curated templates
3. User taps a template card
4. Bottom sheet slides up
5. Shows template details + activity list
6. User scrolls to see all activities
7. Taps "Use This Template"
8. Provider imports template
9. Sheet closes
10. Snackbar: "Locked in! Template imported ✨"
11. Switches to "My Tables" tab
12. Shows new timetable

### Use Case 4: Manage Timetable Options

**Flow:**
1. User taps options button on card
2. Bottom sheet appears
3. User sees options:
   - Edit
   - Set as Active (if not active)
   - Share
   - Toggle Alerts
   - Delete
4. User taps "Set as Active"
5. Provider updates state
6. Sheet closes
7. Card updates to show active badge

### Use Case 5: Delete Timetable

**Flow:**
1. User taps options → Delete
2. Confirmation dialog appears
3. "Are you sure you want to delete '{name}'?"
4. User taps "Delete"
5. Dialog closes
6. Provider deletes timetable
7. Card fades out (auto rebuild)
8. If last timetable, shows empty state

### Use Case 6: Pull to Refresh

**Flow:**
1. User pulls down on any tab
2. Refresh indicator appears
3. `_onRefresh()` called
4. Reloads timetables + templates
5. Refreshes activity tracking
6. Indicator hides
7. Cards update (if changes)

### Use Case 7: Import Timetable

**Flow:**
1. User switches to "Imported" tab
2. Empty state: "Haven't imported any schedules yet"
3. Taps "Import Table" button
4. TODO: Navigate to import screen (Phase 11)
5. Enters share code or scans QR
6. Returns to home
7. Imported tab shows new timetable
8. Card has "Imported" badge
9. No active badge (imported can't be active)

### Use Case 8: Hit Timetable Limit

**Flow:**
1. User has 5 own timetables
2. FAB disappears (can't create more)
3. User tries to import template
4. Snackbar: "You've hit the max (5 tables). Delete one first 📊"
5. User deletes a timetable
6. FAB reappears
7. Can now create/import again

---

## 🎨 Gen-Z Aesthetic Applied

**Slang Used:**
- ✅ "No vibes here yet!" (empty state)
- ✅ "New Table ✨" (create button)
- ✅ "Locked in!" (success message)
- ✅ "Loading your vibes... 📅" (loading)
- ✅ "You've hit the max" (limit reached)
- ✅ "Haven't imported any schedules yet. Check out templates! 👀"

**Visual Design:**
- ✅ Vibrant colors (theme-based)
- ✅ Rounded corners (16px cards, 8px chips)
- ✅ Emojis throughout (32px in cards, 24px in compact)
- ✅ Smooth animations (staggered fade-in)
- ✅ Modern Material 3 components
- ✅ Grid layout (not list) for visual interest
- ✅ Glassmorphic bottom sheets

**Animations:**
- ✅ Staggered fade-in (100ms delay per card)
- ✅ Slide from bottom (20px distance)
- ✅ Smooth transitions (400ms duration)
- ✅ Ease-out curve

---

## 🧪 What's Ready

All home screen functionality is implemented:
- ✅ 3 tabs (My Tables, Imported, Templates)
- ✅ Grid layout with cards
- ✅ Pull-to-refresh
- ✅ Empty states
- ✅ Loading states
- ✅ Error states
- ✅ Options menu
- ✅ Template preview
- ✅ Delete confirmation
- ✅ Dynamic FAB
- ✅ Gen-Z slang integration
- ✅ Staggered animations
- ✅ Provider integration

---

## 📋 What's Next

**Phase 9: UI - Timetable Detail Screen**
- View timetable details
- Current activity banner (if alerts enabled)
- Timeline view with activity cards
- "NOW" badge on current activity
- Progress bar
- Category stats
- Edit FAB
- Duplicate button (for imported)

**Phases 10-13: Remaining Screens**
- Create/edit timetable (Phase 10)
- Share/import screens (Phase 11)
- Settings screen (Phase 12)
- Activity alert dialogs (Phase 13)

---

## ✅ Phase 8 Status: **COMPLETE**

The home screen is fully functional and integrated with providers!

**What You Can Do Now:**
1. Launch app → See home screen with tabs
2. Switch between tabs
3. View empty states (no data yet)
4. Pull to refresh
5. Tap templates to preview
6. FAB appears/disappears based on limits

**What's Not Working Yet:**
- Create timetable (navigation TODO)
- Edit timetable (navigation TODO)
- Share timetable (navigation TODO)
- Import timetable (navigation TODO)
- View timetable detail (navigation TODO)
- Settings screen (navigation TODO)

These will be implemented in Phases 9-12.

Next: **Start Phase 9** (Timetable Detail Screen) when ready 🚀

---

## 📝 Technical Notes

### State Management Integration

**Providers Used:**
- `TimetableProvider` - Load/manage timetables
- `SharingProvider` - Load/import templates
- `CurrentActivityProvider` - Start activity tracking

**Consumer Pattern:**
```dart
Consumer<TimetableProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingIndicator();
    if (provider.error != null) return ErrorState();
    return GridView(...);
  },
)
```

**Benefits:**
- Automatic rebuilds when data changes
- Clean separation of UI and logic
- No manual state management

### Data Loading Strategy

**Initial Load:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _loadData();
});
```
- Runs after first frame painted
- Prevents blocking UI
- Async operation

**Load Sequence:**
1. Load own timetables
2. Load imported timetables
3. Load templates
4. Get alert-enabled timetables
5. Start activity tracking

**Why This Order:**
- Timetables must load before tracking
- Templates can load in parallel
- Activity tracking starts with real data

### Grid Layout Calculations

**GridView Settings:**
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,           // 2 columns
  childAspectRatio: 0.85,     // Width:Height ratio
  crossAxisSpacing: 0,        // No extra spacing (cards have margin)
  mainAxisSpacing: 0,         // No extra spacing
)
```

**Card Sizing:**
- Screen width: 100%
- Column width: 50%
- Card width: 50% - 16px (8px margin × 2)
- Card height: Card width ÷ 0.85 ≈ 1.18× width

**Result:**
- Vertical cards
- Good for content (emoji, name, description, stats)
- Fits 2 per row on most phones

### Animation Performance

**Staggered Delays:**
```dart
FadeInCard(
  delay: Duration(milliseconds: index * 100),
  child: TimetableCard(...),
)
```

**Performance:**
- Each card delays by 100ms
- Max 5 cards = 500ms total
- Smooth waterfall effect
- No jank (uses AnimationController)

**Why It Works:**
- Separate animation per card
- No rebuilds during animation
- GPU-accelerated (opacity + transform)

### Bottom Sheet Best Practices

**Modal Bottom Sheet:**
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => OptionsSheet(),
)
```
- Blocks background interaction
- Dismisses on outside tap
- Returns Future<T?>

**Draggable Scrollable Sheet:**
```dart
DraggableScrollableSheet(
  initialChildSize: 0.7,  // 70% screen height
  minChildSize: 0.5,      // Can drag to 50%
  maxChildSize: 0.95,     // Can drag to 95%
)
```
- Swipe to resize
- Scroll when full
- Smooth drag animation

### Empty State Best Practices

**Applied:**
- ✅ Friendly, non-technical language
- ✅ Gen-Z slang (but not overdone)
- ✅ Clear call-to-action
- ✅ Icon matches context
- ✅ Encourages next step

**Examples:**
- "No vibes here yet!" (friendly)
- "Create your first schedule 🎯" (actionable)
- "Haven't imported any schedules yet" (conversational)
- "Check out templates! 👀" (suggestive)

### Pull-to-Refresh Implementation

**RefreshIndicator:**
```dart
RefreshIndicator(
  onRefresh: _onRefresh,  // Must return Future<void>
  child: GridView(...),
)
```

**Async Refresh:**
```dart
Future<void> _onRefresh() async {
  await _loadData();  // Wait for completion
}
```

**UX:**
- Shows Material spinner
- Blocks interaction during refresh
- Auto-hides when complete
- Works with scrollable widgets

### Dynamic FAB Logic

**Tab-Based Display:**
```dart
final currentTab = _tabController.index;

if (currentTab == 0 && provider.canCreateMore) {
  return FloatingActionButton.extended(...);
} else if (currentTab == 1 && provider.canImportMore) {
  return FloatingActionButton.extended(...);
}

return const SizedBox.shrink();
```

**Benefits:**
- No FAB clutter when not needed
- Contextual actions per tab
- Enforces business rules (max 5)

### Delete Confirmation Pattern

**Best Practice:**
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(...),
);

if (confirmed == true && context.mounted) {
  await provider.deleteTimetable(id);
}
```

**Why `context.mounted` Check:**
- Dialog is async
- Widget may unmount during operation
- Prevents "mounted" error

### Navigation TODOs

**Why Placeholders:**
- Phase 8 focuses on home screen
- Other screens built in later phases
- Navigation wired up progressively

**Will Be Implemented In:**
- Phase 9: Detail view navigation
- Phase 10: Create/edit navigation
- Phase 11: Share/import navigation
- Phase 12: Settings navigation

---

## 🔧 Testing Checklist

### Visual Tests (Manual)

- [ ] App launches to home screen
- [ ] Tab bar shows 3 tabs
- [ ] Active tab is bold
- [ ] Settings icon in app bar
- [ ] Empty state shows in My Tables
- [ ] "New Table ✨" FAB appears
- [ ] Switch to Imported tab → Empty state
- [ ] Switch to Templates tab → Templates load
- [ ] Template cards display correctly
- [ ] Pull to refresh works on all tabs
- [ ] Tap template → Preview sheet opens
- [ ] Preview sheet is draggable
- [ ] Activities list scrolls in preview
- [ ] "Use This Template" button works
- [ ] Snackbar shows on import
- [ ] Imported timetable appears in grid

### Interaction Tests

- [ ] Tap card → Opens detail (TODO placeholder)
- [ ] Tap options → Bottom sheet appears
- [ ] Options sheet has correct buttons
- [ ] Set as Active works
- [ ] Toggle Alerts works
- [ ] Delete shows confirmation
- [ ] Cancel delete works
- [ ] Confirm delete removes card
- [ ] FAB disappears at 5 timetables
- [ ] Import blocked at 5 timetables
- [ ] Snackbar shows limit message

### Animation Tests

- [ ] Cards fade in on load
- [ ] Stagger delay is visible
- [ ] Smooth fade + slide animation
- [ ] Bottom sheet slides up smoothly
- [ ] Draggable sheet resizes smoothly
- [ ] Pull-to-refresh spinner appears
- [ ] No jank or stuttering

### Provider Integration Tests

- [ ] TimetableProvider loads on init
- [ ] SharingProvider loads templates
- [ ] CurrentActivityProvider starts tracking
- [ ] Consumer rebuilds on data change
- [ ] Error state shows on failure
- [ ] Loading state shows during fetch
- [ ] Empty state shows when no data

### Edge Cases

- [ ] No internet → Error state
- [ ] Firebase down → Error state
- [ ] Retry button reloads data
- [ ] Quick tab switches don't crash
- [ ] Rapid refresh doesn't duplicate calls
- [ ] Template import during load works
- [ ] Delete during load doesn't crash
- [ ] Context unmount doesn't error

---

## 💡 Tips for Phase 9

**Detail Screen Should Have:**
1. App bar with timetable name + emoji
2. Back button
3. Share icon (if own timetable)
4. Current activity banner (if alerts enabled)
   - Pulsing dot + "NOW" badge
   - Countdown timer
   - Progress bar
5. Timeline view with activity cards
   - Time + icon + title
   - "NOW" badge on current
   - Tap to expand
6. Edit FAB (if own)
7. Duplicate FAB (if imported)

**Use These Widgets:**
- `PulseDotLabel` for "NOW" badge
- `AppCard` for activity cards
- `FadeInCard` for entrance animation
- `LoadingIndicator` for loading state
- `EmptyState` if no activities

**Navigation:**
```dart
// From home screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TimetableDetailScreen(
      timetableId: timetable.id,
    ),
  ),
);

// In detail screen
final timetable = context.watch<TimetableProvider>()
  .getTimetableById(widget.timetableId);
```

---

**Phase 8 Complete! 🏠✨**

The home screen is the main navigation hub and it's fully functional. Users can browse their timetables, templates, and imported schedules with a clean, modern, Gen-Z aesthetic.
