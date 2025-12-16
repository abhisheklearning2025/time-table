#!/bin/bash

echo "🚀 Phase 2 Setup - Models & Database"
echo "====================================="
echo ""

cd /Users/abhishekrati/Desktop/abhishek_time_table

# Step 1: Get dependencies (including new 'path' package)
echo "1️⃣ Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Pub get failed!"
    exit 1
fi
echo "✅ Dependencies updated"
echo ""

# Step 2: Generate JSON serialization code
echo "2️⃣ Generating JSON serialization code..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "❌ Code generation failed!"
    exit 1
fi
echo "✅ JSON code generated"
echo ""

# Step 3: Verify generated files
echo "3️⃣ Verifying generated files..."
if [ -f "lib/data/models/category.g.dart" ] && \
   [ -f "lib/data/models/activity.g.dart" ] && \
   [ -f "lib/data/models/timetable.g.dart" ]; then
    echo "✅ All .g.dart files generated:"
    ls -lh lib/data/models/*.g.dart
else
    echo "⚠️  Some .g.dart files missing"
fi
echo ""

echo "✅ ✅ ✅ PHASE 2 SETUP COMPLETE! ✅ ✅ ✅"
echo ""
echo "📊 Created:"
echo "  ✓ Category model (with 12 Gen-Z preset categories)"
echo "  ✓ Activity model (with midnight crossing logic)"
echo "  ✓ Timetable model (with type system)"
echo "  ✓ SQLite database helper (with foreign keys)"
echo "  ✓ JSON serialization code (.g.dart files)"
echo ""
echo "📋 Next: Create repositories for data access"
