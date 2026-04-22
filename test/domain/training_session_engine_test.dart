import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_session_engine.dart';
import 'package:ixercise/domain/training_set_expander.dart';

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

  test(
    'wall-clock reconciliation advances timed exercise while app is locked',
    () {
      final DateTime startedAt = DateTime(2026, 4, 22, 14, 0);
      final plan = TrainingPlan(
        id: 'p-clock',
        name: 'Clock',
        items: const [
          TrainingExercise(
            exerciseId: 'jump',
            mode: ExerciseMode.time,
            value: 30,
            restSeconds: 10,
          ),
          TrainingExercise(
            exerciseId: 'push',
            mode: ExerciseMode.reps,
            value: 10,
            restSeconds: 0,
          ),
        ],
      );

      final engine = TrainingSessionEngine(plan, startedAt: startedAt);
      engine.reconcileTo(startedAt.add(const Duration(seconds: 35)));

      expect(engine.state.status, SessionStatus.resting);
      expect(engine.state.remainingSeconds, 5);
      expect(engine.state.elapsedSeconds, 35);
    },
  );

  test('wall-clock reconciliation can cross rest into next exercise', () {
    final DateTime startedAt = DateTime(2026, 4, 22, 14, 0);
    final plan = TrainingPlan(
      id: 'p-cross',
      name: 'Cross',
      items: const [
        TrainingExercise(
          exerciseId: 'jump',
          mode: ExerciseMode.time,
          value: 30,
          restSeconds: 10,
        ),
        TrainingExercise(
          exerciseId: 'push',
          mode: ExerciseMode.reps,
          value: 10,
          restSeconds: 0,
        ),
      ],
    );

    final engine = TrainingSessionEngine(plan, startedAt: startedAt);
    engine.reconcileTo(startedAt.add(const Duration(seconds: 45)));

    expect(engine.state.status, SessionStatus.running);
    expect(engine.state.currentIndex, 1);
    expect(engine.state.remainingSeconds, isNull);
    expect(engine.state.elapsedSeconds, 45);
  });

  test('paused wall-clock time does not consume timer', () {
    final DateTime startedAt = DateTime(2026, 4, 22, 14, 0);
    final plan = TrainingPlan(
      id: 'p-pause',
      name: 'Pause',
      items: const [
        TrainingExercise(
          exerciseId: 'jump',
          mode: ExerciseMode.time,
          value: 30,
          restSeconds: 0,
        ),
      ],
    );

    final engine = TrainingSessionEngine(plan, startedAt: startedAt);
    final DateTime pausedAt = startedAt.add(const Duration(seconds: 5));
    engine.pause(now: pausedAt);
    engine.reconcileTo(pausedAt.add(const Duration(minutes: 10)));
    engine.resume(now: pausedAt.add(const Duration(minutes: 10)));
    engine.reconcileTo(pausedAt.add(const Duration(minutes: 10, seconds: 5)));

    expect(engine.state.status, SessionStatus.running);
    expect(engine.state.remainingSeconds, 20);
    expect(engine.state.elapsedSeconds, 10);
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

  test(
    'interleaved multi-set plan advances in saved order and skips final rest',
    () {
      const items = <TrainingExercise>[
        TrainingExercise(
          exerciseId: 'A',
          mode: ExerciseMode.reps,
          value: 10,
          restSeconds: 20,
        ),
        TrainingExercise(
          exerciseId: 'B',
          mode: ExerciseMode.reps,
          value: 12,
          restSeconds: 20,
        ),
        TrainingExercise(
          exerciseId: 'A',
          mode: ExerciseMode.reps,
          value: 10,
          restSeconds: 20,
        ),
        TrainingExercise(
          exerciseId: 'B',
          mode: ExerciseMode.reps,
          value: 12,
          restSeconds: 20,
        ),
      ];
      final engine = TrainingSessionEngine(
        const TrainingPlan(id: 'p4', name: 'Sets', items: items),
      );
      final visited = <String>[];

      for (int i = 0; i < items.length; i++) {
        visited.add(engine.currentItem.exerciseId);
        engine.completeCurrentReps();
        if (i < items.length - 1) {
          expect(engine.state.status, SessionStatus.resting);
          engine.skipRest();
        }
      }

      expect(visited, <String>['A', 'B', 'A', 'B']);
      expect(engine.state.status, SessionStatus.done);
    },
  );

  test(
    'runs uneven expanded set queue without reordering after first cycle',
    () {
      const baseSequence = <TrainingExercise>[
        TrainingExercise(
          exerciseId: 'A',
          mode: ExerciseMode.reps,
          value: 10,
          restSeconds: 20,
        ),
        TrainingExercise(
          exerciseId: 'B',
          mode: ExerciseMode.reps,
          value: 12,
          restSeconds: 20,
        ),
        TrainingExercise(
          exerciseId: 'C',
          mode: ExerciseMode.reps,
          value: 14,
          restSeconds: 20,
        ),
      ];
      final items = interleaveTrainingSets(
        sequence: baseSequence,
        setCounts: <int>[3, 2, 3],
      );
      final engine = TrainingSessionEngine(
        TrainingPlan(id: 'p5', name: 'Uneven sets', items: items),
      );

      final visited = _completeRepsQueue(engine);

      expect(visited, <String>['A', 'B', 'C', 'A', 'B', 'C', 'A', 'C']);
      expect(engine.state.status, SessionStatus.done);
      expect(engine.state.currentIndex, items.length - 1);
    },
  );
}

List<String> _completeRepsQueue(TrainingSessionEngine engine) {
  final visited = <String>[];

  while (engine.state.status != SessionStatus.done) {
    expect(engine.state.status, SessionStatus.running);
    visited.add(engine.currentItem.exerciseId);
    engine.completeCurrentReps();
    if (engine.state.status == SessionStatus.resting) {
      engine.skipRest();
    }
  }

  return visited;
}
