# Animation Transition Plan

This document scopes two follow-up animation tasks:

1. Start training from home with a selected-row transition into the run screen.
2. Make run/rest phase changes feel continuous by animating timer and next-exercise metadata.

Keep the implementation in Flutter primitives first. The app already uses `CustomTransitionPage`, `Animated*` widgets, `IxAnimatedTimerText`, `IxProgressBar`, `go_router`, and Riverpod. Avoid adding a motion package unless the native widgets become awkward.

## Current Relevant Code

- `lib/app/router.dart`
  - `/home` starts a session and navigates to `/run/:sessionId`.
  - `/run/:sessionId`, `/rest/:sessionId`, and `/done/:sessionId` already use `_sessionTransitionPage`.
- `lib/features/home/home_overview_screen.dart`
  - Plan rows are rendered in `HomeOverviewScreen`.
  - The start button key `home_start_training` is used by tests.
- `lib/features/training_run/training_run_screen.dart`
  - Main run UI includes current exercise title, icon, timer/reps, helper label, and next card.
  - It redirects to rest/done based on `session.status`.
- `lib/features/rest/rest_screen.dart`
  - Main rest UI includes countdown, progress bar, rest adjustment buttons, and next-up card.
  - It redirects to run/done based on `session.status`.

## Task 1: Home Start To Run Transition

### Goal

When the user taps play on a training row, the selected row should visually become the run screen context. Use a shared-axis or scale transition: the row subtly lifts/scales, the home list fades back, then the run screen arrives from the same visual origin.

### Recommended Implementation

Use a route-level transition plus a local row pressed state.

1. Add a specialized route transition for `/run/:sessionId` when coming from `/home`.
   - Replace or extend `_sessionTransitionPage` with a mode parameter:
     - `SessionTransitionKind.start`
     - `SessionTransitionKind.phase`
     - `SessionTransitionKind.done`
   - Use `SessionTransitionKind.start` for `/run/:sessionId`.
   - Keep the existing slide/parallax transition for run/rest/done phase movement, or rename it to `phase`.

2. Build the start transition as shared-axis scale:
   - Fade in from `0` to `1`.
   - Scale from `0.96` to `1.0`.
   - Slide from `Offset(0, 0.035)` to zero.
   - Duration: 420-520 ms.
   - Curve: `Curves.easeOutCubic` for incoming, `Curves.easeInOutSine` for secondary.

3. Add a local pressed animation in `HomeOverviewScreen`.
   - Convert the plan row item area into a small stateful widget if needed.
   - Track `_startingPlanId`.
   - On start tap:
     - set `_startingPlanId = plan.id`;
     - delay about 90-120 ms;
     - call `onStartTraining(plan)`.
   - Animate only the selected row:
     - `AnimatedScale(scale: 0.985 or 1.015 depending on preferred feel)`
     - `AnimatedOpacity(opacity: 0.72)`
     - maybe slightly darken the play button background.
   - Do not remove or rename `home_start_training`.

4. Optional, only if a stronger shared-element feel is needed:
   - Wrap the row title/icon area and run title/icon area in matching `Hero` tags.
   - Suggested tag: `'training-plan-${plan.id}'`.
   - Be careful: `Hero` works best when the source and target are both present across the route push. Because the app uses `context.go`, verify that the source route remains available long enough. If not, use only route-level scale/fade.

### Router Sketch

```dart
enum SessionTransitionKind { start, phase, done }

CustomTransitionPage<void> _sessionTransitionPage({
  required GoRouterState state,
  required Widget child,
  SessionTransitionKind kind = SessionTransitionKind.phase,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: kind == SessionTransitionKind.start
        ? const Duration(milliseconds: 480)
        : const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return switch (kind) {
        SessionTransitionKind.start => _startTrainingTransition(animation, child),
        SessionTransitionKind.phase => _phaseTransition(animation, secondaryAnimation, child),
        SessionTransitionKind.done => _phaseTransition(animation, secondaryAnimation, child),
      };
    },
  );
}
```

### Acceptance Criteria

- Tapping play gives immediate visual feedback before navigation.
- `/run/:sessionId` enters with a scale/fade/shared-axis feel.
- Existing integration test can still tap `home_start_training`.
- No route behavior changes: session starts before arriving on run screen.

## Task 2: Run/Rest Continuous Phase Motion

### Goal

The transition from exercise to rest and rest to next exercise should feel like one workout flow, not separate static screens. Timer, progress, and next-exercise metadata should animate on phase changes.

### Recommended Implementation

Create reusable animated phase widgets rather than putting ad hoc animations directly into both screens.

Suggested file:

- `lib/design_system/ix_phase_transition.dart`

Suggested widgets:

- `IxPhaseSwitcher`
  - A thin wrapper around `AnimatedSwitcher`.
  - Uses `ValueKey` based on exercise id, phase, and index.
  - Default transition: fade + vertical slide + tiny scale.
- `IxMetadataBar`
  - Optional extracted row/card for "NEXT" and "NEXT UP" content.
  - This makes it easier to keep motion consistent between run and rest.

### Training Run Screen Changes

In `training_run_screen.dart`:

1. Wrap current exercise title in `AnimatedSwitcher`.
   - Key: `ValueKey('run-title-${session.currentIndex}-${item.exerciseId}')`.
   - Transition: incoming title slides up from `Offset(0, 0.12)` and fades in.

2. Wrap `ExerciseGroupIcon + IxAnimatedTimerText` cluster in a keyed switcher.
   - Key should include `session.currentIndex` and `item.mode`.
   - Keep `IxAnimatedTimerText` for countdown digit changes.
   - The switcher should only handle exercise-to-exercise or rest-to-run changes.

3. Wrap the helper label text.
   - Key: `ValueKey(item.mode)`.
   - Fade between "Seconds remaining" and "Reps to complete".

4. Animate the next card.
   - Use `AnimatedSwitcher` keyed by next item id/index.
   - When there is no next item, fade/collapse out with `AnimatedSize`.

### Rest Screen Changes

In `rest_screen.dart`:

1. Keep `IxAnimatedTimerText` for second-by-second countdown.
2. Wrap the whole central timer block in a phase entry animation.
   - Key: `ValueKey('rest-${state.session.currentIndex}')`.
   - On entry from run, fade in and scale from `0.98` to `1.0`.
3. Wrap the next-up card in the same metadata switcher used by run.
   - Key: `ValueKey('rest-next-${next.exerciseId}-${state.session.currentIndex}')`.
   - Slide from bottom by `Offset(0, 0.12)` and fade in.
4. Animate progress bar value if `IxProgressBar` does not already animate internally.
   - If needed, update `IxProgressBar` to use `TweenAnimationBuilder<double>`.
   - Keep duration short, about 220-300 ms, so countdown feels responsive.

### Route Transition Adjustment

The existing `_sessionTransitionPage` uses a strong horizontal slide. For run/rest phase transitions, consider reducing travel distance so in-screen metadata animation can carry more of the motion:

- Incoming: `Offset(0.10, 0)` instead of `Offset(1.0, 0)`.
- Outgoing: `Offset(-0.08, 0)` instead of `Offset(-0.38, 0)`.
- Fade: `0.88 -> 1.0`.
- Duration: 360-460 ms.

This keeps route movement visible without making every rest/exercise switch feel like a full page replacement.

### Acceptance Criteria

- When a timed item completes, run screen transitions to rest with smooth route motion.
- Rest screen timer block and next-up card animate into place.
- When rest ends or Skip rest is tapped, the run screen enters smoothly and current/next metadata animates.
- Countdown digits still update once per second and remain readable.
- Existing tests for route changes and button keys still pass.

## Test Plan

Run:

```bash
flutter analyze --no-fatal-infos
flutter test
```

Manual or integration checks:

- Start a training from home and confirm the selected row gives immediate feedback.
- Complete a reps item and confirm route movement into rest.
- Let a timed item auto-complete into rest.
- Tap `rest_skip_button` and confirm the next run screen animates without stale exercise text.
- Complete the final item and confirm done navigation still works.

Do not run the integration test on web. Use Android/iOS device or simulator:

```bash
flutter test integration_test/app_flow_test.dart -d <device-id>
```

## Risks And Guardrails

- Avoid long delayed navigation. Local start feedback should be under 120 ms before calling `onStartTraining`.
- Keep widget keys used by tests:
  - `home_start_training`
  - `run_next_button`
  - `rest_skip_button`
- Do not animate every countdown tick with a whole-screen switcher. Only animate phase/item identity changes; let `IxAnimatedTimerText` handle timer digits.
- If using `Hero`, verify it works with `go_router` and `context.go`; otherwise keep the route-level shared-axis transition.
- Respect reduced motion later if the app adds an accessibility setting. The first implementation can centralize durations in helper functions to make that easier.
