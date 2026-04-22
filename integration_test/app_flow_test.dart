import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ixercise/app/shell.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/live_activity/live_activity_coordinator.dart';
import 'package:ixercise/features/notifications/training_reminder_service.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/session/session_feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('creates a training, completes it, and returns home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(_testApp());
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('training_save_button')),
    );

    expect(find.text('Set up your\ntraining flow.'), findsOneWidget);

    await _editFirstExerciseToBodyweightSquats(tester);
    expect(find.text('Bodyweight squats'), findsOneWidget);
    expect(find.textContaining('4 sets'), findsOneWidget);
    expect(find.textContaining('12 reps'), findsOneWidget);
    expect(find.textContaining('30s rest'), findsOneWidget);

    await _addTimerExercise(tester);
    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('2 sets · 30s work · 15s rest'), findsOneWidget);

    await tester.dragFrom(
      tester.getCenter(find.byKey(const Key('setup_exercise_drag_1'))),
      const Offset(0, -260),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Plank')).dy,
      lessThan(tester.getTopLeft(find.text('Bodyweight squats')).dy),
    );

    await _addExerciseBySearch(
      tester,
      'jumping',
      'exercise_option_jumping_jacks',
    );
    expect(find.text('Jumping jacks'), findsOneWidget);

    await tester.drag(find.text('Bodyweight squats'), const Offset(-120, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('setup_exercise_delete_action')).hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bodyweight squats'), findsNothing);
    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('Jumping jacks'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('setup_schedule_row')));
    await tester.tap(find.byKey(const Key('setup_schedule_row')).hitTestable());
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('schedule_custom_choice')),
    );
    await _tapKey(tester, 'schedule_custom_choice');
    await _pumpUntilFound(tester, find.byKey(const Key('schedule_day_2')));
    await _tapKey(tester, 'schedule_day_2');
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('schedule_editor_apply')).hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Custom'), findsOneWidget);
    expect(find.textContaining('07:30'), findsOneWidget);

    await tester.tap(find.byKey(const Key('training_save_button')));
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('home_start_training')).hitTestable(),
    );

    expect(find.text('Ixercise'), findsOneWidget);
    expect(find.text('My First Training'), findsAtLeastNWidgets(1));

    await tester.tap(
      find.byKey(const Key('home_start_training')).hitTestable(),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('run_next_button')).hitTestable(),
    );

    expect(find.text('Training Run', skipOffstage: false), findsOneWidget);

    await _completeTraining(tester);

    expect(find.text('Done.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('done_back_home')).hitTestable());
    await _pumpUntilFound(tester, find.text('Ixercise'));

    expect(find.text('Ixercise'), findsOneWidget);
    expect(find.text('My First Training'), findsAtLeastNWidgets(1));
  });
}

Future<void> _editFirstExerciseToBodyweightSquats(WidgetTester tester) async {
  await tester.tap(find.text('Push-ups').first);
  await _pumpUntilFound(tester, find.text('Edit exercise'));
  await tester.enterText(
    find.byKey(const Key('exercise_search_input')),
    'bodyweight',
  );
  await tester.pumpAndSettle();
  await _tapKey(tester, 'exercise_option_bodyweight_squats');
  await _tapKey(tester, 'exercise_sets_increment');
  await _tapKey(tester, 'exercise_reps_increment');
  await _tapKey(tester, 'exercise_reps_increment');
  await _tapKey(tester, 'exercise_rest_increment');
  await _tapKey(tester, 'exercise_rest_increment');
  await _tapKey(tester, 'exercise_editor_apply');
  await tester.pumpAndSettle();
}

Future<void> _addTimerExercise(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('training_add_exercise')));
  await _pumpUntilFound(tester, find.text('Edit exercise'));
  await tester.enterText(
    find.byKey(const Key('exercise_search_input')),
    'plank',
  );
  await tester.pumpAndSettle();
  await _tapKey(tester, 'exercise_option_plank');
  await _tapKey(tester, 'exercise_sets_decrement');
  await _tapKey(tester, 'exercise_mode_timer');
  for (int i = 0; i < 4; i += 1) {
    await _tapKey(tester, 'exercise_work_increment');
  }
  await _tapKey(tester, 'exercise_rest_decrement');
  await _tapKey(tester, 'exercise_editor_apply');
  await tester.pumpAndSettle();
}

Future<void> _addExerciseBySearch(
  WidgetTester tester,
  String query,
  String optionKey,
) async {
  await tester.tap(find.byKey(const Key('training_add_exercise')));
  await _pumpUntilFound(tester, find.text('Edit exercise'));
  await tester.enterText(find.byKey(const Key('exercise_search_input')), query);
  await tester.pumpAndSettle();
  await _tapKey(tester, optionKey);
  await _tapKey(tester, 'exercise_editor_apply');
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)).hitTestable());
  await tester.pumpAndSettle();
}

Future<void> _completeTraining(WidgetTester tester) async {
  for (int i = 0; i < 20; i += 1) {
    if (find
        .byKey(const Key('done_back_home'))
        .hitTestable()
        .evaluate()
        .isNotEmpty) {
      return;
    }
    final Finder restSkip = find
        .byKey(const Key('rest_skip_button'))
        .hitTestable();
    if (restSkip.evaluate().isNotEmpty) {
      expect(find.text('Rest', skipOffstage: false), findsAtLeastNWidgets(1));
      await tester.tap(restSkip);
      await tester.pumpAndSettle();
      continue;
    }
    final Finder next = find.byKey(const Key('run_next_button')).hitTestable();
    if (next.evaluate().isNotEmpty) {
      await tester.tap(next);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await _pumpUntilFound(
    tester,
    find.byKey(const Key('done_back_home')).hitTestable(),
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}

ProviderScope _testApp() {
  return ProviderScope(
    overrides: <Override>[
      sessionFeedbackServiceProvider.overrideWith(_NoopSessionFeedback.new),
      trainingReminderServiceProvider.overrideWithValue(
        const _NoopTrainingReminderCoordinator(),
      ),
      liveActivityCoordinatorProvider.overrideWithValue(
        const _NoopLiveActivityCoordinator(),
      ),
    ],
    child: IxerciseApp(),
  );
}

class _NoopSessionFeedback extends SessionFeedbackService {
  _NoopSessionFeedback(super.ref);

  @override
  Future<void> handle(SessionUiState? previous, SessionUiState next) async {}
}

class _NoopTrainingReminderCoordinator implements TrainingReminderCoordinator {
  const _NoopTrainingReminderCoordinator();

  @override
  Future<void> syncAll({
    required List<TrainingPlan> plans,
    required Map<String, Map<String, dynamic>> schedulesByPlanId,
  }) async {}
}

class _NoopLiveActivityCoordinator implements LiveActivityCoordinator {
  const _NoopLiveActivityCoordinator();

  @override
  Future<void> sync(SessionUiState? previous, SessionUiState next) async {}
}
