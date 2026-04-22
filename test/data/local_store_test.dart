import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/data/local_store.dart';
import 'package:ixercise/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('invalid json payload falls back to defaults', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kTrainingPlansKey: '{invalid json',
      kSelectedExercisesKey: '{also invalid',
      kSchedulesKey: '{"bad":true}',
    });

    const store = LocalStore();

    expect(await store.loadTrainingPlans(), isEmpty);
    expect(await store.loadSelectedExercises(), isEmpty);
    expect(await store.loadSchedules(), isEmpty);
  });

  test('save and load training plans roundtrip', () async {
    const store = LocalStore();
    final plans = <TrainingPlan>[
      const TrainingPlan(
        id: 'p1',
        name: 'Starter',
        items: <TrainingExercise>[
          TrainingExercise(
            exerciseId: 'pushups',
            mode: ExerciseMode.time,
            value: 20,
            restSeconds: 10,
          ),
        ],
      ),
    ];

    await store.saveTrainingPlans(plans);
    final loaded = await store.loadTrainingPlans();

    expect(loaded, hasLength(1));
    expect(loaded.first.id, 'p1');
    expect(loaded.first.items.first.restSeconds, 10);
  });

  test('save and load feedback settings roundtrip', () async {
    const store = LocalStore();
    const settings = <String, dynamic>{
      'soundEffectsEnabled': false,
      'hapticsEnabled': true,
      'countdownTicksEnabled': false,
      'trainingRemindersEnabled': true,
      'reminderOffsetMinutes': 15,
      'volume': 0.4,
      'themeMode': 'dark',
    };

    await store.saveFeedbackSettings(settings);
    final loaded = await store.loadFeedbackSettings();

    expect(loaded['soundEffectsEnabled'], isFalse);
    expect(loaded['hapticsEnabled'], isTrue);
    expect(loaded['countdownTicksEnabled'], isFalse);
    expect(loaded['trainingRemindersEnabled'], isTrue);
    expect(loaded['reminderOffsetMinutes'], 15);
    expect(loaded['volume'], 0.4);
    expect(loaded['themeMode'], 'dark');
  });

  test('save and load training reminder ids roundtrip', () async {
    const store = LocalStore();

    await store.saveTrainingReminderIds(<int>[101, 202, 303]);
    final List<int> loaded = await store.loadTrainingReminderIds();

    expect(loaded, <int>[101, 202, 303]);
  });
}
