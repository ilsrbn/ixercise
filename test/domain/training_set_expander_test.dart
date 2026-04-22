import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_set_expander.dart';

void main() {
  const sequence = <TrainingExercise>[
    TrainingExercise(
      exerciseId: 'A',
      mode: ExerciseMode.reps,
      value: 10,
      restSeconds: 20,
    ),
    TrainingExercise(
      exerciseId: 'B',
      mode: ExerciseMode.time,
      value: 30,
      restSeconds: 15,
    ),
    TrainingExercise(
      exerciseId: 'C',
      mode: ExerciseMode.reps,
      value: 12,
      restSeconds: 10,
    ),
  ];

  test('interleaves exercise sets by cycle', () {
    const twoExerciseSequence = <TrainingExercise>[
      TrainingExercise(exerciseId: 'A', mode: ExerciseMode.reps, value: 10),
      TrainingExercise(exerciseId: 'B', mode: ExerciseMode.reps, value: 12),
    ];

    final expanded = interleaveTrainingSets(
      sequence: twoExerciseSequence,
      setCounts: <int>[2, 2],
    );

    expect(_ids(expanded), <String>['A', 'B', 'A', 'B']);
  });

  test('keeps lower-set exercises only in early cycles', () {
    const twoExerciseSequence = <TrainingExercise>[
      TrainingExercise(exerciseId: 'A', mode: ExerciseMode.reps, value: 10),
      TrainingExercise(exerciseId: 'B', mode: ExerciseMode.reps, value: 12),
    ];

    final expanded = interleaveTrainingSets(
      sequence: twoExerciseSequence,
      setCounts: <int>[3, 1],
    );

    expect(_ids(expanded), <String>['A', 'B', 'A', 'A']);
  });

  test('supports A x3, B x3, C x2', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[3, 3, 2],
    );

    expect(_ids(expanded), <String>['A', 'B', 'C', 'A', 'B', 'C', 'A', 'B']);
  });

  test('supports A x2, B x3, C x2', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[2, 3, 2],
    );

    expect(_ids(expanded), <String>['A', 'B', 'C', 'A', 'B', 'C', 'B']);
  });

  test('supports A x3, B x2, C x3', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[3, 2, 3],
    );

    expect(_ids(expanded), <String>['A', 'B', 'C', 'A', 'B', 'C', 'A', 'C']);
  });

  test('supports one exercise with multiple sets', () {
    const single = <TrainingExercise>[
      TrainingExercise(exerciseId: 'A', mode: ExerciseMode.reps, value: 10),
    ];

    final expanded = interleaveTrainingSets(
      sequence: single,
      setCounts: <int>[4],
    );

    expect(_ids(expanded), <String>['A', 'A', 'A', 'A']);
  });

  test('keeps original exercise order when later exercises have more sets', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[1, 2, 4],
    );

    expect(_ids(expanded), <String>['A', 'B', 'C', 'B', 'C', 'C', 'C']);
  });

  test('clamps zero and negative set counts to one set', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[0, -2, 2],
    );

    expect(_ids(expanded), <String>['A', 'B', 'C', 'C']);
  });

  test('returns empty queue for empty sequence', () {
    final expanded = interleaveTrainingSets(
      sequence: const <TrainingExercise>[],
      setCounts: const <int>[],
    );

    expect(expanded, isEmpty);
  });

  test('preserves exercise configuration for every expanded set', () {
    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[2, 1, 1],
    );

    expect(expanded, hasLength(4));
    expect(expanded[0].exerciseId, 'A');
    expect(expanded[0].mode, ExerciseMode.reps);
    expect(expanded[0].value, 10);
    expect(expanded[0].restSeconds, 20);
    expect(expanded[1].exerciseId, 'B');
    expect(expanded[1].mode, ExerciseMode.time);
    expect(expanded[1].value, 30);
    expect(expanded[1].restSeconds, 15);
    expect(expanded[2].exerciseId, 'C');
    expect(expanded[2].mode, ExerciseMode.reps);
    expect(expanded[2].value, 12);
    expect(expanded[2].restSeconds, 10);
    expect(expanded[3].exerciseId, 'A');
    expect(expanded[3].mode, ExerciseMode.reps);
    expect(expanded[3].value, 10);
    expect(expanded[3].restSeconds, 20);
  });
}

List<String> _ids(List<TrainingExercise> items) =>
    items.map((TrainingExercise item) => item.exerciseId).toList();
