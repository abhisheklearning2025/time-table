# Firebase Security Rules - Production Guide

## Overview
This document explains the production Firebase security rules for the TimeTable app and how to deploy them.

## Security Architecture

### Key Principles
1. **Anonymous Auth Required**: All write operations require authentication (even anonymous)
2. **Owner-Based Access**: Users can only modify their own timetables
3. **Public Read for Sharing**: Shared timetables are readable by anyone
4. **Validation on Write**: Server-side validation prevents malicious data
5. **Rate Limiting**: Timestamps prevent rapid-fire creates/updates

### Collections

#### 1. `/timetables/{shareCode}`
**Purpose**: Shared timetables between users

**Read Access**: ✅ Anyone
- Required for importing timetables via share code
- No authentication needed to view shared timetables

**Write Access**: ✅ Authenticated users only (owner)
- Create: Any authenticated user can share their timetable
- Update: Only the owner (ownerId matches auth.uid)
- Delete: Only the owner

**Validation Rules**:
- Share code must be exactly 6 characters (A-Z, 0-9)
- Timetable name: 1-100 characters
- Max 50 activities per timetable
- Created timestamp must match server time (prevents backdating)
- Critical fields (id, ownerId, createdAt) cannot be changed after creation

**Example Valid Document**:
```json
{
  "id": "ABC123",
  "name": "My Study Schedule",
  "description": "Daily study routine",
  "emoji": "📚",
  "ownerId": "firebase_anonymous_uid_here",
  "activities": [
    {
      "id": "act1",
      "time": "9:00 AM",
      "title": "Math Class",
      ...
    }
  ],
  "isPublic": false,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

#### 2. `/templates/{templateId}`
**Purpose**: Curated public timetable templates

**Read Access**: ✅ Anyone
- Users can browse templates without authentication

**Write Access**: 🔒 Admin only
- Requires custom claim: `admin: true`
- Regular users cannot create/modify templates

**Use Case**: Pre-made templates (Student, Professional, Fitness, etc.)

**How to Create Admin User**:
```javascript
// Firebase Admin SDK (Node.js)
admin.auth().setCustomUserClaims(uid, { admin: true });
```

#### 3. `/users/{userId}` (Optional - Future Use)
**Purpose**: User profile data and preferences

**Read Access**: ✅ Owner only
**Write Access**: ✅ Owner only

**Use Case**:
- Sync settings across devices (future feature)
- Track user statistics
- Store user preferences

#### 4. `/analytics/{eventId}` (Optional)
**Purpose**: App usage analytics

**Read Access**: 🔒 None (server/admin only)
**Write Access**: ✅ Authenticated users

**Use Case**:
- Track timetable imports
- Track feature usage
- Anonymous analytics (no PII)

## Validation Rules Explained

### `isValidTimetable()`
Ensures timetable data integrity:
- ✅ Required fields present (id, name, ownerId, activities, createdAt)
- ✅ Share code is 6 characters
- ✅ Name is 1-100 characters (prevents empty names or spam)
- ✅ Max 50 activities (prevents abuse)
- ✅ Timestamp is valid

### `isValidShareCode()`
Ensures share codes match expected format:
- ✅ Exactly 6 characters
- ✅ Only uppercase letters and numbers (A-Z, 0-9)
- ❌ Rejects: "abc123", "ABCD12", "ABC-123"
- ✅ Accepts: "ABC123", "XYZ789"

### Rate Limiting
- `createdAt == request.time` ensures clients can't backdate documents
- Prevents rapid-fire document creation (Firestore will reject duplicates)

## Deployment

### 1. Via Firebase Console (Recommended for First Deploy)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database** → **Rules**
4. Copy contents of `firestore.rules` into the editor
5. Click **Publish**

### 2. Via Firebase CLI (Recommended for Updates)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (if not already done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules

# Verify deployment
firebase firestore:rules:list
```

### 3. Via CI/CD (GitHub Actions Example)

```yaml
# .github/workflows/deploy-firebase.yml
name: Deploy Firebase Rules
on:
  push:
    branches: [main]
    paths:
      - 'firestore.rules'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: w9jds/firebase-action@master
        with:
          args: deploy --only firestore:rules
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Testing Security Rules

### Local Testing with Emulator

```bash
# Start Firestore emulator
firebase emulators:start --only firestore

# Run in test mode
firebase emulators:start --only firestore --import=./test-data
```

### Unit Tests (JavaScript/TypeScript)

```javascript
const { assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');

describe('Timetable Security Rules', () => {
  it('allows authenticated users to create timetables', async () => {
    const db = authedDb({ uid: 'user123' });
    await assertSucceeds(db.collection('timetables').doc('ABC123').set({
      id: 'ABC123',
      name: 'Test Schedule',
      ownerId: 'user123',
      activities: [],
      createdAt: new Date(),
    }));
  });

  it('denies unauthenticated users from creating timetables', async () => {
    const db = guestDb();
    await assertFails(db.collection('timetables').doc('ABC123').set({
      id: 'ABC123',
      name: 'Test Schedule',
      ownerId: 'user123',
      activities: [],
      createdAt: new Date(),
    }));
  });

  it('denies users from modifying others timetables', async () => {
    const db = authedDb({ uid: 'user456' });
    await assertFails(db.collection('timetables').doc('ABC123').update({
      name: 'Hacked Schedule',
    }));
  });
});
```

### Manual Testing Checklist

- [ ] Unauthenticated user can read shared timetable
- [ ] Unauthenticated user cannot create timetable (denied)
- [ ] Authenticated user can create their own timetable
- [ ] Authenticated user cannot modify someone else's timetable
- [ ] Authenticated user can update their own timetable
- [ ] Authenticated user can delete their own timetable
- [ ] Invalid share code (5 chars) is rejected
- [ ] Timetable with 51 activities is rejected
- [ ] Templates are readable by everyone
- [ ] Non-admin cannot create templates

## Common Security Issues & Fixes

### Issue 1: "PERMISSION_DENIED" on Import
**Cause**: Timetable document doesn't exist or share code is invalid

**Fix**:
- Verify share code format (6 uppercase alphanumeric)
- Check timetable exists in Firestore console
- Ensure `allow read: if true` for `/timetables/{shareCode}`

### Issue 2: Can't Update Own Timetable
**Cause**: Trying to change immutable fields (id, ownerId, createdAt)

**Fix**:
- Only update mutable fields (name, description, activities, updatedAt)
- Never change ownerId or createdAt in updates

### Issue 3: Anonymous Auth Not Working
**Cause**: Anonymous auth not enabled in Firebase Console

**Fix**:
1. Go to **Authentication** → **Sign-in method**
2. Enable **Anonymous** provider
3. Save

### Issue 4: Rate Limit Hit
**Cause**: Too many writes in short time

**Fix**:
- Implement client-side rate limiting
- Use `updatedAt` timestamp to throttle updates
- Consider batching updates

## Production Checklist

Before going live:

### Security
- [x] Firestore rules deployed
- [ ] Anonymous auth enabled in Firebase Console
- [ ] Test rules with unit tests
- [ ] Manual security testing completed
- [ ] No debug/test rules in production
- [ ] Admin claims configured (if using templates)

### Performance
- [ ] Create indexes for common queries (see below)
- [ ] Monitor query performance in Firebase Console
- [ ] Set up billing alerts (free tier: 50K reads/day, 20K writes/day)

### Monitoring
- [ ] Enable Firestore audit logs (optional, costs extra)
- [ ] Set up Firebase Alerts for security rule violations
- [ ] Monitor for unusual read/write patterns

## Required Firestore Indexes

Create these indexes in Firebase Console → Firestore → Indexes:

### For Template Browsing
```
Collection: templates
Fields:
  - category (Ascending)
  - createdAt (Descending)
```

### For User's Timetables
```
Collection: timetables
Fields:
  - ownerId (Ascending)
  - createdAt (Descending)
```

**Note**: Firebase will prompt you to create indexes when queries fail. Follow the provided link to auto-create.

## Cost Optimization

### Free Tier Limits (Firestore)
- **Reads**: 50,000/day
- **Writes**: 20,000/day
- **Deletes**: 20,000/day
- **Storage**: 1 GB

### Strategies to Stay Free
1. **Cache aggressively** on client side (use SQLite for local-first)
2. **Limit template browsing** (paginate results, cache locally)
3. **Batch writes** when updating timetables
4. **Monitor usage** in Firebase Console → Usage tab

### Estimated Usage (10K Monthly Active Users)
- **Timetable Imports**: ~1K/day = 1K reads + 1K writes = **2K operations/day** ✅
- **Template Browsing**: ~500/day × 20 templates = **10K reads/day** ✅
- **Timetable Shares**: ~200/day = 200 writes ✅
- **Total**: ~12K operations/day (well within free tier)

## Emergency Security Lockdown

If you detect abuse or security issues:

### Immediate Actions

1. **Disable Writes (Emergency)**:
```javascript
// Quick fix: Deploy this rule
match /timetables/{shareCode} {
  allow read: if true;
  allow write: if false;  // Disable all writes
}
```

2. **Rate Limit by IP** (requires Cloud Functions):
```javascript
// Cloud Function example
exports.rateLimitCheck = functions.https.onCall((data, context) => {
  const ip = context.rawRequest.ip;
  // Check Redis/Firestore for request count
  // Return error if over limit
});
```

3. **Monitor in Real-Time**:
- Firebase Console → Usage → Firestore
- Look for spike in reads/writes
- Check for unusual document patterns

## Support & Resources

- [Firestore Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Rules Playground](https://firebase.google.com/docs/rules/simulator) - Test rules in browser
- [Firebase Discord](https://discord.gg/firebase) - Community support
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase) - #firebase tag

## Changelog

### v1.0.0 (Current)
- Initial production rules
- Anonymous auth support
- Share code validation (6 chars)
- Template admin controls
- Max 50 activities per timetable
- Owner-based access control

### Future Enhancements
- IP-based rate limiting (Cloud Functions)
- User reputation system
- Automatic spam detection
- Content moderation for public templates
