import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/features/notifications/training_reminder_service.dart';

void main() {
  test('fallback timezone preserves UTC+3 wall-clock scheduling', () {
    expect(fallbackZoneNameForOffset(const Duration(hours: 3)), 'Etc/GMT-3');
  });

  test('fallback timezone preserves UTC-7 wall-clock scheduling', () {
    expect(fallbackZoneNameForOffset(const Duration(hours: -7)), 'Etc/GMT+7');
  });

  test('fallback timezone handles common half-hour offsets', () {
    expect(
      fallbackZoneNameForOffset(const Duration(hours: 5, minutes: 30)),
      'Asia/Kolkata',
    );
  });
}
