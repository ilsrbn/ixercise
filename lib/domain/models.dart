enum ExerciseMode { time, reps }

enum SessionStatus { running, resting, paused, done }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final String id;
  final String name;
  final String iconKey;
}

class TrainingExercise {
  const TrainingExercise({
    required this.exerciseId,
    required this.mode,
    required this.value,
    this.restSeconds = 0,
  });

  final String exerciseId;
  final ExerciseMode mode;
  final int value;
  final int restSeconds;
}

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<TrainingExercise> items;
}

class SessionState {
  const SessionState({
    required this.planId,
    required this.currentIndex,
    required this.status,
    required this.startedAt,
    required this.elapsedSeconds,
    this.remainingSeconds,
  });

  final String planId;
  final int currentIndex;
  final SessionStatus status;
  final int? remainingSeconds;
  final DateTime startedAt;
  final int elapsedSeconds;

  SessionState copyWith({
    int? currentIndex,
    SessionStatus? status,
    int? remainingSeconds,
    bool clearRemainingSeconds = false,
    int? elapsedSeconds,
  }) {
    return SessionState(
      planId: planId,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      remainingSeconds: clearRemainingSeconds
          ? null
          : (remainingSeconds ?? this.remainingSeconds),
      startedAt: startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
