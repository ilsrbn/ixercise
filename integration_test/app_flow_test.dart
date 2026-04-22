import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ixercise/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding to done flow returns to home', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Pick Your Exercises'), findsOneWidget);

    await tester.tap(find.byKey(const Key('exercise_card_pushups')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home_start_training')));
    await tester.pumpAndSettle();
    expect(find.text('Training Run'), findsOneWidget);

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('run_tick_button')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Rest'), findsOneWidget);

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('rest_tick_button')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Training Run'), findsOneWidget);

    await tester.tap(find.byKey(const Key('run_next_button')));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byKey(const Key('done_back_home')));
    await tester.pumpAndSettle();
    expect(find.text('Nothing scheduled.'), findsOneWidget);
  });
}
