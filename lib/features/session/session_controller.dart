import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_session_engine.dart';

class SessionUiState {
  const SessionUiState({required this.plan, required this.session});

  final TrainingPlan plan;
  final SessionState session;

  TrainingExercise get currentItem => plan.items[session.currentIndex];
}

class SessionController extends StateNotifier<SessionUiState> {
  SessionController({TrainingPlan? seedPlan})
    : _engine = TrainingSessionEngine(seedPlan ?? _defaultPlan),
      super(
        SessionUiState(
          plan: seedPlan ?? _defaultPlan,
          session: TrainingSessionEngine(seedPlan ?? _defaultPlan).state,
        ),
      ) {
    _sync();
  }

  static const TrainingPlan _defaultPlan = TrainingPlan(
    id: 'default-session-plan',
    name: 'Morning Full Body',
    items: <TrainingExercise>[
      TrainingExercise(
        exerciseId: 'Jumping jacks',
        mode: ExerciseMode.time,
        value: 45,
        restSeconds: 15,
      ),
      TrainingExercise(
        exerciseId: 'Push-ups',
        mode: ExerciseMode.reps,
        value: 12,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Bodyweight squats',
        mode: ExerciseMode.reps,
        value: 20,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Plank',
        mode: ExerciseMode.time,
        value: 60,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Lunges',
        mode: ExerciseMode.reps,
        value: 16,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Mountain climbers',
        mode: ExerciseMode.time,
        value: 40,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Biceps curls',
        mode: ExerciseMode.reps,
        value: 15,
        restSeconds: 30,
      ),
      TrainingExercise(
        exerciseId: 'Crunches',
        mode: ExerciseMode.reps,
        value: 20,
        restSeconds: 0,
      ),
    ],
  );

  final TrainingSessionEngine _engine;

  void startPlan(TrainingPlan plan) {
    _engine.plan = plan;
    _engine.reset();
    _sync();
  }

  void tick({int seconds = 1}) {
    _engine.tick(seconds: seconds);
    _sync();
  }

  void completeOrNext() {
    if (state.session.status == SessionStatus.running) {
      if (state.currentItem.mode == ExerciseMode.reps) {
        _engine.completeCurrentReps();
      } else {
        _engine.tick(seconds: state.session.remainingSeconds ?? 0);
      }
    } else if (state.session.status == SessionStatus.resting) {
      _engine.skipRest();
    } else if (state.session.status == SessionStatus.paused) {
      _engine.resume();
      if (_engine.state.status == SessionStatus.running) {
        if (_engine.currentItem.mode == ExerciseMode.reps) {
          _engine.completeCurrentReps();
        } else {
          _engine.tick(seconds: _engine.state.remainingSeconds ?? 0);
        }
      }
    }
    _sync();
  }

  void skipRest() {
    if (state.session.status == SessionStatus.paused) {
      _engine.resume();
    }
    _engine.skipRest();
    _sync();
  }

  void pauseResume() {
    if (state.session.status == SessionStatus.paused) {
      _engine.resume();
    } else {
      _engine.pause();
    }
    _sync();
  }

  void adjustRestSeconds(int delta) {
    _engine.adjustRestSeconds(delta);
    _sync();
  }

  void endSession() {
    _engine.endSession();
    _sync();
  }

  void _sync() {
    state = SessionUiState(plan: _engine.plan, session: _engine.state);
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionUiState>(
      (ref) => SessionController(),
    );
