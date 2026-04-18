import 'package:ixercise/domain/models.dart';

class TrainingSessionEngine {
  TrainingSessionEngine(this.plan, {DateTime? startedAt})
      : assert(plan.items.isNotEmpty, 'Training plan must have at least one item'),
        state = SessionState(
          planId: plan.id,
          currentIndex: 0,
          status: SessionStatus.running,
          remainingSeconds: plan.items.first.mode == ExerciseMode.time
              ? plan.items.first.value
              : null,
          startedAt: startedAt ?? DateTime.now(),
          elapsedSeconds: 0,
        );

  final TrainingPlan plan;
  SessionState state;

  TrainingExercise get currentItem => plan.items[state.currentIndex];

  bool get isDone => state.status == SessionStatus.done;

  void tick({required int seconds}) {
    if (seconds <= 0 || state.status == SessionStatus.paused || isDone) {
      return;
    }

    int remaining = seconds;
    while (remaining > 0 && !isDone && state.status != SessionStatus.paused) {
      if (state.status == SessionStatus.running) {
        if (currentItem.mode == ExerciseMode.reps) {
          state = state.copyWith(elapsedSeconds: state.elapsedSeconds + remaining);
          return;
        }

        final int currentRemaining = state.remainingSeconds ?? currentItem.value;
        final int step = currentRemaining < remaining ? currentRemaining : remaining;

        state = state.copyWith(
          remainingSeconds: currentRemaining - step,
          elapsedSeconds: state.elapsedSeconds + step,
        );
        remaining -= step;

        if ((state.remainingSeconds ?? 0) <= 0) {
          _completeCurrentExercise();
        }
      } else if (state.status == SessionStatus.resting) {
        final int currentRemaining = state.remainingSeconds ?? 0;
        final int step = currentRemaining < remaining ? currentRemaining : remaining;

        state = state.copyWith(
          remainingSeconds: currentRemaining - step,
          elapsedSeconds: state.elapsedSeconds + step,
        );
        remaining -= step;

        if ((state.remainingSeconds ?? 0) <= 0) {
          _advanceToNextExercise();
        }
      }
    }
  }

  void completeCurrentReps() {
    if (isDone || state.status != SessionStatus.running) {
      return;
    }
    if (currentItem.mode != ExerciseMode.reps) {
      return;
    }

    _completeCurrentExercise();
  }

  void skipRest() {
    if (state.status != SessionStatus.resting || isDone) {
      return;
    }
    _advanceToNextExercise();
  }

  void pause() {
    if (isDone || state.status == SessionStatus.paused) {
      return;
    }
    state = state.copyWith(status: SessionStatus.paused);
  }

  void resume() {
    if (isDone || state.status != SessionStatus.paused) {
      return;
    }

    final int? remaining = state.remainingSeconds;
    final SessionStatus nextStatus =
        remaining == null ? SessionStatus.running : _statusForRemaining(remaining);
    state = state.copyWith(status: nextStatus);
  }

  SessionStatus _statusForRemaining(int remaining) {
    final TrainingExercise item = currentItem;
    if (item.mode == ExerciseMode.time) {
      return SessionStatus.running;
    }
    if (remaining > 0) {
      return SessionStatus.resting;
    }
    return SessionStatus.running;
  }

  void _completeCurrentExercise() {
    final bool hasRest = currentItem.restSeconds > 0;
    if (hasRest) {
      state = state.copyWith(
        status: SessionStatus.resting,
        remainingSeconds: currentItem.restSeconds,
      );
      return;
    }
    _advanceToNextExercise();
  }

  void _advanceToNextExercise() {
    final int nextIndex = state.currentIndex + 1;
    if (nextIndex >= plan.items.length) {
      state = state.copyWith(
        currentIndex: plan.items.length - 1,
        status: SessionStatus.done,
        clearRemainingSeconds: true,
      );
      return;
    }

    final TrainingExercise nextItem = plan.items[nextIndex];
    state = state.copyWith(
      currentIndex: nextIndex,
      status: SessionStatus.running,
      remainingSeconds: nextItem.mode == ExerciseMode.time ? nextItem.value : null,
      clearRemainingSeconds: nextItem.mode == ExerciseMode.reps,
    );
  }
}
