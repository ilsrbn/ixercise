import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/notifications/training_reminder_schedule.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location location;

  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  setUp(() {
    location = tz.getLocation('America/Los_Angeles');
  });

  test('builds weekly reminders for selected weekdays', () {
    final List<TrainingReminderRequest> requests =
        buildTrainingReminderRequests(
          plans: const <TrainingPlan>[_plan],
          schedulesByPlanId: <String, Map<String, dynamic>>{
            'plan-a': <String, dynamic>{
              'type': 'weekdays',
              'weekdays': <int>[1, 3],
              'time': '21:00',
            },
          },
          location: location,
          now: tz.TZDateTime(location, 2026, 4, 21, 10),
          offsetMinutes: 0,
        );

    expect(requests, hasLength(2));
    expect(requests.map((TrainingReminderRequest r) => r.repeatsWeekly), {
      true,
    });
    expect(requests.first.scheduledDate.weekday, 1);
    expect(requests.first.scheduledDate.hour, 21);
    expect(requests.last.scheduledDate.weekday, 3);
    expect(requests.last.scheduledDate.hour, 21);
  });

  test('applies reminder offset before scheduled training time', () {
    final List<TrainingReminderRequest> requests =
        buildTrainingReminderRequests(
          plans: const <TrainingPlan>[_plan],
          schedulesByPlanId: <String, Map<String, dynamic>>{
            'plan-a': <String, dynamic>{
              'type': 'weekdays',
              'weekdays': <int>[2],
              'time': '21:00',
            },
          },
          location: location,
          now: tz.TZDateTime(location, 2026, 4, 21, 10),
          offsetMinutes: 15,
        );

    expect(requests.single.scheduledDate.weekday, 2);
    expect(requests.single.scheduledDate.hour, 20);
    expect(requests.single.scheduledDate.minute, 45);
  });

  test('rolls weekly reminder forward when offset time has already passed', () {
    final List<TrainingReminderRequest> requests =
        buildTrainingReminderRequests(
          plans: const <TrainingPlan>[_plan],
          schedulesByPlanId: <String, Map<String, dynamic>>{
            'plan-a': <String, dynamic>{
              'type': 'weekdays',
              'weekdays': <int>[2],
              'time': '10:00',
            },
          },
          location: location,
          now: tz.TZDateTime(location, 2026, 4, 21, 9, 50),
          offsetMinutes: 15,
        );

    expect(requests.single.scheduledDate.day, 28);
    expect(requests.single.scheduledDate.hour, 9);
    expect(requests.single.scheduledDate.minute, 45);
  });

  test('builds upcoming one-shot alternating reminders from anchor date', () {
    final List<TrainingReminderRequest> requests =
        buildTrainingReminderRequests(
          plans: const <TrainingPlan>[_plan],
          schedulesByPlanId: <String, Map<String, dynamic>>{
            'plan-a': <String, dynamic>{
              'type': 'alternating',
              'anchorDate': '2026-04-20',
              'time': '07:30',
            },
          },
          location: location,
          now: tz.TZDateTime(location, 2026, 4, 21, 10),
          offsetMinutes: 5,
        );

    expect(requests, hasLength(kAlternatingReminderOccurrences));
    expect(requests.first.repeatsWeekly, isFalse);
    expect(requests.first.scheduledDate.day, 22);
    expect(requests.first.scheduledDate.hour, 7);
    expect(requests.first.scheduledDate.minute, 25);
    expect(requests[1].scheduledDate.day, 24);
  });
}

const TrainingPlan _plan = TrainingPlan(
  id: 'plan-a',
  name: 'Arm day',
  items: <TrainingExercise>[
    TrainingExercise(
      exerciseId: 'pushups',
      mode: ExerciseMode.reps,
      value: 10,
      restSeconds: 30,
    ),
  ],
);
