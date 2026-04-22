import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_set_expander.dart';

void main() {
  test('interleaves exercise sets by cycle', () {
    const sequence = <TrainingExercise>[
      TrainingExercise(exerciseId: 'A', mode: ExerciseMode.reps, value: 10),
      TrainingExercise(exerciseId: 'B', mode: ExerciseMode.reps, value: 12),
    ];

    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[2, 2],
    );

    expect(expanded.map((TrainingExercise item) => item.exerciseId), <String>[
      'A',
      'B',
      'A',
      'B',
    ]);
  });

  test('keeps lower-set exercises only in early cycles', () {
    const sequence = <TrainingExercise>[
      TrainingExercise(exerciseId: 'A', mode: ExerciseMode.reps, value: 10),
      TrainingExercise(exerciseId: 'B', mode: ExerciseMode.reps, value: 12),
    ];

    final expanded = interleaveTrainingSets(
      sequence: sequence,
      setCounts: <int>[3, 1],
    );

    expect(expanded.map((TrainingExercise item) => item.exerciseId), <String>[
      'A',
      'B',
      'A',
      'A',
    ]);
  });
}
