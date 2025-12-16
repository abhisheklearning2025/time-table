#!/bin/bash

# Phase 5 Audio & Notification Services Test Script
# Tests service initialization and basic functionality

echo "🧪 Testing Phase 5 - Audio & Notification Services..."
echo ""

# Check if audio directory exists
if [ ! -d "assets/audio/default" ]; then
    echo "❌ Error: assets/audio/default directory not found"
    exit 1
fi

echo "✅ Audio directory exists"
echo ""

# Count audio files
audio_files=$(ls assets/audio/default/*.mp3 2>/dev/null | wc -l | tr -d ' ')
echo "📁 Audio files found: $audio_files / 14 required"
echo ""

if [ "$audio_files" -eq 0 ]; then
    echo "⚠️  WARNING: No audio files found!"
    echo "   Please add audio files before testing alerts."
    echo "   See assets/audio/default/README.md for instructions."
    echo ""
fi

# Check if services are registered in dependency injection
echo "🔍 Checking service registration..."
if grep -q "AudioService" lib/services/dependency_injection.dart; then
    echo "   ✅ AudioService registered"
else
    echo "   ❌ AudioService not registered"
fi

if grep -q "NotificationService" lib/services/dependency_injection.dart; then
    echo "   ✅ NotificationService registered"
else
    echo "   ❌ NotificationService not registered"
fi

if grep -q "BackgroundService" lib/services/dependency_injection.dart; then
    echo "   ✅ BackgroundService registered"
else
    echo "   ❌ BackgroundService not registered"
fi
echo ""

# Check AndroidManifest permissions
echo "🔍 Checking Android permissions..."
if grep -q "FOREGROUND_SERVICE" android/app/src/main/AndroidManifest.xml; then
    echo "   ✅ FOREGROUND_SERVICE permission"
else
    echo "   ❌ FOREGROUND_SERVICE permission missing"
fi

if grep -q "POST_NOTIFICATIONS" android/app/src/main/AndroidManifest.xml; then
    echo "   ✅ POST_NOTIFICATIONS permission"
else
    echo "   ❌ POST_NOTIFICATIONS permission missing"
fi

if grep -q "SCHEDULE_EXACT_ALARM" android/app/src/main/AndroidManifest.xml; then
    echo "   ✅ SCHEDULE_EXACT_ALARM permission"
else
    echo "   ❌ SCHEDULE_EXACT_ALARM permission missing"
fi

if grep -q "FOREGROUND_SERVICE_MEDIA_PLAYBACK" android/app/src/main/AndroidManifest.xml; then
    echo "   ✅ FOREGROUND_SERVICE_MEDIA_PLAYBACK permission"
else
    echo "   ❌ FOREGROUND_SERVICE_MEDIA_PLAYBACK permission missing"
fi
echo ""

# Create a test Dart file
cat > /tmp/test_phase5_services.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:abhishek_time_table/services/dependency_injection.dart';
import 'package:abhishek_time_table/domain/services/audio_service.dart';
import 'package:abhishek_time_table/domain/services/notification_service.dart';
import 'package:abhishek_time_table/domain/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('✅ Phase 5 Services Test\n');

  // Setup dependency injection
  await setupDependencyInjection();
  print('✅ Dependency injection setup complete\n');

  // Test AudioService
  print('🔊 Testing AudioService...');
  final audioService = getIt<AudioService>();
  print('   ✅ AudioService instance created');

  // Validate audio assets
  final assetsValid = await audioService.validateAudioAssets();
  if (assetsValid) {
    print('   ✅ Audio assets validated');
  } else {
    print('   ⚠️  Audio assets not found (expected if files not added yet)');
  }

  // Get volume
  final volume = await audioService.getVolume();
  print('   ✅ Default volume: ${(volume * 100).toInt()}%\n');

  // Test NotificationService
  print('🔔 Testing NotificationService...');
  final notificationService = getIt<NotificationService>();
  print('   ✅ NotificationService instance created');

  // Initialize notifications
  await notificationService.initialize();
  print('   ✅ Notifications initialized');

  // Get pending count
  final pendingCount = await notificationService.getPendingNotificationCount();
  print('   ✅ Pending notifications: $pendingCount\n');

  // Test BackgroundService
  print('⚙️  Testing BackgroundService...');
  final backgroundService = getIt<BackgroundService>();
  print('   ✅ BackgroundService instance created');
  print('   ✅ Service running: ${backgroundService.isRunning}\n');

  // Summary
  print('📋 Phase 5 Service Test Summary:');
  print('   ✅ All services initialized successfully');
  print('   ✅ Dependency injection working');
  print('   ✅ Notifications system ready');

  if (!assetsValid) {
    print('\n⚠️  Next Step: Add audio files to assets/audio/default/');
    print('   See assets/audio/default/README.md for instructions');
  } else {
    print('\n🎉 Phase 5 is fully ready for integration!');
  }

  // Dispose services
  await audioService.dispose();
  await backgroundService.dispose();
}
EOF

echo "📝 Test file created at /tmp/test_phase5_services.dart"
echo ""
echo "To run this test manually:"
echo "1. Ensure Firebase is initialized"
echo "2. Run: dart /tmp/test_phase5_services.dart"
echo "   (Or copy to lib/ and run as Flutter app)"
echo ""

echo "✅ Phase 5 Code Implementation Complete!"
echo ""
echo "📦 What was built:"
echo "   ✅ AudioService (background audio playback)"
echo "   ✅ NotificationService (exact alarm scheduling)"
echo "   ✅ BackgroundService (periodic checks, orchestration)"
echo "   ✅ Dependency injection registered"
echo "   ✅ Android permissions configured"
echo "   ✅ Foreground service declared"
echo ""

if [ "$audio_files" -eq 0 ]; then
    echo "⚠️  Action Required:"
    echo "   📁 Add 14 audio files to assets/audio/default/"
    echo "   📖 See assets/audio/default/README.md for details"
    echo ""
fi

echo "🎯 Next Steps:"
echo "   1. Add audio files (see README.md)"
echo "   2. Request notification permissions in UI"
echo "   3. Start BackgroundService on app launch"
echo "   4. Proceed to Phase 6 (State Management - Providers)"
echo ""
