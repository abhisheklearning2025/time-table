import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abhishek_time_table/core/utils/time_helper.dart';
import 'package:abhishek_time_table/data/models/activity.dart';
import 'package:abhishek_time_table/data/models/category.dart';

void main() {
  group('TimeHelper - getCurrentActivity', () {
    final testCategory = Category(
      id: 'test',
      name: 'Test Category',
      color: const Color(0xFF000000),
    );

    test('returns correct activity for current time', () {
      final activities = [
        Activity(
          id: '1',
          time: '9:00 AM',
          endTime: '10:00 AM',
          startMinutes: 540, // 9:00 AM
          endMinutes: 600, // 10:00 AM
          duration: '1h',
          title: 'Morning Activity',
          description: '',
          category: testCategory,
          icon: '📅',
          isNextDay: false,
          timetableId: 'test-table',
        ),
        Activity(
          id: '2',
          time: '10:00 AM',
          endTime: '11:00 AM',
          startMinutes: 600, // 10:00 AM
          endMinutes: 660, // 11:00 AM
          duration: '1h',
          title: 'Mid Morning Activity',
          description: '',
          category: testCategory,
          icon: '📅',
          isNextDay: false,
          timetableId: 'test-table',
        ),
      ];

      // Test at 9:30 AM (570 minutes)
      final now = DateTime(2024, 1, 1, 9, 30);
      final result = TimeHelper.getCurrentActivity(now, activities);

      expect(result, isNotNull);
      expect(result?.title, 'Morning Activity');
    });

    test('returns null when no activity is active', () {
      final activities = [
        Activity(
          id: '1',
          time: '9:00 AM',
          endTime: '10:00 AM',
          startMinutes: 540,
          endMinutes: 600,
          duration: '1h',
          title: 'Morning Activity',
          description: '',
          category: testCategory,
          icon: '📅',
          isNextDay: false,
          timetableId: 'test-table',
        ),
      ];

      // Test at 8:00 AM (480 minutes) - before any activity
      final now = DateTime(2024, 1, 1, 8, 0);
      final result = TimeHelper.getCurrentActivity(now, activities);

      expect(result, isNull);
    });

    test('handles midnight crossing activities correctly', () {
      final activities = [
        Activity(
          id: '1',
          time: '11:00 PM',
          endTime: '1:00 AM',
          startMinutes: 1380, // 11:00 PM
          endMinutes: 60, // 1:00 AM next day
          duration: '2h',
          title: 'Late Night Activity',
          description: '',
          category: testCategory,
          icon: '📅',
          isNextDay: true,
          timetableId: 'test-table',
        ),
      ];

      // Test at 11:30 PM (1410 minutes)
      final now = DateTime(2024, 1, 1, 23, 30);
      final result = TimeHelper.getCurrentActivity(now, activities);

      expect(result, isNotNull);
      expect(result?.title, 'Late Night Activity');
      expect(result?.isNextDay, true);
    });

    test('handles midnight crossing - early morning check', () {
      final activities = [
        Activity(
          id: '1',
          time: '11:00 PM',
          endTime: '1:00 AM',
          startMinutes: 1380,
          endMinutes: 60,
          duration: '2h',
          title: 'Late Night Activity',
          description: '',
          category: testCategory,
          icon: '📅',
          isNextDay: true,
          timetableId: 'test-table',
        ),
      ];

      // Test at 12:30 AM (30 minutes)
      final now = DateTime(2024, 1, 1, 0, 30);
      final result = TimeHelper.getCurrentActivity(now, activities);

      expect(result, isNotNull);
      expect(result?.title, 'Late Night Activity');
    });

    test('returns empty list for empty activities', () {
      final activities = <Activity>[];
      final now = DateTime(2024, 1, 1, 9, 30);
      final result = TimeHelper.getCurrentActivity(now, activities);

      expect(result, isNull);
    });
  });

  group('TimeHelper - getTimeRemaining', () {
    final testCategory = Category(
      id: 'test',
      name: 'Test Category',
      color: const Color(0xFF000000),
    );

    test('calculates remaining time correctly', () {
      final activity = Activity(
        id: '1',
        time: '9:00 AM',
        endTime: '10:00 AM',
        startMinutes: 540,
        endMinutes: 600,
        duration: '1h',
        title: 'Morning Activity',
        description: '',
        category: testCategory,
        icon: '📅',
        isNextDay: false,
        timetableId: 'test-table',
      );

      // Test at 9:30 AM - should have 30 minutes remaining
      final now = DateTime(2024, 1, 1, 9, 30);
      final remaining = TimeHelper.getTimeRemaining(now, activity);

      expect(remaining, 30);
    });

    test('returns 0 when activity has ended', () {
      final activity = Activity(
        id: '1',
        time: '9:00 AM',
        endTime: '10:00 AM',
        startMinutes: 540,
        endMinutes: 600,
        duration: '1h',
        title: 'Morning Activity',
        description: '',
        category: testCategory,
        icon: '📅',
        isNextDay: false,
        timetableId: 'test-table',
      );

      // Test at 10:30 AM - activity has ended
      final now = DateTime(2024, 1, 1, 10, 30);
      final remaining = TimeHelper.getTimeRemaining(now, activity);

      expect(remaining, 0);
    });

    test('handles midnight crossing correctly', () {
      final activity = Activity(
        id: '1',
        time: '11:00 PM',
        endTime: '1:00 AM',
        startMinutes: 1380,
        endMinutes: 60,
        duration: '2h',
        title: 'Late Night Activity',
        description: '',
        category: testCategory,
        icon: '📅',
        isNextDay: true,
        timetableId: 'test-table',
      );

      // Test at 11:30 PM - should have 90 minutes remaining (to 1:00 AM)
      final now = DateTime(2024, 1, 1, 23, 30);
      final remaining = TimeHelper.getTimeRemaining(now, activity);

      expect(remaining, 90);
    });

    test('handles midnight crossing in early morning', () {
      final activity = Activity(
        id: '1',
        time: '11:00 PM',
        endTime: '1:00 AM',
        startMinutes: 1380,
        endMinutes: 60,
        duration: '2h',
        title: 'Late Night Activity',
        description: '',
        category: testCategory,
        icon: '📅',
        isNextDay: true,
        timetableId: 'test-table',
      );

      // Test at 12:30 AM - should have 30 minutes remaining
      final now = DateTime(2024, 1, 1, 0, 30);
      final remaining = TimeHelper.getTimeRemaining(now, activity);

      expect(remaining, 30);
    });
  });

  group('TimeHelper - formatDuration', () {
    test('formats hours and minutes correctly', () {
      expect(TimeHelper.formatDuration(90), '1h 30m');
      expect(TimeHelper.formatDuration(120), '2h');
      expect(TimeHelper.formatDuration(45), '45m');
      expect(TimeHelper.formatDuration(60), '1h');
      expect(TimeHelper.formatDuration(0), '0m');
    });

    test('handles edge cases', () {
      expect(TimeHelper.formatDuration(1), '1m');
      expect(TimeHelper.formatDuration(59), '59m');
      expect(TimeHelper.formatDuration(61), '1h 1m');
      expect(TimeHelper.formatDuration(1439), '23h 59m'); // Almost a full day
    });
  });
}
