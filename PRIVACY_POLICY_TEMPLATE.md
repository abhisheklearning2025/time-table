# Privacy Policy for TimeTable

**Last Updated**: [INSERT DATE]

## Introduction

TimeTable ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This privacy policy explains how we collect, use, and protect your information when you use our mobile application.

## Information We Collect

### 1. Information You Provide
- **Timetable Data**: Activity names, times, descriptions, categories, and custom icons you create
- **Settings**: Alert preferences, theme choices, volume settings

### 2. Automatically Collected Information
- **Anonymous User ID**: Firebase Anonymous Authentication generates a unique identifier
- **Device Information**: Device model, operating system version, app version
- **Usage Analytics**: App interactions, features used, screen views (via Firebase Analytics)
- **Crash Reports**: Error logs and stack traces (via Sentry)

### 3. Information We Do NOT Collect
- ❌ Personal names or email addresses
- ❌ Phone numbers
- ❌ Exact location data
- ❌ Contacts or calendar access
- ❌ Camera or microphone data (except for QR scanning when you explicitly use that feature)
- ❌ Financial information

## How We Use Your Information

### Data Storage
- **Local Storage**: All timetables are stored locally on your device using SQLite
- **Cloud Sync** (Optional): Only when you choose to share a timetable, it's uploaded to Firebase Firestore with:
  - Anonymous User ID (no personal information)
  - Timetable activities and metadata
  - 6-digit share code

### Analytics & Improvements
- **Firebase Analytics**: Track feature usage, screen views, and app interactions to improve user experience
- **Sentry Error Tracking**: Collect crash reports and error logs to fix bugs

### Notifications
- **Local Notifications**: Audio alerts and system notifications are generated locally on your device
- **Background Service**: WorkManager schedules alerts; no data sent to external servers

## Data Sharing

### We DO NOT Share Your Data With:
- Third-party advertisers
- Data brokers
- Marketing companies

### We DO Share Minimal Data With:
- **Firebase/Google Cloud**: For anonymous authentication and cloud sharing features
- **Sentry**: For crash reporting and error tracking (anonymous)

### Your Shared Timetables
When you share a timetable via QR code or link:
- The timetable is stored in Firebase Firestore
- Anyone with the share code can view and import it
- Your anonymous User ID is attached (not personally identifiable)
- You can delete shared timetables anytime

## Your Rights and Choices

### Data Access
- View all your timetables in the app
- Export timetables via sharing features

### Data Deletion
- **Delete Local Data**: Settings → Account → Clear All Data
- **Delete Shared Timetables**: Delete timetable from app, removes from cloud
- **Request Full Deletion**: Email us at privacy@timetable.app

### Opt-Out of Analytics
- Analytics cannot be disabled in-app (required for bug tracking)
- You can uninstall the app to stop all data collection

## Data Security

### Measures We Take
- **Encryption in Transit**: All data sent to Firebase uses HTTPS/TLS
- **Anonymous Authentication**: No passwords or credentials stored
- **Local-First**: Data stays on device unless you choose to share
- **Secure Storage**: SQLite database encrypted by Android system

### Permissions Required
- **Notifications**: For activity alerts (required)
- **Camera**: For QR code scanning only (optional, on-demand)
- **Exact Alarms**: For precise activity notifications (Android 12+)
- **Internet**: For sharing timetables and analytics (optional for core features)

## Third-Party Services

We use the following third-party services:
- **Firebase (Google)**: Authentication, Firestore database, Analytics
  - [Firebase Privacy Policy](https://firebase.google.com/support/privacy)
- **Sentry**: Error tracking and performance monitoring
  - [Sentry Privacy Policy](https://sentry.io/privacy/)

These services may collect data as described in their respective privacy policies.

## Children's Privacy

TimeTable is suitable for users of all ages. We do not knowingly collect personal information from children under 13. If you are a parent/guardian and believe your child has provided us with personal information, please contact us to request deletion.

## Changes to This Policy

We may update this privacy policy from time to time. Changes will be posted here with an updated "Last Updated" date. Continued use of the app after changes constitutes acceptance of the new policy.

## Data Retention

- **Local Data**: Retained until you delete the app or clear data
- **Shared Timetables**: Retained in Firebase until you delete them
- **Analytics Data**: Retained for 14 months (Firebase default)
- **Crash Reports**: Retained for 90 days (Sentry default)

## International Users

TimeTable is available worldwide. Data may be transferred to and processed in countries where Firebase and Sentry operate servers, including the United States. By using the app, you consent to such transfers.

## Contact Us

If you have questions about this privacy policy or want to exercise your data rights:

- **Email**: privacy@timetable.app
- **GitHub**: https://github.com/yourcompany/timetable/issues
- **Website**: https://timetable.app/contact

## Your Consent

By using TimeTable, you consent to this privacy policy.

---

## Summary (TL;DR)

✅ **What we collect**: Anonymous ID, timetable data (local), device info, crash logs
✅ **What we DON'T collect**: Names, emails, location, contacts
✅ **How we use it**: Improve app, fix bugs, enable sharing features
✅ **Who we share with**: Firebase (for sharing), Sentry (for errors) - both anonymous
✅ **Your control**: Delete data anytime in Settings
✅ **Security**: Encrypted, local-first, anonymous

Questions? Email us at privacy@timetable.app

---

**TimeTable Team**
[Your Company Name]
[Date]
