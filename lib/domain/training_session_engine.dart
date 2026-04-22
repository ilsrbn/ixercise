import 'package:ixercise/domain/models.dart';

class TrainingSessionEngine {
  TrainingSessionEngine(this._plan, {DateTime? startedAt})
    : assert(
        _plan.items.isNotEmpty,
        'Training plan must have at least one item',
      ) {
    final DateTime initialTime = startedAt ?? DateTime.now();
    _lastReconciledAt = initialTime;
    state = SessionState(
      planId: _plan.id,
      currentIndex: 0,
      status: SessionStatus.running,
      remainingSeconds: _plan.items.first.mode == ExerciseMode.time
          ? _plan.items.first.value
          : null,
      startedAt: initialTime,
      elapsedSeconds: 0,
    );
  }

  TrainingPlan _plan;
  late DateTime _lastReconciledAt;
  SessionStatus? _pausedFromStatus;
  late SessionState state;

  TrainingPlan get plan => _plan;
  set plan(TrainingPlan value) {
    _plan = value;
  }

  TrainingExercise get currentItem => plan.items[state.currentIndex];

  bool get isDone => state.status == SessionStatus.done;

  void reset({DateTime? now}) {
    final DateTime resetAt = now ?? DateTime.now();
    _lastReconciledAt = resetAt;
    _pausedFromStatus = null;
    state = SessionState(
      planId: _plan.id,
      currentIndex: 0,
      status: SessionStatus.running,
      remainingSeconds: _plan.items.first.mode == ExerciseMode.time
          ? _plan.items.first.value
          : null,
      startedAt: resetAt,
      elapsedSeconds: 0,
    );
  }

  void reconcileTo(DateTime now) {
    if (isDone || state.status == SessionStatus.paused) {
      _lastReconciledAt = now;
      return;
    }

    final int seconds = now.difference(_lastReconciledAt).inSeconds;
    if (seconds <= 0) {
      return;
    }

    tick(seconds: seconds);
    _lastReconciledAt = _lastReconciledAt.add(Duration(seconds: seconds));
  }

  void tick({required int seconds}) {
    if (seconds <= 0 || state.status == SessionStatus.paused || isDone) {
      return;
    }

    int remaining = seconds;
    while (remaining > 0 && !isDone && state.status != SessionStatus.paused) {
      if (state.status == SessionStatus.running) {
        if (currentItem.mode == ExerciseMode.reps) {
          state = state.copyWith(
            elapsedSeconds: state.elapsedSeconds + remaining,
          );
          return;
        }

        final int currentRemaining =
            state.remainingSeconds ?? currentItem.value;
        final int step = currentRemaining < remaining
            ? currentRemaining
            : remaining;

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
        final int step = currentRemaining < remaining
            ? currentRemaining
            : remaining;

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
    if ((state.status != SessionStatus.resting &&
            _pausedFromStatus != SessionStatus.resting) ||
        isDone) {
      return;
    }
    _pausedFromStatus = null;
    _advanceToNextExercise();
  }

  void adjustRestSeconds(int delta) {
    if (delta == 0 || state.status != SessionStatus.resting || isDone) {
      return;
    }
    final int current = state.remainingSeconds ?? 0;
    final int next = (current + delta).clamp(0, 3600).toInt();
    state = state.copyWith(remainingSeconds: next);
    if (next == 0) {
      _advanceToNextExercise();
    }
  }

  void pause({DateTime? now}) {
    if (isDone || state.status == SessionStatus.paused) {
      return;
    }
    final DateTime pausedAt = now ?? DateTime.now();
    reconcileTo(pausedAt);
    _pausedFromStatus = state.status;
    state = state.copyWith(status: SessionStatus.paused);
    _lastReconciledAt = pausedAt;
  }

  void endSession() {
    if (isDone) {
      return;
    }
    state = state.copyWith(
      status: SessionStatus.done,
      currentIndex: state.currentIndex.clamp(0, plan.items.length - 1),
      clearRemainingSeconds: true,
    );
    _pausedFromStatus = null;
  }

  void resume({DateTime? now}) {
    if (isDone || state.status != SessionStatus.paused) {
      return;
    }

    final int? remaining = state.remainingSeconds;
    final SessionStatus nextStatus =
        _pausedFromStatus ??
        (remaining == null
            ? SessionStatus.running
            : _statusForRemaining(remaining));
    _pausedFromStatus = null;
    state = state.copyWith(status: nextStatus);
    _lastReconciledAt = now ?? DateTime.now();
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
    final bool isLastItem = state.currentIndex >= plan.items.length - 1;
    final bool hasRest = currentItem.restSeconds > 0 && !isLastItem;
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
      remainingSeconds: nextItem.mode == ExerciseMode.time
          ? nextItem.value
          : null,
      clearRemainingSeconds: nextItem.mode == ExerciseMode.reps,
    );
  }
}
