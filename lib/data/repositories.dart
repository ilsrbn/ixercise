import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/data/local_store.dart';
import 'package:ixercise/domain/models.dart';

class ExerciseSelectionRepository {
  ExerciseSelectionRepository(this._store);

  final LocalStore _store;

  Future<Set<String>> load() => _store.loadSelectedExercises();

  Future<void> save(Set<String> exerciseIds) =>
      _store.saveSelectedExercises(exerciseIds);
}

class TrainingPlanRepository {
  TrainingPlanRepository(this._store);

  final LocalStore _store;

  Future<List<TrainingPlan>> load() => _store.loadTrainingPlans();

  Future<void> save(List<TrainingPlan> plans) =>
      _store.saveTrainingPlans(plans);
}

class ScheduleRepository {
  ScheduleRepository(this._store);

  final LocalStore _store;

  Future<List<Map<String, dynamic>>> load() => _store.loadSchedules();

  Future<void> save(List<Map<String, dynamic>> schedules) =>
      _store.saveSchedules(schedules);
}

class FeedbackSettingsRepository {
  FeedbackSettingsRepository(this._store);

  final LocalStore _store;

  Future<Map<String, dynamic>> load() => _store.loadFeedbackSettings();

  Future<void> save(Map<String, dynamic> settings) =>
      _store.saveFeedbackSettings(settings);
}

class TrainingReminderIdRepository {
  TrainingReminderIdRepository(this._store);

  final LocalStore _store;

  Future<List<int>> load() => _store.loadTrainingReminderIds();

  Future<void> save(List<int> ids) => _store.saveTrainingReminderIds(ids);
}

final localStoreProvider = Provider<LocalStore>((ref) => const LocalStore());

final exerciseSelectionRepositoryProvider =
    Provider<ExerciseSelectionRepository>(
      (ref) => ExerciseSelectionRepository(ref.watch(localStoreProvider)),
    );

final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>(
  (ref) => TrainingPlanRepository(ref.watch(localStoreProvider)),
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(ref.watch(localStoreProvider)),
);

final feedbackSettingsRepositoryProvider = Provider<FeedbackSettingsRepository>(
  (ref) => FeedbackSettingsRepository(ref.watch(localStoreProvider)),
);

final trainingReminderIdRepositoryProvider =
    Provider<TrainingReminderIdRepository>(
      (ref) => TrainingReminderIdRepository(ref.watch(localStoreProvider)),
    );
