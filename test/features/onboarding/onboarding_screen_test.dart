import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('continue disabled until at least one exercise selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byKey(const Key('onboarding_continue')),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byKey(const Key('exercise_card_pushups')));
    await tester.pumpAndSettle();

    final ElevatedButton enabledButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('onboarding_continue')),
    );
    expect(enabledButton.onPressed, isNotNull);
  });
}
