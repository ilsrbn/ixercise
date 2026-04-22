# Background Activity Plan

Goal: make workout sessions behave correctly when the phone is locked, then add native iOS lock-screen surfaces.

## Phase 1: Timer Correctness

- Treat timed exercise/rest countdowns as wall-clock based, not Dart timer based.
- Store the last reconciled timestamp inside the session engine.
- On each visible timer tick and app resume, reconcile `DateTime.now()` against the last timestamp.
- If the app was suspended for 90 seconds, advance the engine by 90 seconds on resume.
- Paused sessions must not consume elapsed wall-clock time.

## Phase 2: Phase-End Feedback

- Do not use local push notifications while an active workout is running.
- Use the lock-screen Live Activity as the active workout surface when the phone is locked.
- Use sounds and haptics for phase changes:
  - workout starts
  - exercise changes to rest
  - rest changes to next exercise
  - final 3-second countdown ticks
  - workout finishes
- Keep scheduled local notifications only for future scheduled training reminders.

### Phase 2 Implementation Notes

- `SessionFeedbackService` handles active workout sounds and haptics.
- `TrainingReminderService` handles scheduled training reminders only.
- `sessionControllerProvider` changes should sync:
  - `SessionFeedbackService`
  - `LiveActivityCoordinator`
- `sessionControllerProvider` changes should not schedule active workout local notifications.
- The source of truth remains the timestamp-reconciled session engine from Phase 1.

### Phase 2 Testing

- Unit-test session feedback transitions where possible.
- Widget/app-shell tests should override sound/haptic and Live Activity services with fake implementations.
- Scheduled training reminders remain covered by notification schedule/service tests.

## Phase 3: Live Activity

- Add an iOS ActivityKit widget extension.
- Show current exercise/rest, countdown, next item, and progress.
- Keep Flutter as source of truth and publish snapshots to the Live Activity.
- Use App Groups if native extension state sharing is needed.

### Phase 3 Implementation Notes

- Build the feature in two native slices:
  - first, add a Flutter-to-iOS MethodChannel and a deterministic Dart snapshot mapper
  - second, add the WidgetKit extension that renders those snapshots on the lock screen and Dynamic Island
- Channel name: `ixercise/live_activity`.
- Methods:
  - `sync`: start or update the current Live Activity from a session snapshot
  - `end`: end the active Live Activity when a session finishes
  - `isSupported`: report whether ActivityKit is available and enabled
- Snapshot fields:
  - `sessionId`
  - `planName`
  - `phase`
  - `title`
  - `subtitle`
  - `remainingSeconds`
  - `totalSeconds`
  - `progress`
  - `isPaused`
  - `updatedAt`
- Flutter remains the source of truth. Native iOS only mirrors the current session state.
- Unsupported platforms and iOS versions should no-op without disrupting the workout flow.
- End the activity when `SessionStatus.done` is emitted.
- Keep this coordinator injectable so widget tests can replace it with a fake.

### Phase 3 Extension Notes

- The WidgetKit extension target is `LiveActivityExtension`.
- The shared ActivityKit attributes type lives in `ios/Shared/IxerciseWorkoutActivityAttributes.swift`.
- The extension includes:
  - a small static `IxerciseWidget`, matching Apple's Widget Extension template shape
  - `IxerciseLiveActivityWidget`, which renders the lock-screen Live Activity and Dynamic Island regions
  - `IxerciseLiveActivityBundle`, which exposes both widgets
- Runner embeds `LiveActivityExtension.appex` through the `Embed App Extensions` build phase.
- The extension target must use concrete version values for simulator install:
  - `MARKETING_VERSION = 1.0.0`
  - `CURRENT_PROJECT_VERSION = 1`
- Do not point extension version settings at `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` unless the extension target has a base xcconfig that includes `Flutter/Generated.xcconfig`; unresolved or missing extension version values cause simulator install to fail with `Invalid placeholder attributes`.
- The app builds and the integration flow installs on iPhone 17 Pro simulator after these settings.

## Phase 4: Lock-Screen Controls

- Add native App Intents for pause/resume/skip/done.
- Route actions back into shared session state.
- Fall back to opening the app on older iOS versions or unsupported controls.

## Phase 5: Dynamic Island

- Add compact, minimal, and expanded Dynamic Island layouts.
- Keep it informational first; add controls only after lock-screen actions are stable.
