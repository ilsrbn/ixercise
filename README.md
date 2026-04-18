# Ixercise Flutter MVP

Ixercise is a Flutter MVP for a focused training flow:

1. Onboarding (exercise cards with required selection)
2. Home overview (no calories block)
3. Training run
4. Rest
5. Done

## Stack

- Flutter + Dart
- Riverpod (`flutter_riverpod`)
- Router (`go_router`)
- Local persistence (`shared_preferences`)

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Tests

Run all unit/widget tests:

```bash
flutter test
```

Run integration flow test:

```bash
flutter test integration_test/app_flow_test.dart -r expanded
```

## Current MVP Flow

1. Select at least one exercise on onboarding.
2. Continue to home.
3. Start training.
4. Complete timed run item and rest item.
5. Complete reps item.
6. Return from done to home.
