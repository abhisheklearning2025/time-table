# TimeTable - Smart Schedule Manager 📅

> Organize your day the Gen-Z way with audio alerts, sharing, and beautiful design.

A multi-user timetable platform built with Flutter that allows users to create, share, and track daily schedules with smart audio alerts and real-time activity tracking.

![Platform](https://img.shields.io/badge/Platform-Android%208.0%2B-green)
![Flutter](https://img.shields.io/badge/Flutter-3.10.4%2B-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### Core Features
- **Create up to 5 timetables** - Personal schedules for different days/activities
- **Import 5 shared timetables** - Get schedules from friends via QR/link/code
- **Smart audio alerts** - Background notifications when activities start
- **5-minute warnings** - Get notified before activities begin
- **Real-time tracking** - See current activity with countdown timer
- **Offline-first** - Works without internet (except for sharing)

### Sharing Features
- **QR Code** - Generate and scan QR codes
- **Share Links** - Create shareable URLs (`timetable.app/t/ABC123`)
- **6-Digit Codes** - Share via simple codes (e.g., `ABC123`)
- **Public Templates** - Browse preset schedules (Student, Professional, Fitness)
- **Firebase Sync** - Cloud storage for shared timetables

### UI/UX
- **Gen-Z Aesthetic** - Vibrant colors, smooth animations, modern design
- **Dark Mode** - Full dark theme support
- **3 Theme Options** - Vibrant, Pastel, Neon color schemes
- **Material 3** - Latest Material Design guidelines
- **Responsive** - Optimized for all screen sizes

### Technical Features
- **Background Alerts** - WorkManager ensures alerts fire even when app is closed
- **Midnight Crossing** - Support for activities spanning midnight (e.g., 11 PM - 1 AM)
- **Per-Timetable Alerts** - Enable/disable alerts for each timetable
- **Custom Audio** - Set custom alert sounds per category
- **Deep Linking** - Open shared timetables directly from links

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK 3.10.4 or higher
- Android Studio / VS Code with Flutter extension
- Android device or emulator (Android 8.0+)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourcompany/timetable.git
cd abhishek_time_table
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up Firebase**

See [Firebase Setup](#firebase-setup) section below.

4. **Run the app**
```bash
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Enable the following services:
   - **Authentication** → Anonymous
   - **Firestore Database**
   - **Analytics** (optional)
   - **Performance Monitoring** (optional)

3. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - Web: Copy web config to `web/firebase-config.js`

4. Deploy Firestore security rules:
```bash
firebase deploy --only firestore:rules
```

See [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md) for detailed instructions.

### Sentry Setup (Optional - Error Tracking)

1. Create account at [sentry.io](https://sentry.io)
2. Create Flutter project
3. Copy DSN to `lib/core/constants/sentry_config.dart`:
```dart
static const String dsn = 'https://your-dsn@sentry.io/project-id';
```

See [SENTRY_SETUP.md](SENTRY_SETUP.md) for detailed instructions.

## 📱 Build for Production

### Build APK
```bash
flutter build apk --release --split-per-abi
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### Build for Web
```bash
flutter build web --release
```

See [PLAYSTORE_PREPARATION.md](PLAYSTORE_PREPARATION.md) for full Play Store submission guide.

## 🏗️ Project Structure

```
lib/
├── core/                   # Core utilities and theme
│   ├── constants/          # App constants
│   ├── theme/              # Material 3 theme
│   └── utils/              # Helper functions
├── data/                   # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Data repositories
│   └── data_sources/       # Local & remote data sources
├── domain/                 # Business logic
│   └── services/           # Business services
├── presentation/           # UI layer
│   ├── providers/          # State management (Provider)
│   ├── screens/            # App screens
│   └── widgets/            # Reusable widgets
└── services/               # App-wide services
    └── dependency_injection.dart
```

**Architecture**: Clean Architecture with Provider for state management

## 🎨 Customization

### Change Theme Colors

Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1);  // Indigo
static const Color accentColor = Color(0xFFA855F7);   // Purple
```

### Add Custom Categories

Edit `lib/core/constants/app_constants.dart`:
```dart
static final presetCategories = [
  Category(id: 'custom', name: 'Custom', color: Colors.orange),
];
```

### Modify Alert Sounds

Place audio files in `assets/audio/default/` and update `pubspec.yaml`.

## 📖 Documentation

### User Guides
- [App Features Overview](docs/FEATURES.md) *(to be created)*
- [Sharing Timetables](docs/SHARING.md) *(to be created)*

### Developer Guides
- [Firebase Security](FIREBASE_SECURITY.md) - Firestore rules and setup
- [Sentry Error Tracking](SENTRY_SETUP.md) - Error monitoring setup
- [Icon Setup](ICON_SETUP.md) - App icon and splash screen
- [Play Store Preparation](PLAYSTORE_PREPARATION.md) - Complete submission guide
- [Privacy Policy](PRIVACY_POLICY_TEMPLATE.md) - Ready-to-use privacy policy

### Phase Summaries
- [Phase 18: Web Build](PHASE_18_SUMMARY.md)
- [Phase 19: Production Readiness](PHASE_19_SUMMARY.md)

### Technical Docs
- [Web Deployment](WEB_DEPLOYMENT.md) - Vercel deployment guide
- [Test Results](TEST_RESULTS.md) - Unit and widget test results

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/core/utils/time_helper_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Current Test Status**: 11/16 tests passing (see [TEST_RESULTS.md](TEST_RESULTS.md))

## 🛠️ Tech Stack

### Core
- **Flutter** 3.10.4 - UI framework
- **Dart** 3.10.4 - Programming language
- **Material 3** - Design system

### State Management
- **Provider** 6.1.1 - State management

### Backend & Storage
- **Firebase Auth** 5.3.4 - Anonymous authentication
- **Cloud Firestore** 5.6.0 - Cloud database for sharing
- **SQLite** 2.4.1 - Local database
- **SharedPreferences** 2.3.3 - Settings storage

### Notifications & Audio
- **Flutter Local Notifications** 18.0.1 - Notifications
- **AudioPlayers** 6.1.0 - Audio playback
- **WorkManager** 0.5.2 - Background tasks

### Sharing
- **QR Flutter** 4.1.0 - QR code generation
- **Mobile Scanner** 6.0.2 - QR code scanning
- **Share Plus** 10.1.3 - Native share dialog
- **App Links** 6.3.4 - Deep linking

### Monitoring & Analytics
- **Firebase Analytics** 11.3.5 - Usage analytics
- **Firebase Performance** 0.10.0+10 - Performance monitoring
- **Sentry Flutter** 8.11.0 - Error tracking

### UI/UX
- **Google Fonts** 6.2.1 - Typography
- **Flutter Animate** 4.5.0 - Animations
- **Shimmer** 3.0.0 - Loading effects
- **Lottie** 3.2.0 - Complex animations

### Development Tools
- **GetIt** 8.0.3 - Dependency injection
- **JSON Serializable** 6.8.0 - JSON serialization
- **Flutter Launcher Icons** 0.14.2 - Icon generation
- **Flutter Native Splash** 2.4.3 - Splash screen

## 🔒 Privacy & Security

### Data Collection
- **Anonymous User ID** (Firebase UID) - For sharing features
- **Device Information** - For analytics and crash reports
- **Usage Analytics** - To improve app experience

### Data NOT Collected
- Personal names or emails
- Exact location
- Contacts or calendar data
- Financial information

See [PRIVACY_POLICY_TEMPLATE.md](PRIVACY_POLICY_TEMPLATE.md) for full privacy policy.

## 🌐 Web Version

The app has a view-only web version deployed on Vercel:
- View shared timetables via links
- Browse public templates
- Import timetables (view-only copy)
- No edit/delete capabilities
- No background alerts (browser limitations)

See [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md) for deployment instructions.

## 📊 Analytics & Monitoring

### Firebase Analytics Events
- Timetable creation/deletion/editing
- Sharing and importing
- Alert triggers and snoozes
- Theme changes
- Template usage

### Sentry Error Tracking
- Crash reports
- Error stack traces
- Performance monitoring
- User breadcrumbs

### Firebase Performance
- Screen load times
- Database query performance
- Network request latency
- Custom operation traces

## 🐛 Known Issues

See [TEST_RESULTS.md](TEST_RESULTS.md) for detailed test failures:
1. Midnight crossing logic edge cases
2. getCurrentActivity null handling
3. Alert indicator icon mismatch
4. Text matching inconsistencies

**Status**: Documented for future bug fix phase.

## 🚧 Roadmap

### Phase 20: Bug Fixes & Polish
- Fix failing tests from Phase 17
- UI/UX refinements
- Performance optimizations

### Phase 21: Launch
- Play Store submission
- Vercel web deployment
- Marketing campaign

### Future Features
- **Multi-device sync** - Sync across devices
- **Widgets** - Home screen widgets
- **Recurring timetables** - Weekly schedules
- **Statistics** - Activity tracking and insights
- **Reminders** - Pre-activity reminders
- **Export/Backup** - Export to calendar, PDF
- **iOS version** - If demand exists
- **Premium features** - Unlimited timetables, themes

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Guidelines
- Follow Flutter style guide
- Write tests for new features
- Update documentation
- Run `flutter analyze` before committing
- Keep commits atomic and descriptive

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Abhishek Rati** - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Sentry for error tracking
- Material Design team for design guidelines
- Open source community for packages

## 📞 Support

- **Email**: support@timetable.app
- **GitHub Issues**: [Create an issue](https://github.com/yourcompany/timetable/issues)
- **Website**: https://timetable.app *(to be created)*

## 💰 Support the Project

If you find this app useful, consider:
- ⭐ Starring the repository
- 📢 Sharing with friends
- ☕ [Buy me a coffee](https://buymeacoffee.com/yourname) *(optional)*

---

**Made with ❤️ for the Gen-Z generation**

Let's organize our chaos! 🎯
