import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abhishek_time_table/presentation/widgets/timetable/timetable_card.dart';
import 'package:abhishek_time_table/data/models/timetable.dart';
import 'package:abhishek_time_table/data/models/activity.dart';
import 'package:abhishek_time_table/data/models/category.dart';

void main() {
  group('TimetableCard Widget Tests', () {
    final testCategory = Category(
      id: 'test',
      name: 'Test Category',
      color: const Color(0xFF000000),
    );

    final testActivities = [
      Activity(
        id: '1',
        time: '9:00 AM',
        endTime: '10:00 AM',
        startMinutes: 540,
        endMinutes: 600,
        duration: '1h',
        title: 'Test Activity',
        description: 'Test Description',
        category: testCategory,
        icon: '📅',
        isNextDay: false,
        timetableId: 'test-table',
      ),
    ];

    final testTimetable = Timetable(
      id: 'test-table',
      name: 'Test Timetable',
      description: 'A test timetable',
      emoji: '📅',
      activities: testActivities,
      type: TimetableType.own,
      isActive: true,
      alertsEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublic: false,
    );

    Widget createTestWidget(Timetable timetable) {
      return MaterialApp(
        home: Scaffold(
          body: TimetableCard(
            timetable: timetable,
            onTap: () {},
          ),
        ),
      );
    }

    testWidgets('displays timetable name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      expect(find.text('Test Timetable'), findsOneWidget);
    });

    testWidgets('displays emoji when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      expect(find.text('📅'), findsWidgets);
    });

    testWidgets('displays activity count', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      expect(find.textContaining('1 activit'), findsOneWidget);
    });

    testWidgets('shows active badge when timetable is active',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('does not show active badge when showActiveBadge is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimetableCard(
              timetable: testTimetable,
              onTap: () {},
              showActiveBadge: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('triggers onTap callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimetableCard(
              timetable: testTimetable,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TimetableCard));
      expect(tapped, true);
    });

    testWidgets('displays description when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      expect(find.text('A test timetable'), findsOneWidget);
    });

    testWidgets('handles timetable without emoji', (WidgetTester tester) async {
      final timetableNoEmoji = testTimetable.copyWith(emoji: null);

      await tester.pumpWidget(createTestWidget(timetableNoEmoji));

      // Should still render without errors
      expect(find.text('Test Timetable'), findsOneWidget);
    });

    testWidgets('shows alert status indicator when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testTimetable));

      // Should show notifications icon for alerts enabled
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });
  });
}
