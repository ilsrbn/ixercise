import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/app/router.dart';

void main() {
  test('router exposes onboarding as initial location', () {
    final router = buildRouter();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/onboarding',
    );
  });
}
