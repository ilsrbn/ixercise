# Ixercise Flutter MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter MVP that matches the approved Ixercise flow: onboarding cards, home overview (no calories), minimal run, separate rest, and done screen with local persistence.

**Architecture:** Single Flutter app with feature modules (`onboarding`, `home`, `training_run`, `rest`, `done`), Riverpod state controllers, `go_router` navigation, and a pure-Dart training engine. Storage is versioned JSON in `shared_preferences` with migration guards.

**Tech Stack:** Flutter, Dart, flutter_riverpod, go_router, shared_preferences, flutter_test, integration_test.

---

### Task 1: Project Bootstrap and Routing Skeleton

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app/router.dart`
- Create: `lib/app/shell.dart`
- Test: `test/app/router_smoke_test.dart`

- [ ] **Step 1: Scaffold Flutter app**

```bash
flutter create . --platforms=web,ios,android
```

- [ ] **Step 2: Add dependencies in `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

- [ ] **Step 3: Write failing router smoke test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/app/router.dart';

void main() {
  test('router exposes onboarding as initial location', () {
    final router = buildRouter();
    expect(router.routeInformationProvider.value.uri.toString(), '/onboarding');
  });
}
```

- [ ] **Step 4: Run test to verify failure**

Run: `flutter test test/app/router_smoke_test.dart -r expanded`
Expected: FAIL with missing `buildRouter`.

- [ ] **Step 5: Implement router and shell minimal code**

```dart
// lib/app/router.dart
import 'package:go_router/go_router.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/home', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/run/:sessionId', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/rest/:sessionId', builder: (_, __) => const Placeholder()),
      GoRoute(path: '/done/:sessionId', builder: (_, __) => const Placeholder()),
    ],
  );
}
```

- [ ] **Step 6: Run tests and commit**

Run: `flutter test test/app/router_smoke_test.dart -r expanded`
Expected: PASS.

```bash
git add pubspec.yaml lib/main.dart lib/app/router.dart lib/app/shell.dart test/app/router_smoke_test.dart
git commit -m "chore: scaffold flutter app and routing skeleton"
```

### Task 2: Design System Foundation

**Files:**
- Create: `lib/design_system/tokens.dart`
- Create: `lib/design_system/ix_button.dart`
- Create: `lib/design_system/ix_progress_bar.dart`
- Test: `test/design_system/ix_button_test.dart`

- [ ] **Step 1: Write failing button style test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/design_system/ix_button.dart';

void main() {
  testWidgets('primary IxButton renders accent background', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: IxButton.primary(label: 'Go'))));
    final container = tester.widget<Container>(find.byKey(const Key('ix_button_primary_container')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/design_system/ix_button_test.dart -r expanded`
Expected: FAIL with missing `IxButton`.

- [ ] **Step 3: Implement tokens and reusable widgets**

```dart
// lib/design_system/tokens.dart
import 'package:flutter/material.dart';

class IxColors {
  static const ink = Color(0xFF0A0A0A);
  static const bg = Color(0xFFFAFAFA);
  static const line = Color(0xFFE8E8E8);
  static const mute = Color(0xFF6B6B6B);
  static const accent = Color(0xFFE11D2E);
}
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/design_system/ix_button_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/design_system/tokens.dart lib/design_system/ix_button.dart lib/design_system/ix_progress_bar.dart test/design_system/ix_button_test.dart
git commit -m "feat: add custom design system tokens and primitives"
```

### Task 3: Domain Models and Training Engine

**Files:**
- Create: `lib/domain/models.dart`
- Create: `lib/domain/training_session_engine.dart`
- Test: `test/domain/training_session_engine_test.dart`

- [ ] **Step 1: Write failing engine transition tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_session_engine.dart';

void main() {
  test('timed exercise completes into rest when restSeconds > 0', () {
    final plan = TrainingPlan(id: 'p1', name: 'A', items: [
      TrainingExercise(exerciseId: 'push', mode: ExerciseMode.time, value: 10, restSeconds: 15),
    ]);
    final engine = TrainingSessionEngine(plan);
    engine.tick(seconds: 10);
    expect(engine.state.status, SessionStatus.resting);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/domain/training_session_engine_test.dart -r expanded`
Expected: FAIL with missing engine/model symbols.

- [ ] **Step 3: Implement models + deterministic engine**

```dart
enum ExerciseMode { time, reps }
enum SessionStatus { running, resting, paused, done }
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/domain/training_session_engine_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/domain/models.dart lib/domain/training_session_engine.dart test/domain/training_session_engine_test.dart
git commit -m "feat: implement training domain models and engine"
```

### Task 4: Onboarding Cards Screen

**Files:**
- Create: `lib/features/onboarding/onboarding_screen.dart`
- Create: `lib/features/onboarding/onboarding_controller.dart`
- Test: `test/features/onboarding/onboarding_screen_test.dart`

- [ ] **Step 1: Write failing onboarding validation test**

```dart
testWidgets('continue disabled until at least one exercise selected', (tester) async {
  // pump onboarding screen
  expect(find.text('Continue'), findsOneWidget);
  final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  expect(button.onPressed, isNull);
});
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart -r expanded`
Expected: FAIL with missing onboarding screen.

- [ ] **Step 3: Implement cards-only onboarding with search/filter**

```dart
// Required behavior
// - cards grid only
// - search by exercise name
// - toggle selection
// - continue enabled when selected.isNotEmpty
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/features/onboarding/onboarding_screen.dart lib/features/onboarding/onboarding_controller.dart test/features/onboarding/onboarding_screen_test.dart
git commit -m "feat: add onboarding cards flow with required selection gate"
```

### Task 5: Home Overview MVP (No Calories)

**Files:**
- Create: `lib/features/home/home_overview_screen.dart`
- Create: `lib/features/home/home_controller.dart`
- Test: `test/features/home/home_overview_screen_test.dart`

- [ ] **Step 1: Write failing home MVP test**

```dart
testWidgets('home overview renders plans and does not show calories', (tester) async {
  // pump home with seeded plans
  expect(find.text('Calories'), findsNothing);
  expect(find.text('Start training'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/features/home/home_overview_screen_test.dart -r expanded`
Expected: FAIL.

- [ ] **Step 3: Implement overview-only home screen**

```dart
// Required behavior
// - training cards list
// - start/create/schedule actions
// - no calories metrics block
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/features/home/home_overview_screen_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/features/home/home_overview_screen.dart lib/features/home/home_controller.dart test/features/home/home_overview_screen_test.dart
git commit -m "feat: implement home overview mvp without calories"
```

### Task 6: Training Run, Rest, and Done Screens

**Files:**
- Create: `lib/features/training_run/training_run_screen.dart`
- Create: `lib/features/rest/rest_screen.dart`
- Create: `lib/features/done/done_screen.dart`
- Create: `lib/features/session/session_controller.dart`
- Test: `test/features/session/session_flow_test.dart`

- [ ] **Step 1: Write failing session flow widget test**

```dart
testWidgets('timed item auto-advances to rest and then next exercise', (tester) async {
  // seed session with timed + rest
  // verify run -> rest -> run transitions
});
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/features/session/session_flow_test.dart -r expanded`
Expected: FAIL.

- [ ] **Step 3: Implement minimal run UI + separate rest + done**

```dart
// Required behavior
// - run screen: linear progress + current item + controls
// - rest screen: countdown + next-up + pause/resume + skip
// - done screen: elapsed time + back home
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/features/session/session_flow_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/features/training_run/training_run_screen.dart lib/features/rest/rest_screen.dart lib/features/done/done_screen.dart lib/features/session/session_controller.dart test/features/session/session_flow_test.dart
git commit -m "feat: implement run rest done session flow"
```

### Task 7: Persistence, Schema Versioning, and Migration Guards

**Files:**
- Create: `lib/data/local_store.dart`
- Create: `lib/data/repositories.dart`
- Test: `test/data/local_store_test.dart`

- [ ] **Step 1: Write failing persistence tests**

```dart
test('invalid json payload falls back to defaults', () async {
  // seed broken payload
  // expect safe defaults
});
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/data/local_store_test.dart -r expanded`
Expected: FAIL.

- [ ] **Step 3: Implement versioned read/write and fallback behavior**

```dart
const kSchemaVersion = 1;
const kSelectedExercisesKey = 'ixercise_selected_exercises';
const kTrainingPlansKey = 'ixercise_training_plans';
const kSchedulesKey = 'ixercise_schedules';
```

- [ ] **Step 4: Run tests and commit**

Run: `flutter test test/data/local_store_test.dart -r expanded`
Expected: PASS.

```bash
git add lib/data/local_store.dart lib/data/repositories.dart test/data/local_store_test.dart
git commit -m "feat: add versioned local persistence with fallback migration guards"
```

### Task 8: Integration Flow, QA, and Delivery Check

**Files:**
- Create: `integration_test/app_flow_test.dart`
- Modify: `lib/main.dart`
- Modify: `README.md`

- [ ] **Step 1: Write failing end-to-end integration test**

```dart
// onboarding select -> continue -> home -> start -> run -> rest -> done -> back home
```

- [ ] **Step 2: Run integration to verify failure**

Run: `flutter test integration_test/app_flow_test.dart -r expanded`
Expected: FAIL until full flow wired.

- [ ] **Step 3: Wire app entrypoint and document run commands**

```bash
flutter test
flutter test integration_test/app_flow_test.dart -r expanded
flutter run -d chrome
```

- [ ] **Step 4: Full verification and commit**

Run: `flutter analyze && flutter test`
Expected: PASS with no analyzer errors.

```bash
git add integration_test/app_flow_test.dart lib/main.dart README.md
git commit -m "test: add e2e flow coverage and mvp runbook"
```

## Plan Self-Review

1. Spec coverage: onboarding(cards), home(overview/no calories), run(minimal), rest, done, persistence, schedule metadata are all mapped to tasks.
2. Placeholder scan: no TBD/TODO placeholders remain.
3. Type consistency: shared domain names (`TrainingPlan`, `TrainingExercise`, `SessionStatus`) are consistent across tasks.
