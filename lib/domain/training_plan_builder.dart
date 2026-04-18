import 'package:ixercise/domain/models.dart';

TrainingPlan buildPlanFromExerciseIds({
  required String id,
  required String name,
  required List<String> exerciseIds,
}) {
  final List<String> unique = <String>{...exerciseIds}
      .where((String value) => value.trim().isNotEmpty)
      .toList(growable: false);

  final List<String> source = unique.isEmpty
      ? const <String>['Push-ups']
      : unique;
  final List<TrainingExercise> items = <TrainingExercise>[];

  for (int i = 0; i < source.length; i++) {
    final bool asTime = i.isEven;
    final int value = asTime ? 30 + ((i % 3) * 15) : 10 + ((i % 3) * 5);
    items.add(
      TrainingExercise(
        exerciseId: source[i],
        mode: asTime ? ExerciseMode.time : ExerciseMode.reps,
        value: value,
        restSeconds: i == source.length - 1 ? 0 : 20,
      ),
    );
  }

  return TrainingPlan(
    id: id,
    name: name,
    items: items,
  );
}
