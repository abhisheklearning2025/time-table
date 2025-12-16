#!/bin/bash

echo "🔨 Generating JSON Serialization Code"
echo "======================================"
echo ""

cd /Users/abhishekrati/Desktop/abhishek_time_table

echo "1️⃣ Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ CODE GENERATION SUCCESSFUL! ✅ ✅ ✅"
    echo ""
    echo "📝 Generated files:"
    ls -lh lib/data/models/*.g.dart 2>/dev/null || echo "No .g.dart files found"
else
    echo ""
    echo "❌ Code generation failed!"
    exit 1
fi
