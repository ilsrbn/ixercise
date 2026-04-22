import 'dart:convert';

import 'package:ixercise/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kSchemaVersion = 1;
const String kSchemaVersionKey = 'ixercise_schema_version';
const String kSelectedExercisesKey = 'ixercise_selected_exercises';
const String kTrainingPlansKey = 'ixercise_training_plans';
const String kSchedulesKey = 'ixercise_schedules';
const String kFeedbackSettingsKey = 'ixercise_feedback_settings';
const String kTrainingReminderIdsKey = 'ixercise_training_reminder_ids';

class LocalStore {
  const LocalStore();

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> writeSchemaVersion() async {
    final prefs = await _prefs();
    await prefs.setInt(kSchemaVersionKey, kSchemaVersion);
  }

  Future<Set<String>> loadSelectedExercises() async {
    final prefs = await _prefs();
    final raw = prefs.getString(kSelectedExercisesKey);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }
      return decoded.whereType<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> saveSelectedExercises(Set<String> value) async {
    final prefs = await _prefs();
    await writeSchemaVersion();
    await prefs.setString(kSelectedExercisesKey, jsonEncode(value.toList()));
  }

  Future<List<TrainingPlan>> loadTrainingPlans() async {
    final prefs = await _prefs();
    final raw = prefs.getString(kTrainingPlansKey);
    if (raw == null || raw.isEmpty) {
      return <TrainingPlan>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <TrainingPlan>[];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_trainingPlanFromJson)
          .toList(growable: false);
    } catch (_) {
      return <TrainingPlan>[];
    }
  }

  Future<void> saveTrainingPlans(List<TrainingPlan> plans) async {
    final prefs = await _prefs();
    await writeSchemaVersion();
    await prefs.setString(
      kTrainingPlansKey,
      jsonEncode(plans.map(_trainingPlanToJson).toList(growable: false)),
    );
  }

  Future<List<Map<String, dynamic>>> loadSchedules() async {
    final prefs = await _prefs();
    final raw = prefs.getString(kSchedulesKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> saveSchedules(List<Map<String, dynamic>> schedules) async {
    final prefs = await _prefs();
    await writeSchemaVersion();
    await prefs.setString(kSchedulesKey, jsonEncode(schedules));
  }

  Future<Map<String, dynamic>> loadFeedbackSettings() async {
    final prefs = await _prefs();
    final raw = prefs.getString(kFeedbackSettingsKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> saveFeedbackSettings(Map<String, dynamic> settings) async {
    final prefs = await _prefs();
    await writeSchemaVersion();
    await prefs.setString(kFeedbackSettingsKey, jsonEncode(settings));
  }

  Future<List<int>> loadTrainingReminderIds() async {
    final prefs = await _prefs();
    final raw = prefs.getString(kTrainingReminderIdsKey);
    if (raw == null || raw.isEmpty) {
      return <int>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <int>[];
      }
      return decoded.whereType<int>().toList(growable: false);
    } catch (_) {
      return <int>[];
    }
  }

  Future<void> saveTrainingReminderIds(List<int> ids) async {
    final prefs = await _prefs();
    await writeSchemaVersion();
    await prefs.setString(kTrainingReminderIdsKey, jsonEncode(ids));
  }
}

Map<String, dynamic> _trainingPlanToJson(TrainingPlan plan) {
  return <String, dynamic>{
    'id': plan.id,
    'name': plan.name,
    'items': plan.items
        .map(
          (item) => <String, dynamic>{
            'exerciseId': item.exerciseId,
            'mode': item.mode.name,
            'value': item.value,
            'restSeconds': item.restSeconds,
          },
        )
        .toList(growable: false),
  };
}

TrainingPlan _trainingPlanFromJson(Map<String, dynamic> json) {
  final List<dynamic> rawItems =
      (json['items'] as List<dynamic>? ?? <dynamic>[]);
  final items = rawItems
      .whereType<Map<String, dynamic>>()
      .map((raw) {
        final String modeRaw = raw['mode'] as String? ?? 'time';
        final ExerciseMode mode = modeRaw == ExerciseMode.reps.name
            ? ExerciseMode.reps
            : ExerciseMode.time;

        return TrainingExercise(
          exerciseId: raw['exerciseId'] as String? ?? '',
          mode: mode,
          value: raw['value'] as int? ?? 1,
          restSeconds: raw['restSeconds'] as int? ?? 0,
        );
      })
      .toList(growable: false);

  return TrainingPlan(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    items: items,
  );
}
