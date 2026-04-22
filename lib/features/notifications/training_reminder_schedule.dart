import 'package:ixercise/domain/models.dart';
import 'package:timezone/timezone.dart' as tz;

const int kAlternatingReminderOccurrences = 30;

class TrainingReminderRequest {
  const TrainingReminderRequest({
    required this.id,
    required this.planId,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
    required this.repeatsWeekly,
  });

  final int id;
  final String planId;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final String payload;
  final bool repeatsWeekly;
}

List<TrainingReminderRequest> buildTrainingReminderRequests({
  required List<TrainingPlan> plans,
  required Map<String, Map<String, dynamic>> schedulesByPlanId,
  required tz.Location location,
  required tz.TZDateTime now,
  required int offsetMinutes,
}) {
  final List<TrainingReminderRequest> out = <TrainingReminderRequest>[];
  for (final TrainingPlan plan in plans) {
    final Map<String, dynamic>? schedule = schedulesByPlanId[plan.id];
    if (schedule == null) {
      continue;
    }
    final String type = schedule['type'] as String? ?? 'none';
    final _TimeOfDay? time = _parseTime(schedule['time'] as String? ?? '');
    if (time == null) {
      continue;
    }
    if (type == 'weekdays') {
      final List<int> weekdays =
          (schedule['weekdays'] as List<dynamic>? ?? <dynamic>[])
              .whereType<int>()
              .where((int day) => day >= 1 && day <= 7)
              .toSet()
              .toList()
            ..sort();
      for (final int weekday in weekdays) {
        final tz.TZDateTime reminderDate = _nextWeekdayReminderDate(
          location: location,
          now: now,
          weekday: weekday,
          hour: time.hour,
          minute: time.minute,
          offsetMinutes: offsetMinutes,
        );
        out.add(
          _request(
            plan: plan,
            slot: weekday,
            timeLabel: schedule['time'] as String? ?? '',
            scheduledDate: reminderDate,
            repeatsWeekly: true,
          ),
        );
      }
    } else if (type == 'alternating') {
      tz.TZDateTime workout = _firstAlternatingWorkoutDate(
        location: location,
        now: now,
        anchorDate: schedule['anchorDate'] as String?,
        hour: time.hour,
        minute: time.minute,
        offsetMinutes: offsetMinutes,
      );
      for (int i = 0; i < kAlternatingReminderOccurrences; i += 1) {
        final tz.TZDateTime reminderDate = workout.subtract(
          Duration(minutes: offsetMinutes),
        );
        out.add(
          _request(
            plan: plan,
            slot: 20 + i,
            timeLabel: schedule['time'] as String? ?? '',
            scheduledDate: reminderDate,
            repeatsWeekly: false,
          ),
        );
        workout = workout.add(const Duration(days: 2));
      }
    }
  }
  return out;
}

TrainingReminderRequest _request({
  required TrainingPlan plan,
  required int slot,
  required String timeLabel,
  required tz.TZDateTime scheduledDate,
  required bool repeatsWeekly,
}) {
  return TrainingReminderRequest(
    id: trainingReminderId(plan.id, slot),
    planId: plan.id,
    title: 'Training time',
    body: timeLabel.isEmpty
        ? '${plan.name} is scheduled today'
        : '${plan.name} starts at $timeLabel',
    scheduledDate: scheduledDate,
    payload: 'plan:${plan.id}',
    repeatsWeekly: repeatsWeekly,
  );
}

int trainingReminderId(String planId, int slot) {
  return 100000000 + (_stableHash(planId) % 1000000) * 100 + slot;
}

int _stableHash(String input) {
  int hash = 0;
  for (final int codeUnit in input.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

tz.TZDateTime _nextWeekdayReminderDate({
  required tz.Location location,
  required tz.TZDateTime now,
  required int weekday,
  required int hour,
  required int minute,
  required int offsetMinutes,
}) {
  tz.TZDateTime workout = tz.TZDateTime(
    location,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  while (workout.weekday != weekday) {
    workout = workout.add(const Duration(days: 1));
  }
  tz.TZDateTime reminder = workout.subtract(Duration(minutes: offsetMinutes));
  while (!reminder.isAfter(now)) {
    workout = workout.add(const Duration(days: 7));
    reminder = workout.subtract(Duration(minutes: offsetMinutes));
  }
  return reminder;
}

tz.TZDateTime _firstAlternatingWorkoutDate({
  required tz.Location location,
  required tz.TZDateTime now,
  required String? anchorDate,
  required int hour,
  required int minute,
  required int offsetMinutes,
}) {
  final DateTime anchor =
      _parseDate(anchorDate) ?? DateTime(now.year, now.month, now.day);
  tz.TZDateTime workout = tz.TZDateTime(
    location,
    anchor.year,
    anchor.month,
    anchor.day,
    hour,
    minute,
  );
  tz.TZDateTime reminder = workout.subtract(Duration(minutes: offsetMinutes));
  while (!reminder.isAfter(now)) {
    workout = workout.add(const Duration(days: 2));
    reminder = workout.subtract(Duration(minutes: offsetMinutes));
  }
  return workout;
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

_TimeOfDay? _parseTime(String value) {
  final List<String> parts = value.split(':');
  if (parts.length != 2) {
    return null;
  }
  final int? hour = int.tryParse(parts[0]);
  final int? minute = int.tryParse(parts[1]);
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }
  return _TimeOfDay(hour: hour, minute: minute);
}

class _TimeOfDay {
  const _TimeOfDay({required this.hour, required this.minute});

  final int hour;
  final int minute;
}
