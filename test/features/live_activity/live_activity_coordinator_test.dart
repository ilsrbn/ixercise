import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/live_activity/live_activity_coordinator.dart';
import 'package:ixercise/features/session/session_controller.dart';

void main() {
  test('running timed exercise snapshot includes timer progress', () {
    final LiveActivitySnapshot snapshot = buildLiveActivitySnapshot(
      _state(
        status: SessionStatus.running,
        currentIndex: 0,
        remainingSeconds: 15,
      ),
    );

    expect(snapshot.sessionId, 'plan-a');
    expect(snapshot.planName, 'Plan A');
    expect(snapshot.phase, 'Training');
    expect(snapshot.title, 'Jumping jacks');
    expect(snapshot.subtitle, 'Timer');
    expect(snapshot.remainingSeconds, 15);
    expect(snapshot.totalSeconds, 30);
    expect(snapshot.progress, closeTo(0.25, 0.001));
    expect(snapshot.isPaused, isFalse);
  });

  test('rest snapshot names the next exercise', () {
    final LiveActivitySnapshot snapshot = buildLiveActivitySnapshot(
      _state(
        status: SessionStatus.resting,
        currentIndex: 0,
        remainingSeconds: 10,
      ),
    );

    expect(snapshot.phase, 'Rest');
    expect(snapshot.title, 'Rest');
    expect(snapshot.subtitle, 'Next: Push-ups');
    expect(snapshot.remainingSeconds, 10);
    expect(snapshot.totalSeconds, 20);
  });

  test('running reps snapshot shows target reps', () {
    final LiveActivitySnapshot snapshot = buildLiveActivitySnapshot(
      _state(
        status: SessionStatus.running,
        currentIndex: 1,
        remainingSeconds: null,
      ),
    );

    expect(snapshot.phase, 'Training');
    expect(snapshot.title, 'Push-ups');
    expect(snapshot.subtitle, '12 reps');
    expect(snapshot.remainingSeconds, isNull);
    expect(snapshot.totalSeconds, isNull);
    expect(snapshot.progress, closeTo(0.5, 0.001));
  });

  test('paused snapshot is marked paused', () {
    final LiveActivitySnapshot snapshot = buildLiveActivitySnapshot(
      _state(
        status: SessionStatus.paused,
        currentIndex: 0,
        remainingSeconds: 15,
      ),
    );

    expect(snapshot.phase, 'Paused');
    expect(snapshot.title, 'Jumping jacks');
    expect(snapshot.subtitle, 'Jumping jacks');
    expect(snapshot.isPaused, isTrue);
  });
}

SessionUiState _state({
  required SessionStatus status,
  required int currentIndex,
  required int? remainingSeconds,
}) {
  return SessionUiState(
    plan: _plan,
    session: SessionState(
      planId: _plan.id,
      currentIndex: currentIndex,
      status: status,
      startedAt: DateTime(2026, 4, 22, 14, 0),
      elapsedSeconds: 0,
      remainingSeconds: remainingSeconds,
    ),
  );
}

const TrainingPlan _plan = TrainingPlan(
  id: 'plan-a',
  name: 'Plan A',
  items: <TrainingExercise>[
    TrainingExercise(
      exerciseId: 'Jumping jacks',
      mode: ExerciseMode.time,
      value: 30,
      restSeconds: 20,
    ),
    TrainingExercise(
      exerciseId: 'Push-ups',
      mode: ExerciseMode.reps,
      value: 12,
      restSeconds: 0,
    ),
  ],
);
