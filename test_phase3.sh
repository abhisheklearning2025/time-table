#!/bin/bash

echo "🧪 Testing Phase 3 - Auth & Sharing Services"
echo "=============================================="
echo ""

cd /Users/abhishekrati/Desktop/abhishek_time_table

# Step 1: Clean and get dependencies
echo "1️⃣ Cleaning and updating dependencies..."
flutter clean
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Pub get failed!"
    exit 1
fi
echo "✅ Dependencies updated"
echo ""

# Step 2: Build APK
echo "2️⃣ Building APK..."
flutter build apk --debug
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ APK built"
echo ""

# Step 3: Install on device
echo "3️⃣ Installing on device..."
flutter install --debug
if [ $? -ne 0 ]; then
    echo "⚠️  Install failed. You can install manually:"
    echo "   adb install -r build/app/outputs/flutter-apk/app-debug.apk"
fi

echo ""
echo "✅ ✅ ✅ PHASE 3 READY TO TEST! ✅ ✅ ✅"
echo ""
echo "📱 What to Test:"
echo "  1. Launch app - should auto sign-in anonymously"
echo "  2. Check logs for Firebase Auth success"
echo "  3. App should show placeholder UI (no errors)"
echo ""
echo "🔍 Check logs:"
echo "  adb logcat | grep -E 'Flutter|Firebase'"
echo ""
echo "📊 What's Ready:"
echo "  ✓ Firebase Anonymous Auth (auto sign-in)"
echo "  ✓ TimetableService (multi-timetable management)"
echo "  ✓ SharingService (export/import/QR/links)"
echo "  ✓ All repositories and services in DI"
echo ""
echo "📋 Next: Phase 4 (Templates) or Phase 5 (Audio/Notifications)"
