# Phase 7 Complete - Theme & Common Widgets

## ✅ What We Built

### 1. AppColors - Gen-Z Color System

**File:** [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart)

**Features:**
- ✅ Three complete theme modes (Vibrant, Pastel, Neon)
- ✅ Dynamic primary, secondary, and accent colors per theme
- ✅ Category-specific colors for 12 activity types
- ✅ Gradient definitions for each theme
- ✅ Light and dark mode color schemes
- ✅ Helper methods to get colors by theme mode

**Theme Modes:**

**Vibrant (Default):**
- Primary: Purple (#9C27B0)
- Secondary: Pink (#E91E63)
- Accent: Cyan (#00BCD4)
- Gradient: Purple → Pink
- Bold, high-saturation colors

**Pastel:**
- Primary: Soft Purple (#CE93D8)
- Secondary: Soft Pink (#F48FB1)
- Accent: Soft Cyan (#80DEEA)
- Gradient: Soft Purple → Soft Pink
- Gentle, low-saturation colors

**Neon:**
- Primary: Electric Purple (#D500F9)
- Secondary: Hot Pink (#FF4081)
- Accent: Bright Cyan (#00E5FF)
- Gradient: Electric Purple → Hot Pink
- Maximum saturation, glowing aesthetic

**Category Colors:**
```dart
study: Purple (#9C27B0)
work: Blue (#2196F3)
chill: Green (#4CAF50)
family: Pink (#E91E63)
fitness: Orange (#FF9800)
sleep: Indigo (#3F51B5)
personal: Teal (#009688)
health: Red (#F44336)
creative: Deep Orange (#FF5722)
social: Light Blue (#03A9F4)
learning: Deep Purple (#673AB7)
other: Blue Grey (#607D8B)
```

**Key Methods:**
```dart
Color getPrimaryColor(String themeMode)      // Get primary by theme
Color getSecondaryColor(String themeMode)    // Get secondary by theme
Color getAccentColor(String themeMode)       // Get accent by theme
LinearGradient getGradient1(String themeMode) // Get gradient by theme
Color getCategoryColor(String categoryId)    // Get category color
```

### 2. AppTheme - Material 3 Theme

**File:** [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)

**Features:**
- ✅ Material 3 design system
- ✅ Google Fonts integration (Poppins + Inter)
- ✅ Complete light and dark themes
- ✅ Dynamic theme based on user settings
- ✅ Comprehensive widget theming

**Theme Configuration:**
- **Brightness:** Light/Dark mode support
- **Color Scheme:** Dynamic based on theme mode
- **Typography:** Poppins for headings, Inter for body text
- **Shapes:** Rounded corners (16px cards, 12px buttons)
- **Elevation:** Modern Material 3 elevation system

**Widget Themes:**
- ✅ AppBar (elevated, centered title)
- ✅ Card (rounded, elevated)
- ✅ ElevatedButton (rounded, no elevation in light)
- ✅ TextButton (rounded)
- ✅ OutlinedButton (rounded, 2px border)
- ✅ FloatingActionButton (rounded)
- ✅ InputDecoration (filled, rounded)
- ✅ Chip (rounded)
- ✅ BottomNavigationBar (fixed, elevated)
- ✅ Divider (thin, subtle)

**Typography Scale:**
```dart
// Display (large, prominent)
displayLarge: 57px, bold
displayMedium: 45px, bold
displaySmall: 36px, bold

// Headline (section headers)
headlineLarge: 32px, w600
headlineMedium: 28px, w600
headlineSmall: 24px, w600

// Title (card titles)
titleLarge: 22px, w500
titleMedium: 16px, w500
titleSmall: 14px, w500

// Body (main content)
bodyLarge: 16px, normal
bodyMedium: 14px, normal
bodySmall: 12px, normal

// Label (buttons, tabs)
labelLarge: 14px, w600
labelMedium: 12px, w600
labelSmall: 11px, w600
```

**Key Methods:**
```dart
static ThemeData getLightTheme(String themeMode)  // Get light theme
static ThemeData getDarkTheme(String themeMode)   // Get dark theme
```

### 3. AppButton - Reusable Button Widget

**File:** [lib/presentation/widgets/common/app_button.dart](lib/presentation/widgets/common/app_button.dart)

**Features:**
- ✅ Three button styles (Primary, Secondary, Text)
- ✅ Optional icon support
- ✅ Loading state with spinner
- ✅ Enabled/disabled state
- ✅ Consistent Gen-Z styling

**Button Styles:**

**Primary:**
```dart
AppButton.primary(
  text: 'Save',
  icon: Icons.check,
  onPressed: () {},
)
```
- Filled with theme primary color
- White text
- Rounded corners (12px)
- Padding: 24h × 16v

**Secondary:**
```dart
AppButton.secondary(
  text: 'Cancel',
  onPressed: () {},
)
```
- Outlined with theme primary color
- Primary color text
- 2px border
- Same padding

**Text:**
```dart
AppButton.text(
  text: 'Learn More',
  onPressed: () {},
)
```
- No background
- Primary color text
- Minimal padding: 16h × 12v

**Loading State:**
```dart
AppButton.primary(
  text: 'Saving...',
  isLoading: true,
  onPressed: () {}, // Disabled while loading
)
```
- Shows circular progress indicator
- Disables button automatically
- Matches text color

### 4. AppCard - Reusable Card Widget

**File:** [lib/presentation/widgets/common/app_card.dart](lib/presentation/widgets/common/app_card.dart)

**Features:**
- ✅ Standard card with Material theme
- ✅ Gradient card support
- ✅ Glass morphism card variant
- ✅ Tap handling with InkWell
- ✅ Customizable padding, margin, elevation

**Card Variants:**

**Standard Card:**
```dart
AppCard(
  child: Text('Content'),
  onTap: () {},
  padding: EdgeInsets.all(16),
)
```
- Uses theme card color
- Rounded corners (16px)
- Elevation from theme
- Ripple effect on tap

**Gradient Card:**
```dart
AppCard.gradient(
  gradient: AppColors.vibrantGradient1,
  child: Text('Content'),
)
```
- Custom gradient background
- Transparent material layer
- Maintains ripple effect

**Glass Card:**
```dart
GlassCard(
  child: Text('Content'),
  blur: 10,
  opacity: 0.1,
)
```
- Frosted glass effect (backdrop blur)
- Semi-transparent background
- Border with subtle color
- Gen-Z glassmorphism aesthetic

### 5. LoadingIndicator - Loading & Empty States

**File:** [lib/presentation/widgets/common/loading_indicator.dart](lib/presentation/widgets/common/loading_indicator.dart)

**Features:**
- ✅ Circular progress indicator with sizes
- ✅ Optional loading text
- ✅ Full-screen loading overlay
- ✅ Empty state widget
- ✅ Error state widget with retry

**Loading Sizes:**

**Small (24px):**
```dart
LoadingIndicator.small()
```

**Medium (40px, default):**
```dart
LoadingIndicator.medium(
  text: 'Loading timetables...',
)
```

**Large (60px):**
```dart
LoadingIndicator.large()
```

**Loading Overlay:**
```dart
LoadingOverlay(
  isLoading: isLoading,
  text: 'Saving...',
  child: YourContent(),
)
```
- Full-screen black overlay (50% opacity)
- Centers loading indicator
- Blocks interaction while loading

**Empty State:**
```dart
EmptyState(
  icon: Icons.schedule,
  title: 'No vibes here yet!',
  subtitle: 'Create your first schedule 🎯',
  action: AppButton.primary(
    text: 'Create',
    onPressed: () {},
  ),
)
```
- Large icon (80px)
- Title + subtitle
- Optional action button
- Gen-Z slang support

**Error State:**
```dart
ErrorState(
  message: 'Connection not vibing rn. Check your internet? 📡',
  onRetry: () {},
)
```
- Error icon (80px)
- User-friendly message
- Optional retry button
- Gen-Z error messages

### 6. PulseDot - Animated Current Activity Indicator

**File:** [lib/presentation/widgets/animated/pulse_dot.dart](lib/presentation/widgets/animated/pulse_dot.dart)

**Features:**
- ✅ Smooth pulsing animation (opacity + glow)
- ✅ Customizable size, color, duration
- ✅ Combines with text for "NOW" badge
- ✅ Gen-Z vibrant aesthetic

**Usage:**

**Standalone Dot:**
```dart
PulseDot(
  size: 12,
  color: Colors.red,
  duration: Duration(milliseconds: 1000),
)
```
- Pulses between 60% and 100% opacity
- Glowing shadow effect
- Smooth ease-in-out curve

**With Label:**
```dart
PulseDotLabel(
  text: 'NOW',
  dotSize: 8,
  dotColor: Colors.red,
)
```
- Dot + text in a row
- Consistent spacing (6px gap)
- Matches text color to dot

**Animation Details:**
- Duration: 1 second (default)
- Repeats infinitely
- Opacity: 0.6 → 1.0 → 0.6
- Shadow: Pulsing glow effect

### 7. FadeInCard - Entrance Animation

**File:** [lib/presentation/widgets/animated/fade_in_card.dart](lib/presentation/widgets/animated/fade_in_card.dart)

**Features:**
- ✅ Fade-in animation
- ✅ Optional slide animation (bottom/side)
- ✅ Configurable delay for staggering
- ✅ Staggered list variant

**Usage:**

**Single Card:**
```dart
FadeInCard(
  duration: Duration(milliseconds: 400),
  delay: Duration(milliseconds: 200),
  slideFromBottom: true,
  slideDistance: 20,
  child: TimetableCard(),
)
```
- Fades from 0% to 100% opacity
- Slides from offset to final position
- Smooth ease-out curve

**Staggered List:**
```dart
StaggeredFadeInList(
  children: [
    TimetableCard1(),
    TimetableCard2(),
    TimetableCard3(),
  ],
  itemDuration: Duration(milliseconds: 400),
  staggerDelay: Duration(milliseconds: 100),
)
```
- Each item delays by 100ms
- Creates waterfall effect
- Smooth, professional entrance

**Animation Parameters:**
- Duration: 400ms (default)
- Curve: Ease-out
- Slide distance: 20px (default)
- Direction: Bottom (default) or horizontal

### 8. ShimmerPlaceholder - Loading Skeleton

**File:** [lib/presentation/widgets/animated/shimmer_placeholder.dart](lib/presentation/widgets/animated/shimmer_placeholder.dart)

**Features:**
- ✅ Smooth shimmer animation (gradient sweep)
- ✅ Multiple shape variants (rectangular, circular)
- ✅ Pre-built card and list skeletons
- ✅ Auto-adapts to light/dark theme

**Usage:**

**Rectangular:**
```dart
ShimmerPlaceholder.rounded(
  width: 200,
  height: 16,
  radius: 8,
)
```
- Rounded corners
- Horizontal gradient sweep
- 1.5 second animation loop

**Circular:**
```dart
ShimmerPlaceholder.circular(
  size: 48,
)
```
- Perfect circle
- For avatars, icons
- Same shimmer effect

**Card Skeleton:**
```dart
CardShimmerPlaceholder()
```
- Pre-built timetable card skeleton
- Avatar + title + subtitle
- Body text lines
- Matches AppCard layout

**List Skeleton:**
```dart
ListShimmerPlaceholder(
  itemCount: 3,
)
```
- Multiple list item skeletons
- Avatar + two text lines
- Used while loading lists

**Animation Details:**
- Duration: 1.5 seconds
- Direction: Left to right
- Colors: Auto-adapts to theme
  - Light: Grey 300 → Grey 100
  - Dark: Grey 800 → Grey 700

---

## 📁 File Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart             ✅ NEW
│       └── app_theme.dart              ✅ NEW
├── presentation/
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart         ✅ NEW
│       │   ├── app_card.dart           ✅ NEW
│       │   └── loading_indicator.dart  ✅ NEW
│       └── animated/
│           ├── pulse_dot.dart          ✅ NEW
│           ├── fade_in_card.dart       ✅ NEW
│           └── shimmer_placeholder.dart ✅ NEW
└── main.dart                            ✅ UPDATED
```

---

## 🎨 Design System Summary

### Color Palette

**Vibrant (Default):**
- High saturation
- Bold, energetic
- Purple/Pink/Cyan

**Pastel:**
- Low saturation
- Soft, calming
- Gentle tones

**Neon:**
- Maximum saturation
- Electric, glowing
- Intense vibes

### Typography

**Headings:** Poppins (modern, rounded)
**Body:** Inter (clean, readable)
**Weights:** 400 (normal), 500 (medium), 600 (semi-bold), bold

### Spacing

- Small: 8px
- Medium: 16px
- Large: 24px
- Extra Large: 32px

### Border Radius

- Small: 8px (chips)
- Medium: 12px (buttons, inputs)
- Large: 16px (cards)

### Elevation

- Light mode cards: 2dp
- Dark mode cards: 4dp
- FAB light: 4dp
- FAB dark: 6dp
- Bottom nav: 8dp

---

## 🎯 Use Cases Implemented

### Use Case 1: Themed App with Settings

```dart
// In main.dart
Consumer<SettingsProvider>(
  builder: (context, settings, _) {
    return MaterialApp(
      theme: AppTheme.getLightTheme(settings.themeMode),
      darkTheme: AppTheme.getDarkTheme(settings.themeMode),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(),
    );
  },
)
```

**What This Does:**
- App theme updates when user changes settings
- Supports vibrant/pastel/neon modes
- Light/dark mode switching
- All widgets automatically use new theme

### Use Case 2: Consistent Buttons

```dart
// Primary action
AppButton.primary(
  text: 'Lock it in ✨',
  icon: Icons.check,
  onPressed: () => saveTimetable(),
)

// Secondary action
AppButton.secondary(
  text: 'Nah, go back',
  onPressed: () => Navigator.pop(context),
)

// Loading state
AppButton.primary(
  text: 'Saving...',
  isLoading: isCreatingTimetable,
  onPressed: () {},
)
```

**Benefits:**
- Consistent styling across app
- Loading states handled automatically
- Gen-Z slang for friendly UX

### Use Case 3: Card Layouts

```dart
// Standard card
AppCard(
  child: Column(
    children: [
      Text(timetable.name),
      Text('${timetable.activities.length} activities'),
    ],
  ),
  onTap: () => openTimetable(timetable),
)

// Gradient card for featured content
AppCard.gradient(
  gradient: AppColors.vibrantGradient1,
  child: FeaturedTimetableContent(),
)

// Glass card for overlays
GlassCard(
  child: CurrentActivityWidget(),
)
```

**Benefits:**
- Consistent card styling
- Visual hierarchy with gradients
- Modern glassmorphism for overlays

### Use Case 4: Loading States

```dart
// While loading data
if (isLoading) {
  return LoadingIndicator.medium(
    text: 'Fetching the vibe... 📥',
  );
}

// Full-screen overlay
LoadingOverlay(
  isLoading: isSaving,
  text: 'Locking it in... 💾',
  child: TimetableForm(),
)

// List skeleton
if (isLoadingTimetables) {
  return ListShimmerPlaceholder(itemCount: 3);
}
```

**Benefits:**
- Professional loading UX
- Gen-Z slang for friendly feedback
- Skeleton screens prevent layout shift

### Use Case 5: Empty & Error States

```dart
// No timetables yet
if (timetables.isEmpty) {
  return EmptyState(
    icon: Icons.schedule,
    title: 'No vibes here yet!',
    subtitle: 'Create your first schedule 🎯',
    action: AppButton.primary(
      text: 'New Table ✨',
      onPressed: () => createTimetable(),
    ),
  );
}

// Network error
if (hasError) {
  return ErrorState(
    message: 'Connection not vibing rn. Check your internet? 📡',
    onRetry: () => retryFetch(),
  );
}
```

**Benefits:**
- Friendly, non-technical language
- Clear call-to-action
- Retry functionality for errors

### Use Case 6: Animated Entrances

```dart
// Single card fade-in
FadeInCard(
  delay: Duration(milliseconds: 200),
  child: TimetableCard(),
)

// Staggered list
StaggeredFadeInList(
  children: timetables.map((t) => TimetableCard(t)).toList(),
  staggerDelay: Duration(milliseconds: 100),
)
```

**Benefits:**
- Smooth, professional entrance
- Draws attention to new content
- Gen-Z aesthetic with motion

### Use Case 7: Current Activity Indicator

```dart
// Pulsing "NOW" badge
if (isCurrentActivity) {
  return PulseDotLabel(
    text: 'NOW',
    dotColor: theme.colorScheme.error,
  );
}

// Custom pulse indicator
PulseDot(
  size: 16,
  color: Colors.green,
)
```

**Benefits:**
- Eye-catching current activity marker
- Vibrant, Gen-Z aesthetic
- Smooth animation

---

## 🧪 What's Ready

All theme and widget foundations are implemented:
- ✅ 3 complete theme modes (vibrant, pastel, neon)
- ✅ Material 3 design system
- ✅ Google Fonts integration
- ✅ 3 common widgets (button, card, loading)
- ✅ 3 animated widgets (pulse, fade-in, shimmer)
- ✅ Light and dark mode support
- ✅ Theme reactive to settings changes
- ✅ Gen-Z aesthetic throughout

---

## 📋 What's Next

**Phase 8: UI - Timetable List Screen (Home)**
- Home screen with tab bar (My Tables | Imported | Templates)
- Timetable card grid
- Active timetable indicator
- Alert status badges
- Options menu (Edit, Share, Delete, etc.)
- FAB for create/import
- Empty states with Gen-Z slang
- Pull-to-refresh
- Bottom bar for quick access

**Phases 9-13: Remaining UI Screens**
- Timetable detail view (Phase 9)
- Create/edit timetable (Phase 10)
- Share/import screens (Phase 11)
- Settings screen (Phase 12)
- Activity alert dialogs (Phase 13)

---

## ✅ Phase 7 Status: **COMPLETE**

All theme and widget foundations are ready for UI implementation!

**What You Can Do Now:**
```dart
// Use theme in app
MaterialApp(
  theme: AppTheme.getLightTheme('vibrant'),
  darkTheme: AppTheme.getDarkTheme('vibrant'),
)

// Use common widgets
AppButton.primary(text: 'Save', onPressed: () {})
AppCard(child: YourContent())
LoadingIndicator.medium(text: 'Loading...')
EmptyState(icon: Icons.schedule, title: 'No data')

// Use animated widgets
PulseDotLabel(text: 'NOW')
FadeInCard(child: YourCard())
ShimmerPlaceholder.rounded(width: 200, height: 16)
```

Next: **Start Phase 8** (Timetable List Screen) when ready 🚀

---

## 📝 Technical Notes

### Material 3 Migration

**Deprecated Properties Removed:**
- `background` / `onBackground` in ColorScheme (use `surface` / `onSurface`)
- Used `scaffoldBackgroundColor` directly instead

**Fixed Property Names:**
- `CardTheme` → `CardThemeData`
- `bottomNavigationBarThemeData` → `bottomNavigationBarTheme`

### Google Fonts Integration

**Fonts Used:**
- **Poppins:** Headings, titles, labels (modern, rounded)
- **Inter:** Body text, descriptions (clean, readable)

**Why These Fonts:**
- Popular in Gen-Z apps
- Excellent web/mobile rendering
- Support for all weights
- Professional yet playful

### Color Opacity Updates

**Old (Deprecated):**
```dart
Colors.white.withOpacity(0.1)
```

**New (Material 3):**
```dart
Colors.white.withValues(alpha: 0.1)
```

**Applied In:**
- GlassCard backdrop blur
- Loading overlay
- Shimmer placeholders

### Animation Performance

**Best Practices Applied:**
- `SingleTickerProviderStateMixin` for single animations
- Proper disposal of controllers
- Efficient AnimatedBuilder usage
- No unnecessary rebuilds

**Animation Curves:**
- `Curves.easeInOut` for pulsing
- `Curves.easeOut` for entrances
- Smooth, professional motion

### Theme Reactivity

**How It Works:**
1. User changes theme in SettingsProvider
2. `themeMode` property updates
3. Consumer<SettingsProvider> rebuilds MaterialApp
4. `AppTheme.getLightTheme(themeMode)` called with new mode
5. Entire app re-themes instantly

**No Manual Refresh Needed:**
- Provider handles reactivity
- All widgets use `Theme.of(context)`
- Automatic color scheme updates

### Accessibility Considerations

**Color Contrast:**
- All text colors meet WCAG AA standards
- High contrast in dark mode
- Readable on all backgrounds

**Text Sizes:**
- Minimum 12px (labelSmall)
- Body text: 14-16px
- Headings: 22px+

**Touch Targets:**
- Buttons: 48px minimum height
- Cards: Full width, 16px padding
- FAB: 56px (Material standard)

### Performance Optimizations

**Shimmer Animation:**
- Reuses single AnimationController
- Efficient gradient computation
- No layout recalculations

**Card Rendering:**
- InkWell for ripple (Material layer)
- ClipRRect only when needed
- Minimal rebuilds

**Loading States:**
- Shimmer placeholders prevent layout shift
- Skeleton screens improve perceived performance
- Smooth transitions between states

---

## 🎨 Gen-Z Aesthetic Checklist

- ✅ Bold, vibrant colors (primary palette)
- ✅ Soft, pastel option (secondary palette)
- ✅ Neon, glowing option (tertiary palette)
- ✅ Smooth animations (pulse, fade, shimmer)
- ✅ Rounded corners everywhere (8-16px)
- ✅ Glassmorphism support (GlassCard)
- ✅ Gradient support (AppCard.gradient)
- ✅ Modern fonts (Poppins + Inter)
- ✅ Emojis in UI text (supported)
- ✅ Gen-Z slang integration (EmptyState, ErrorState)
- ✅ Playful interactions (ripple, pulse, glow)
- ✅ Material 3 principles (elevation, color roles)

---

## 💡 Tips for Using the Design System

**1. Always Use Theme Colors:**
```dart
// Good
color: Theme.of(context).colorScheme.primary

// Bad
color: Colors.purple
```

**2. Use Semantic Text Styles:**
```dart
// Good
style: Theme.of(context).textTheme.headlineMedium

// Bad
style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)
```

**3. Leverage Widget Variants:**
```dart
// Use constructors for clarity
AppButton.primary()    // Clear intent
AppButton.secondary()  // Clear intent
```

**4. Combine Widgets:**
```dart
// AppCard + FadeInCard for animated entrance
FadeInCard(
  child: AppCard(
    child: YourContent(),
  ),
)
```

**5. Use Gen-Z Slang Sparingly:**
- Buttons: "Lock it in", "Spread the vibe"
- Empty states: "No vibes here yet"
- Errors: "Connection not vibing rn"
- Don't overdo it - keep professional terms for technical UI

---

**Phase 7 Complete! 🎨✨**

The entire design system is ready. All screens built from Phase 8 onwards will use these foundations for a consistent, modern, Gen-Z aesthetic.
