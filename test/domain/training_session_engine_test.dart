import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_session_engine.dart';

void main() {
  test('timed exercise completes into rest when restSeconds > 0', () {
    final plan = TrainingPlan(
      id: 'p1',
      name: 'A',
      items: const [
        TrainingExercise(
          exerciseId: 'push',
          mode: ExerciseMode.time,
          value: 10,
          restSeconds: 15,
        ),
      ],
    );

    final engine = TrainingSessionEngine(plan);
    engine.tick(seconds: 10);

    expect(engine.state.status, SessionStatus.resting);
    expect(engine.state.remainingSeconds, 15);
  });

  test('rest auto-advances to next exercise', () {
    final plan = TrainingPlan(
      id: 'p2',
      name: 'B',
      items: const [
        TrainingExercise(
          exerciseId: 'push',
          mode: ExerciseMode.time,
          value: 10,
          restSeconds: 5,
        ),
        TrainingExercise(
          exerciseId: 'squat',
          mode: ExerciseMode.reps,
          value: 12,
          restSeconds: 0,
        ),
      ],
    );

    final engine = TrainingSessionEngine(plan);
    engine.tick(seconds: 10);
    engine.tick(seconds: 5);

    expect(engine.state.status, SessionStatus.running);
    expect(engine.state.currentIndex, 1);
    expect(engine.state.remainingSeconds, isNull);
  });

  test('reps item requires manual completion and then ends session', () {
    final plan = TrainingPlan(
      id: 'p3',
      name: 'C',
      items: const [
        TrainingExercise(
          exerciseId: 'plank',
          mode: ExerciseMode.reps,
          value: 20,
          restSeconds: 0,
        ),
      ],
    );

    final engine = TrainingSessionEngine(plan);

    engine.tick(seconds: 30);
    expect(engine.state.status, SessionStatus.running);

    engine.completeCurrentReps();
    expect(engine.state.status, SessionStatus.done);
  });
}
