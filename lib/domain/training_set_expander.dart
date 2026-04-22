import 'package:ixercise/domain/models.dart';

List<TrainingExercise> interleaveTrainingSets({
  required List<TrainingExercise> sequence,
  required List<int> setCounts,
}) {
  assert(
    sequence.length == setCounts.length,
    'Every exercise must have a matching set count',
  );
  if (sequence.isEmpty) {
    return <TrainingExercise>[];
  }

  final int maxSets = setCounts.fold<int>(
    1,
    (int max, int sets) => sets > max ? sets : max,
  );
  final List<TrainingExercise> expanded = <TrainingExercise>[];

  for (int setIndex = 0; setIndex < maxSets; setIndex++) {
    for (int i = 0; i < sequence.length; i++) {
      final int sets = setCounts[i] < 1 ? 1 : setCounts[i];
      if (setIndex < sets) {
        expanded.add(sequence[i]);
      }
    }
  }

  return expanded;
}
