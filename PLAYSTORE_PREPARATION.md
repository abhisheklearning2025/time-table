# Google Play Store - Preparation Guide

## Overview
This document outlines all requirements and steps to publish the TimeTable app on Google Play Store.

## Prerequisites Checklist

### Developer Account
- [ ] Google Play Console account ($25 one-time fee)
- [ ] Payment method added (for paid apps or in-app purchases)
- [ ] Developer profile completed

### App Requirements
- [ ] Unique package name (com.yourcompany.abhishek_time_table)
- [ ] Signed release APK/AAB
- [ ] Privacy policy URL
- [ ] App content rating completed
- [ ] Target API level 34+ (Android 14)

---

## Required Assets

### 1. App Icon
**Status**: Configuration ready in pubspec.yaml

**Next Steps**:
1. Create icon images (see [ICON_SETUP.md](ICON_SETUP.md))
2. Place in `assets/images/`
3. Run `flutter pub run flutter_launcher_icons`

**Specifications**:
- 1024x1024 px PNG (no transparency for legacy)
- 1024x1024 px PNG adaptive foreground
- Vibrant Gen-Z design with #6366F1 background

### 2. Feature Graphic
**Required**: Yes (for Play Store listing)

**Specifications**:
- Size: 1024x500 px
- Format: PNG or JPEG
- Max file size: 1 MB
- No transparency

**Design Recommendations**:
- Show app UI mockup
- Include tagline: "Organize your day the Gen-Z way"
- Use vibrant gradient background (#6366F1 → #A855F7)
- Display key features: Alerts, Sharing, Templates

**Tools**:
- Canva (easiest)
- Figma (professional)
- Photoshop

### 3. Screenshots (Required)
**Minimum**: 2 screenshots
**Recommended**: 4-8 screenshots

**Specifications**:
- Format: PNG or JPEG
- Dimensions: 16:9 or 9:16 aspect ratio
- Min: 320px on shortest side
- Max: 3840px on longest side
- Recommended: 1080x1920 px (phone) or 1920x1080 px (tablet)

**Screenshot Ideas**:
1. **Home Screen** - List of timetables with vibrant cards
2. **Timeline View** - Current activity with countdown
3. **Create Screen** - Add new timetable flow
4. **Sharing Screen** - QR code and share options
5. **Templates Gallery** - Browse preset timetables
6. **Settings Screen** - Alert toggles and theme options
7. **Alert Dialog** - Activity alert notification
8. **Dark Mode** - Show dark theme variant

**How to Capture**:
```bash
# Run app on emulator/device
flutter run --release

# Use Android Studio Device File Explorer
# Or use adb screenshot command
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

**Tools for Enhancement**:
- [Previewed](https://previewed.app) - Device frames
- [Screenshots.pro](https://screenshots.pro) - App mockups
- [Figma Templates](https://www.figma.com/community/tag/app%20screenshots)

### 4. Video (Optional but Recommended)
**Max duration**: 30 seconds
**Format**: MP4, MOV, AVI
**Max file size**: 100 MB

**Content Ideas**:
- Quick walkthrough of creating a timetable
- Show alert triggering in real-time
- Demonstrate sharing via QR code
- Highlight Gen-Z aesthetic

**Tools**:
- Screen recorder (Android Studio, scrcpy)
- Video editor (DaVinci Resolve, CapCut)

### 5. Promo Graphic (Optional)
**Size**: 180x120 px
**Format**: PNG or JPEG

Used for promotions in Play Store.

---

## App Listing Details

### 1. Title
**Max**: 50 characters

**Options**:
- "TimeTable - Smart Schedule Manager"
- "TimeTable - Alerts & Sharing"
- "TimeTable: Organize Your Day"

**Current Recommendation**: "TimeTable - Schedule & Alerts"

### 2. Short Description
**Max**: 80 characters

**Recommendation**:
"Create, share, and track your daily schedule with audio alerts & notifications."

### 3. Full Description
**Max**: 4000 characters

**Template**:
```
📅 TimeTable - Organize Your Day the Gen-Z Way

Create up to 5 timetables, import 5 shared schedules, and never miss an activity with smart audio alerts and notifications!

✨ KEY FEATURES

🔔 Smart Alerts & Notifications
• Audio alerts when activities start
• 5-minute warning before activities
• Background alerts (app closed or minimized)
• Customizable alert sounds per category
• Snooze and dismiss options

📤 Easy Sharing
• Share timetables via QR code
• Generate shareable links
• Import with 6-digit share codes
• Browse public templates
• Real-time Firebase sync

📚 Multiple Timetables
• Create up to 5 personal timetables
• Import up to 5 shared schedules
• Switch active timetable anytime
• Per-timetable alert controls

🎨 Gen-Z Aesthetic
• Vibrant colors and smooth animations
• Dark mode support
• Multiple theme options (Vibrant, Pastel, Neon)
• Modern Material 3 design

📊 Templates Library
• Student schedules
• Professional 9-5 routines
• Fitness plans
• Meal planning
• Custom templates

⚙️ Powerful Features
• Real-time current activity tracking
• Countdown timers with progress bars
• Category-based activity organization
• Midnight crossing support (late-night activities)
• Offline-first (works without internet)
• Export to cloud for sharing

🚀 WHY TIMETABLE?

TimeTable is built for students, professionals, and anyone who wants to stay on top of their daily routine. Whether you're juggling classes, work meetings, or workout sessions, TimeTable keeps you organized with smart alerts and easy sharing.

💡 USE CASES

Students: Track class schedules, study sessions, assignments
Professionals: Manage meetings, deep work blocks, breaks
Fitness: Plan workouts, track nutrition, schedule recovery
Parents: Organize family time, meal prep, kids' activities

🔒 PRIVACY

• Anonymous authentication (no login required)
• Local-first data storage
• Optional cloud sync for sharing
• No personal data collection

📱 REQUIREMENTS

• Android 8.0+ (API 26)
• Notification permissions (for alerts)
• Internet connection (for sharing features only)

🌐 SUPPORT

• Email: support@timetable.app
• GitHub: github.com/yourcompany/timetable
• Privacy Policy: timetable.app/privacy

Made with ❤️ for the Gen-Z generation. Let's organize our chaos! 🎯
```

**Tips**:
- Use emojis sparingly (1-2 per section)
- Highlight unique features (sharing, multiple timetables)
- Include keywords: schedule, planner, alerts, notifications, time management
- Mention privacy and offline support
- Add call-to-action at the end

### 4. Categories
**Primary Category**: Productivity
**Secondary Category** (optional): Lifestyle

### 5. Tags
**Max**: 5 tags

**Recommendations**:
- schedule
- planner
- time management
- productivity
- alerts

### 6. Contact Details
- **Email**: your-email@example.com (required)
- **Website**: https://timetable.app (optional)
- **Phone**: +1234567890 (optional)

### 7. Privacy Policy
**Required**: Yes

**Hosting Options**:
- GitHub Pages (free): `https://yourusername.github.io/timetable/privacy.html`
- Firebase Hosting (free)
- Website: `https://timetable.app/privacy`

**Privacy Policy Template**:
See [PRIVACY_POLICY_TEMPLATE.md](PRIVACY_POLICY_TEMPLATE.md)

---

## App Content Rating

Complete the questionnaire in Play Console to get content rating.

**Expected Rating**: E (Everyone) or T (Teen)

**Key Questions**:
- Violence: No
- Sexual content: No
- Profanity: No
- User interaction: No (anonymous auth, no chat)
- Data sharing: Minimal (anonymous ID only)
- Location: No
- Purchases: No (if free app)

---

## Build & Sign App

### 1. Create Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**Save credentials**:
- Keystore password
- Key alias
- Key password

### 2. Configure key.properties
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=path/to/upload-keystore.jks
```

### 3. Update build.gradle
Edit `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Build Release
```bash
# Build App Bundle (AAB) - Recommended
flutter build appbundle --release

# Or build APK
flutter build apk --release --split-per-abi

# Output:
# AAB: build/app/outputs/bundle/release/app-release.aab
# APK: build/app/outputs/apk/release/app-armeabi-v7a-release.apk
```

**Recommendation**: Use AAB (Android App Bundle) for Play Store - smaller download size, better optimization.

---

## Testing Before Submission

### 1. Internal Testing
- Upload AAB to Play Console → Internal Testing
- Add test users (email addresses)
- Test on real devices
- Verify all features work

### 2. Closed Testing (Beta)
- Expand to 20-100 users
- Gather feedback
- Fix critical bugs

### 3. Pre-Launch Report
Play Console automatically tests your app on ~20 devices:
- Crashes
- Security vulnerabilities
- Accessibility issues
- Performance

Review and fix issues before production release.

---

## Submission Checklist

### App Details
- [ ] App name (50 chars max)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] App icon (512x512 px)
- [ ] Feature graphic (1024x500 px)
- [ ] Screenshots (min 2, recommended 4-8)
- [ ] Privacy policy URL
- [ ] Category selected
- [ ] Contact email

### Store Listing
- [ ] App screenshots uploaded (phone + tablet if applicable)
- [ ] Video uploaded (optional but recommended)
- [ ] Translations added (if supporting multiple languages)

### App Content
- [ ] Content rating completed
- [ ] Target audience selected
- [ ] Ads declaration (does app show ads? No)
- [ ] Data safety form completed
- [ ] App access (no login required - anonymous)

### Pricing & Distribution
- [ ] Free or paid selected
- [ ] Countries selected for distribution
- [ ] Google Play for Education (opt-in/out)

### App Release
- [ ] Release name (e.g., "v0.1.0")
- [ ] Release notes written
- [ ] AAB uploaded
- [ ] Internal testing passed
- [ ] Pre-launch report reviewed

---

## Release Notes Template

**v0.1.0 - Initial Release**
```
🎉 Welcome to TimeTable!

✨ What's New:
• Create up to 5 personal timetables
• Import 5 shared schedules from friends
• Smart audio alerts and notifications
• Share timetables via QR code or link
• Browse public templates
• Beautiful Gen-Z aesthetic with dark mode
• Real-time activity tracking
• Offline-first, cloud sync for sharing

🔔 Features:
• Background alerts even when app is closed
• 5-minute warning before activities
• Customizable alert sounds
• Snooze and dismiss options

📱 Requirements:
• Android 8.0+
• Notification permissions for alerts

💬 Feedback:
Love the app? Rate us 5 stars!
Found a bug? Email us at support@timetable.app
```

---

## Data Safety Form

**Data Collection**:
- [ ] User IDs (anonymous Firebase UID) - Optional, for sharing
- [ ] App interactions (Firebase Analytics) - Optional
- [ ] Crash logs (Sentry) - Optional

**Data Usage**:
- Analytics: Improve app performance
- Crash reports: Fix bugs

**Data Sharing**:
- No data sold to third parties
- No data shared for advertising

**Security**:
- Data encrypted in transit (HTTPS)
- Users can request data deletion

**Data Deletion**:
- Settings → Account → Clear All Data
- Deletes local timetables and anonymous profile

---

## Pricing Strategy

**Recommendation**: Free with optional donation link

**Why Free?**:
- Larger user base
- Easier to go viral
- Build reputation first
- Monetize later (premium features, ads)

**Future Monetization** (Phase 20+):
- Premium themes (beyond 3 free)
- Unlimited timetables (beyond 5+5 limit)
- Cloud backup across devices
- Analytics dashboard
- Ad-free experience (if showing ads)

---

## Launch Strategy

### Pre-Launch (2 weeks before)
- [ ] Create social media accounts (Twitter, Instagram, TikTok)
- [ ] Post teaser screenshots
- [ ] Create landing page (timetable.app)
- [ ] Prepare launch announcement

### Launch Day
- [ ] Submit to Play Store
- [ ] Post on Reddit (r/productivity, r/androidapps)
- [ ] Share on social media
- [ ] Email friends/beta testers
- [ ] Post on Product Hunt
- [ ] Share in Gen-Z communities (TikTok, Discord)

### Post-Launch (Week 1-2)
- [ ] Monitor reviews and respond
- [ ] Fix critical bugs ASAP
- [ ] Track analytics (downloads, retention)
- [ ] Gather user feedback
- [ ] Plan next update

---

## Common Rejection Reasons & Fixes

### 1. Missing Privacy Policy
**Fix**: Create and host privacy policy, add URL to Play Console

### 2. Insufficient Screenshots
**Fix**: Upload at least 2, preferably 4-8 screenshots

### 3. Icon Not Following Guidelines
**Fix**: Remove text from icon, use high-resolution (1024x1024 px)

### 4. Misleading Description
**Fix**: Ensure all features mentioned in description actually work

### 5. Crash on Launch
**Fix**: Test release build thoroughly before submission

### 6. Missing Permissions Explanation
**Fix**: Update AndroidManifest.xml with uses-permission comments

### 7. Target API Level Too Low
**Fix**: Update targetSdkVersion to 34+ in build.gradle

---

## Post-Launch Checklist

### Week 1
- [ ] Respond to all reviews (within 24 hours)
- [ ] Monitor crash reports (Sentry)
- [ ] Track analytics (Firebase Analytics)
- [ ] Fix critical bugs
- [ ] Release hotfix if needed

### Month 1
- [ ] Analyze user retention
- [ ] Identify most-used features
- [ ] Plan feature updates
- [ ] A/B test app listing (screenshots, description)
- [ ] Request reviews from satisfied users

### Ongoing
- [ ] Monthly updates with bug fixes
- [ ] Quarterly feature releases
- [ ] Monitor competitors
- [ ] Engage with user community
- [ ] Maintain 4.0+ star rating

---

## Resources

### Official Documentation
- [Play Console Help](https://support.google.com/googleplay/android-developer/)
- [App Quality Guidelines](https://developer.android.com/quality)
- [Store Listing Best Practices](https://developer.android.com/distribute/best-practices/launch/)

### Tools
- [App Icon Generator](https://romannurik.github.io/AndroidAssetStudio/)
- [Screenshot Templates](https://www.figma.com/community/tag/app%20screenshots)
- [ASO Tools](https://appradar.com) - App Store Optimization

### Communities
- [r/androiddev](https://reddit.com/r/androiddev)
- [r/androidapps](https://reddit.com/r/androidapps)
- [Flutter Discord](https://discord.gg/flutter)

---

## Estimated Timeline

- **Assets Creation**: 2-3 days (icon, screenshots, graphics)
- **Testing**: 1 week (internal + closed beta)
- **Listing Setup**: 1 day (write descriptions, fill forms)
- **Review Process**: 1-7 days (Google's review time)
- **Total**: ~2-3 weeks from start to live

---

## Success Metrics

### Launch Goals (Month 1)
- 100+ downloads
- 4.0+ star rating
- <5% crash rate
- >40% 7-day retention

### Growth Goals (Month 3)
- 1,000+ downloads
- 4.5+ star rating
- 10+ reviews
- Featured in "New & Updated" section

### Long-term Goals (Year 1)
- 10,000+ downloads
- 4.7+ star rating
- 100+ reviews
- Top 50 in Productivity category

---

## Contact & Support

If you need help during the submission process:
- Google Play Console Help Center
- Flutter Community Discord
- Email: play-store-support@google.com

Good luck with your launch! 🚀
