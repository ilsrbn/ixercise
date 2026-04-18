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

    final store = const LocalStore();

    expect(await store.loadTrainingPlans(), isEmpty);
    expect(await store.loadSelectedExercises(), isEmpty);
    expect(await store.loadSchedules(), isEmpty);
  });

  test('save and load training plans roundtrip', () async {
    final store = const LocalStore();
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
}
