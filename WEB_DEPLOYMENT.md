# Web Deployment Guide - Phase 18

## Overview
This guide covers deploying the TimeTable app to web with Vercel hosting. The web version runs in **view-only mode** with limited features compared to the Android app.

## Web Version Limitations

### Not Available on Web ❌
- **Background audio alerts** - Browsers don't support reliable background audio
- **System notifications** - Limited notification API support
- **QR code scanning** - Camera access restrictions in browsers
- **Custom audio files** - No file system access in browsers
- **Edit/Delete operations** - View-only mode for web
- **Create new timetables** - Web users can only view and import

### Available on Web ✅
- View shared timetables via deep links (`timetable.app/t/ABC123`)
- Browse public templates
- Import timetables (view-only)
- Real-time activity tracking (in-page only)
- Light/Dark mode theme
- Responsive design

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Firebase project** with web app configured
3. **Vercel account** (free tier works)
4. **Git repository** (for automatic deployments)

## Step 1: Configure Firebase for Web

### 1.1 Add Web App to Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click "Add app" → Select Web (</>) icon
4. Register app with nickname: "TimeTable Web"
5. Copy the Firebase configuration

### 1.2 Create Firebase Config File
Create `web/firebase-config.js`:

```javascript
// Firebase configuration
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
```

### 1.3 Update index.html
Add Firebase SDKs to `web/index.html` before `</body>`:

```html
<!-- Firebase SDKs -->
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>

<!-- Your Firebase config -->
<script src="firebase-config.js"></script>
```

## Step 2: Build for Web

### 2.1 Clean Previous Builds
```bash
flutter clean
flutter pub get
```

### 2.2 Build Web App
```bash
flutter build web --release --web-renderer html
```

**Build options:**
- `--release`: Optimized production build
- `--web-renderer html`: HTML renderer (better compatibility than canvaskit)
- Alternative: `--web-renderer canvaskit` for better performance but larger bundle

### 2.3 Verify Build
After successful build, check `build/web/` directory:
```
build/web/
├── index.html
├── flutter_bootstrap.js
├── assets/
├── canvaskit/ (if using canvaskit renderer)
├── favicon.png
└── icons/
```

## Step 3: Test Locally

### 3.1 Serve Locally
```bash
# Using Python
cd build/web
python3 -m http.server 8000

# Or using Flutter
flutter run -d chrome
```

### 3.2 Open in Browser
Navigate to `http://localhost:8000`

### 3.3 Test Functionality
- [x] App loads without errors
- [x] Firebase authentication works
- [x] Can view timetables
- [x] Deep links work (`/t/ABC123`)
- [x] Theme switching works
- [x] Responsive on mobile browser

## Step 4: Deploy to Vercel

### 4.1 Install Vercel CLI (Optional)
```bash
npm install -g vercel
```

### 4.2 Connect GitHub Repository

**Option A: Vercel Dashboard (Recommended)**
1. Go to [vercel.com](https://vercel.com)
2. Sign in with GitHub
3. Click "New Project"
4. Import your GitHub repository
5. Configure:
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release --web-renderer html`
   - **Output Directory**: `build/web`
   - **Install Command**: Leave empty (Flutter SDK required in build environment)

**Option B: Vercel CLI**
```bash
cd /path/to/abhishek_time_table
vercel
```

Follow prompts:
- Link to existing project or create new
- Set up build settings as above

### 4.3 Environment Variables
In Vercel dashboard, add environment variables:
- `FLUTTER_VERSION`: `3.27.1` (or your Flutter version)

### 4.4 Deploy
```bash
# Manual deployment
vercel --prod

# Or push to GitHub (auto-deploys if connected)
git push origin main
```

## Step 5: Configure Custom Domain (Optional)

### 5.1 Add Domain in Vercel
1. Go to Project Settings → Domains
2. Add domain: `timetable.app` or your custom domain
3. Configure DNS records as instructed by Vercel

### 5.2 Update Firebase Authorized Domains
1. Firebase Console → Authentication → Settings
2. Authorized domains → Add `timetable.app`

### 5.3 Update Deep Links
Update AndroidManifest.xml and sharing service to use actual domain.

## Troubleshooting

### Issue: Build Fails
**Solution**: Ensure Flutter SDK is available in Vercel build environment. May need custom build image.

**Workaround**: Build locally and deploy static files:
```bash
flutter build web --release
vercel --prod build/web
```

### Issue: Firebase Not Connecting
**Solution**:
- Check `firebase-config.js` credentials
- Verify domain in Firebase authorized domains
- Check browser console for CORS errors

### Issue: Deep Links Not Working
**Solution**:
- Verify `vercel.json` rewrites configuration
- Test with full URL: `https://timetable.app/t/ABC123`
- Check Firebase hosting rules

### Issue: Assets Not Loading
**Solution**:
- Ensure `--base-href` is set correctly in build command
- Check Vercel logs for 404 errors
- Verify asset paths in `index.html`

## Performance Optimization

### 1. Enable Compression
Vercel automatically enables gzip/brotli compression.

### 2. Cache Assets
Assets cached via headers in `vercel.json`:
```json
{
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    }
  ]
}
```

### 3. Use HTML Renderer
HTML renderer has smaller bundle size than CanvasKit:
- HTML: ~2-3 MB
- CanvasKit: ~5-7 MB

### 4. Lazy Load Assets
Firebase and other libraries loaded only when needed.

## Monitoring & Analytics

### Firebase Analytics
Add to `index.html`:
```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-analytics-compat.js"></script>
<script>
  firebase.analytics();
</script>
```

### Vercel Analytics
Automatically enabled for Pro accounts.

## Maintenance

### Updating the App
1. Make changes locally
2. Test with `flutter run -d chrome`
3. Build: `flutter build web --release`
4. Deploy: `git push` or `vercel --prod`

### Rolling Back
In Vercel dashboard:
1. Deployments tab
2. Select previous deployment
3. Promote to production

## Security

### Firestore Rules (View-Only Web)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /timetables/{doc} {
      allow read: if true;  // Anyone can read
      allow write: if request.auth != null && !isWeb();  // Only mobile can write
    }
  }
}

function isWeb() {
  return request.auth.token.firebase.sign_in_provider == 'anonymous';
}
```

## Cost Estimation

### Vercel Free Tier Limits
- 100 GB bandwidth/month
- Unlimited deployments
- Automatic HTTPS
- Edge network (CDN)

**Estimated Usage**:
- App size: ~3 MB
- 10,000 visits/month = ~30 GB bandwidth
- Well within free tier ✅

### Firebase Free Tier
- 10GB/month storage
- 50K reads/day
- 20K writes/day (mostly from mobile)

## Web-Specific Features

### Platform Detection
App automatically detects web platform and:
- Shows "Download Android App" banner
- Disables edit/delete buttons
- Shows restriction messages
- Hides alert settings

### Responsive Design
- Mobile-first design
- Breakpoints: 600px, 900px, 1200px
- Touch-friendly targets (min 48x48)

## Next Steps

After web deployment:
1. Test on multiple browsers (Chrome, Firefox, Safari, Edge)
2. Test on mobile browsers
3. Monitor Vercel analytics
4. Set up error tracking (Sentry)
5. Configure SEO metadata
6. Submit to search engines

## Support

For deployment issues:
- Vercel: [vercel.com/docs](https://vercel.com/docs)
- Flutter Web: [flutter.dev/web](https://flutter.dev/web)
- Firebase: [firebase.google.com/docs/web](https://firebase.google.com/docs/web)

---

**Deployment Checklist**:
- [ ] Firebase web app configured
- [ ] Build succeeds locally
- [ ] Tested in browser locally
- [ ] Vercel project created
- [ ] Domain configured (if custom)
- [ ] Firebase rules updated
- [ ] Deep links tested
- [ ] Mobile browser tested
- [ ] Analytics configured
- [ ] Error monitoring set up
