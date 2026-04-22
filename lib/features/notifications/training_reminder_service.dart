import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:ixercise/data/repositories.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/notifications/training_reminder_schedule.dart';
import 'package:ixercise/features/settings/feedback_settings_controller.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract class TrainingReminderCoordinator {
  Future<void> syncAll({
    required List<TrainingPlan> plans,
    required Map<String, Map<String, dynamic>> schedulesByPlanId,
  });
}

class TrainingReminderService implements TrainingReminderCoordinator {
  TrainingReminderService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInitialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<void> syncAll({
    required List<TrainingPlan> plans,
    required Map<String, Map<String, dynamic>> schedulesByPlanId,
  }) async {
    if (kIsWeb) {
      return;
    }
    await initialize();

    final TrainingReminderIdRepository idRepository = _ref.read(
      trainingReminderIdRepositoryProvider,
    );
    final List<int> previousIds = await idRepository.load();
    for (final int id in previousIds) {
      await _plugin.cancel(id: id);
    }

    final FeedbackSettings settings = _ref.read(
      feedbackSettingsControllerProvider,
    );
    if (!settings.trainingRemindersEnabled) {
      await idRepository.save(<int>[]);
      return;
    }

    final tz.Location location = await _localLocation();
    final List<TrainingReminderRequest> requests =
        buildTrainingReminderRequests(
          plans: plans,
          schedulesByPlanId: schedulesByPlanId,
          location: location,
          now: tz.TZDateTime.now(location),
          offsetMinutes: settings.reminderOffsetMinutes,
        );
    if (requests.isEmpty) {
      await idRepository.save(<int>[]);
      return;
    }

    final bool allowed = await _requestPermissions();
    if (!allowed) {
      await idRepository.save(<int>[]);
      return;
    }

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'training_reminders',
        'Training reminders',
        channelDescription: 'Scheduled workout reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(threadIdentifier: 'training_reminders'),
      macOS: DarwinNotificationDetails(threadIdentifier: 'training_reminders'),
    );

    final List<int> scheduledIds = <int>[];
    for (final TrainingReminderRequest request in requests) {
      await _plugin.zonedSchedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledDate: request.scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: request.payload,
        matchDateTimeComponents: request.repeatsWeekly
            ? DateTimeComponents.dayOfWeekAndTime
            : null,
      );
      scheduledIds.add(request.id);
    }

    await idRepository.save(scheduledIds);
  }

  Future<bool> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool? androidGranted = await android
        ?.requestNotificationsPermission();
    if (androidGranted == false) {
      return false;
    }

    final IOSFlutterLocalNotificationsPlugin? ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final bool? iosGranted = await ios?.requestPermissions(
      alert: true,
      sound: true,
    );
    if (iosGranted == false) {
      return false;
    }

    final MacOSFlutterLocalNotificationsPlugin? macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final bool? macosGranted = await macos?.requestPermissions(
      alert: true,
      sound: true,
    );
    if (macosGranted == false) {
      return false;
    }

    return true;
  }

  Future<tz.Location> _localLocation() async {
    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      _timezoneInitialized = true;
    }

    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    return tz.local;
  }
}

final trainingReminderServiceProvider = Provider<TrainingReminderCoordinator>((
  ref,
) {
  return TrainingReminderService(ref);
});
