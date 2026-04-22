import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/rest/rest_screen.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/training_run/training_run_screen.dart';

void main() {
  testWidgets('timed item auto-advances to rest and then next exercise', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionControllerProvider.overrideWith(
            (ref) => SessionController(seedPlan: _testPlan),
          ),
        ],
        child: const MaterialApp(home: _SessionFlowHarness()),
      ),
    );

    expect(find.text('Training Run', skipOffstage: false), findsOneWidget);

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('run_tick_button')));
      await tester.pump();
    }

    expect(find.text('Rest', skipOffstage: false), findsOneWidget);

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('rest_tick_button')));
      await tester.pump();
    }

    expect(find.text('Training Run', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('Push-ups'), findsOneWidget);
  });
}

const TrainingPlan _testPlan = TrainingPlan(
  id: 'flow-test',
  name: 'Flow Test',
  items: <TrainingExercise>[
    TrainingExercise(
      exerciseId: 'Jumping jacks',
      mode: ExerciseMode.time,
      value: 5,
      restSeconds: 3,
    ),
    TrainingExercise(
      exerciseId: 'Push-ups',
      mode: ExerciseMode.reps,
      value: 12,
      restSeconds: 0,
    ),
  ],
);

class _SessionFlowHarness extends ConsumerWidget {
  const _SessionFlowHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).session;

    if (session.status == SessionStatus.resting ||
        session.status == SessionStatus.paused) {
      return const RestScreen(sessionId: 'test');
    }

    return const TrainingRunScreen(sessionId: 'test');
  }
}
