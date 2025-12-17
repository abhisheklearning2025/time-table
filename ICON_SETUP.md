# App Icon & Splash Screen Setup

## Overview
This document outlines the app icon and splash screen assets needed for the TimeTable app.

## Required Assets

### 1. App Icon (assets/images/app_icon.png)
**Purpose**: Main app icon (legacy Android)

**Specifications**:
- Size: 1024x1024 px
- Format: PNG with transparency
- Design: Clock or calendar icon with vibrant Gen-Z colors

**Recommendations**:
- Use vibrant indigo (#6366F1) as primary color
- Include a modern clock face or timetable grid
- Keep design simple and recognizable at small sizes
- Avoid text (app name shows separately)

### 2. Adaptive Icon Foreground (assets/images/app_icon_foreground.png)
**Purpose**: Foreground layer for Android adaptive icons

**Specifications**:
- Size: 1024x1024 px
- Format: PNG with transparency
- Safe zone: Center 432x432 px (avoid clipping)
- Design: Same as app_icon.png but optimized for adaptive icons

**Note**: The background will be solid color (#6366F1), so the foreground should work well on indigo background.

### 3. Splash Screen Icon (assets/images/splash_icon.png)
**Purpose**: Displayed during app launch

**Specifications**:
- Size: 288x288 px (or larger, will be scaled)
- Format: PNG with transparency
- Design: Simplified version of app icon

**Recommendations**:
- Use same design as app icon but possibly simplified
- Will be centered on indigo background (#6366F1)
- Should be recognizable at smaller size

## Design Guidelines

### Color Palette (Gen-Z Theme)
- **Primary**: Indigo (#6366F1)
- **Accent**: Purple (#A855F7)
- **Highlight**: Pink (#EC4899)
- **Alternative**: Cyan (#06B6D4)

### Icon Concepts

**Option 1: Modern Clock**
- Circular clock face with modern hands
- Gradient from indigo to purple
- Minimalist numbers or tick marks

**Option 2: Timetable Grid**
- 3x3 or 4x4 grid representing schedule
- Some blocks highlighted in vibrant colors
- Optional: Add small clock icon overlay

**Option 3: Calendar + Clock Hybrid**
- Calendar page with clock hands
- Gen-Z style with bold colors
- Emoji integration (📅 or ⏰ stylized)

## Generation Commands

After placing the icon files in `assets/images/`, run:

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Quick Start (Using Placeholder Icons)

If you don't have custom icons yet, you can:

1. **Use online tools**:
   - [Canva](https://canva.com) - Free icon designer
   - [Figma](https://figma.com) - Professional design tool
   - [IconKitchen](https://icon.kitchen) - Android icon generator

2. **AI Image Generation**:
   - Use DALL-E, Midjourney, or Stable Diffusion
   - Prompt: "Modern minimalist clock icon for timetable app, vibrant indigo and purple gradient, Gen-Z aesthetic, flat design, on transparent background"

3. **Icon Fonts/Libraries**:
   - Material Icons (already in app)
   - [Flaticon](https://flaticon.com) - Download PNG icons
   - [The Noun Project](https://thenounproject.com)

## Current Status

### Icon Files Needed
- [ ] `assets/images/app_icon.png` (1024x1024)
- [ ] `assets/images/app_icon_foreground.png` (1024x1024)
- [ ] `assets/images/splash_icon.png` (288x288+)

### Configuration
- [x] pubspec.yaml updated with flutter_launcher_icons
- [x] pubspec.yaml updated with flutter_native_splash
- [x] Color scheme configured (#6366F1 indigo)
- [x] Android 12+ splash screen configured

### Next Steps
1. Create/obtain icon assets (see Design Guidelines)
2. Place files in `assets/images/`
3. Run generation commands
4. Test on Android device

## Testing Checklist

After generating icons:
- [ ] App icon appears in launcher
- [ ] Icon looks good in light theme
- [ ] Icon looks good in dark theme
- [ ] Adaptive icon works on Android 8+
- [ ] Splash screen shows on launch
- [ ] Splash screen matches brand colors
- [ ] Android 12+ splash screen works correctly
- [ ] No distortion or clipping on different devices

## Troubleshooting

### Icon Generation Fails
```bash
# Clear cache and retry
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### Splash Screen Not Showing
- Check `android/app/src/main/res/drawable` for generated files
- Verify `android/app/src/main/res/values/styles.xml` has splash theme
- Run `flutter clean` and rebuild

### Icon Looks Blurry
- Ensure source image is at least 1024x1024 px
- Use PNG format, not JPEG
- Check image has sufficient DPI (300+)

## Resources

- [Android Adaptive Icons Guide](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- [Material Design Icons](https://m3.material.io/styles/icons/overview)
- [Flutter Launcher Icons Docs](https://pub.dev/packages/flutter_launcher_icons)
- [Flutter Native Splash Docs](https://pub.dev/packages/flutter_native_splash)

## Production Checklist

Before app store submission:
- [ ] High-quality custom icon created
- [ ] Icon tested on multiple devices
- [ ] Splash screen tested on Android 8-14
- [ ] Screenshots include updated icon
- [ ] Feature graphic includes icon branding
- [ ] All icon sizes generated correctly
