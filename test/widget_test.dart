import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/data/local_store.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/live_activity/live_activity_coordinator.dart';
import 'package:ixercise/features/notifications/training_reminder_service.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ixercise/app/shell.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kLocaleKey: 'en',
    });
  });

  testWidgets('app boots into onboarding when no trainings are saved', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Set up your\ntraining flow.'), findsOneWidget);
  });

  testWidgets('app boots into home when trainings are saved', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kLocaleKey: 'en',
      kTrainingPlansKey: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'saved-plan',
          'name': 'Saved Training',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'exerciseId': 'pushups',
              'mode': 'reps',
              'value': 10,
              'restSeconds': 30,
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Saved Training'), findsOneWidget);
    expect(find.text('Set up your\ntraining flow.'), findsNothing);
  });
}

ProviderScope _app() {
  return ProviderScope(
    overrides: <Override>[
      trainingReminderServiceProvider.overrideWithValue(
        const _FakeTrainingReminderCoordinator(),
      ),
      liveActivityCoordinatorProvider.overrideWithValue(
        const _FakeLiveActivityCoordinator(),
      ),
    ],
    child: IxerciseApp(),
  );
}

class _FakeTrainingReminderCoordinator implements TrainingReminderCoordinator {
  const _FakeTrainingReminderCoordinator();

  @override
  Future<void> syncAll({
    required List<TrainingPlan> plans,
    required Map<String, Map<String, dynamic>> schedulesByPlanId,
  }) async {}
}

class _FakeLiveActivityCoordinator implements LiveActivityCoordinator {
  const _FakeLiveActivityCoordinator();

  @override
  Future<void> sync(SessionUiState? previous, SessionUiState next) async {}
}
