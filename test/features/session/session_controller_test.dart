import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/session/session_controller.dart';

void main() {
  test('complete action works while paused during reps exercise', () {
    final controller = SessionController(
      seedPlan: const TrainingPlan(
        id: 'p1',
        name: 'Paused reps',
        items: <TrainingExercise>[
          TrainingExercise(
            exerciseId: 'A',
            mode: ExerciseMode.reps,
            value: 10,
            restSeconds: 0,
          ),
        ],
      ),
    );

    controller.pauseResume();
    controller.completeOrNext();

    expect(controller.state.session.status, SessionStatus.done);
  });

  test('skip rest works while paused during rest', () {
    final controller = SessionController(
      seedPlan: const TrainingPlan(
        id: 'p2',
        name: 'Paused rest',
        items: <TrainingExercise>[
          TrainingExercise(
            exerciseId: 'A',
            mode: ExerciseMode.time,
            value: 5,
            restSeconds: 20,
          ),
          TrainingExercise(
            exerciseId: 'B',
            mode: ExerciseMode.reps,
            value: 8,
            restSeconds: 0,
          ),
        ],
      ),
    );

    controller.tick(seconds: 5);
    expect(controller.state.session.status, SessionStatus.resting);

    controller.pauseResume();
    controller.skipRest();

    expect(controller.state.session.status, SessionStatus.running);
    expect(controller.state.session.currentIndex, 1);
    expect(controller.state.currentItem.exerciseId, 'B');
  });
}
