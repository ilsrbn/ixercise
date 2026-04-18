# Ixercise Agent Guide

This file is for coding agents working on this repository.

## Project Goal

Build a Flutter MVP for a workout app with this core flow:

1. Onboarding (exercise picker, cards/grid)
2. Home (overview list, no calories analytics block)
3. Training Run
4. Rest (separate screen)
5. Done

## Design Source of Truth

Use the imported Claude design package as visual reference:

- `design_ref/src/screens/onboarding.jsx`
- `design_ref/src/screens/home.jsx`
- `design_ref/src/screens/training.jsx`
- `design_ref/src/ui.jsx`
- `design_ref/uploads/Training app.md` (product notes + full exercise catalog)

Do not revert to default Flutter Material sample look.

## Current Stack

- Flutter / Dart
- `flutter_riverpod`
- `go_router`
- `shared_preferences`
- `flutter_test`
- `integration_test`

## App Structure

- `lib/main.dart`: app entrypoint
- `lib/app/router.dart`: route map
- `lib/app/shell.dart`: `MaterialApp.router` shell
- `lib/features/onboarding/*`: onboarding catalog, controller, screen
- `lib/features/home/*`: home state and screen
- `lib/features/session/*`: session controller over domain engine
- `lib/features/training_run/*`: run screen
- `lib/features/rest/*`: rest screen
- `lib/features/done/*`: completion screen
- `lib/domain/*`: core models + deterministic training engine
- `lib/data/*`: local persistence and repositories
- `lib/design_system/*`: tokens and shared widgets

## Routes

- `/onboarding`
- `/home`
- `/run/:sessionId`
- `/rest/:sessionId`
- `/done/:sessionId`

## Domain Notes

- `ExerciseMode`: `time | reps`
- `SessionStatus`: `running | resting | paused | done`
- Timed item auto-completes on countdown to 0.
- Reps item advances manually.
- Rest is a dedicated phase/screen.

## Onboarding Catalog Requirement

The onboarding list must use the full exercise set from `Training app.md` (100+ entries).

Current implementation source:

- `lib/features/onboarding/exercise_catalog.dart`

Compatibility detail:

- Keep the first exercise card key compatible with tests: `exercise_card_pushups`.

## Visual Direction Rules

- Palette: near-black/white with red accent (`#E11D2E`)
- Thin borders/hairlines
- Large, bold typography for headers and timers
- Rounded pill controls for primary actions
- Sticky bottom CTA on onboarding
- Rest screen uses dark background

## Testing

Unit/widget tests:

```bash
flutter test
```

Integration flow test file:

- `integration_test/app_flow_test.dart`

Note: Flutter `integration_test` is not supported on web targets (`chrome`, `edge`).
Run it on Android/iOS device/emulator.

## Common Pitfalls

1. Avoid running long blocking commands in this environment without user confirmation.
2. Keep existing widget keys used by tests unless tests are updated in the same change.
3. If design and implementation differ, prioritize `design_ref/*` files over generic defaults.

## Current Status

- App compiles and tests were passing before latest visual restyling pass.
- If a failure appears, first check:
  - renamed text assertions in tests
  - changed widget keys
  - route transitions between run/rest/done
