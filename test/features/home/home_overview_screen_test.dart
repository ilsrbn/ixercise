import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/data/local_store.dart';
import 'package:ixercise/features/home/home_overview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home overview renders plans and does not show calories', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeOverviewScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calories'), findsNothing);
    expect(find.text('Nothing scheduled.'), findsOneWidget);
    expect(find.text(_todayLabel()), findsOneWidget);
    expect(find.textContaining('No trainings yet.'), findsOneWidget);
  });

  testWidgets('home overview shows today scheduled training in headline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kTrainingPlansKey: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'leg-day',
          'name': 'Leg Day',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'exerciseId': 'Squats',
              'mode': 'reps',
              'value': 12,
              'restSeconds': 30,
            },
          ],
        },
      ]),
      kSchedulesKey: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'planId': 'leg-day',
          'type': 'weekdays',
          'weekdays': <int>[DateTime.now().weekday],
          'time': '21:00',
        },
      ]),
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeOverviewScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled.'), findsNothing);
    expect(find.text('Leg Day\nat 21:00.'), findsOneWidget);
  });
}

String _todayLabel() {
  final DateTime now = DateTime.now();
  const List<String> weekdays = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  const List<String> months = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}
