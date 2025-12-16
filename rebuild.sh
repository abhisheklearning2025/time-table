#!/bin/bash

echo "🔄 Rebuilding and Installing TimeTable App"
echo "=========================================="
echo ""

# Step 1: Clean
echo "1️⃣ Cleaning project..."
flutter clean
if [ $? -ne 0 ]; then
    echo "❌ Clean failed!"
    exit 1
fi
echo "✅ Clean complete"
echo ""

# Step 2: Get dependencies
echo "2️⃣ Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Pub get failed!"
    exit 1
fi
echo "✅ Dependencies fetched"
echo ""

# Step 3: Build APK
echo "3️⃣ Building debug APK..."
flutter build apk --debug
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ APK built successfully"
echo ""

# Step 4: Install on device
echo "4️⃣ Installing on device..."
flutter install --debug
if [ $? -ne 0 ]; then
    echo "❌ Install failed! Make sure device is connected."
    echo ""
    echo "You can manually install with:"
    echo "  adb install -r build/app/outputs/flutter-apk/app-debug.apk"
    exit 1
fi

echo ""
echo "✅ ✅ ✅ SUCCESS! ✅ ✅ ✅"
echo ""
echo "📱 App installed and ready to launch!"
echo ""
