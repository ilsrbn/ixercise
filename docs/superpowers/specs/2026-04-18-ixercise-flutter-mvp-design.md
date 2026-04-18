# Ixercise Flutter MVP Design Spec

Date: 2026-04-18
Status: Draft for user approval

## 1. Scope

Build a Flutter mobile-first app (web-compatible) for a workout flow with a custom UI system and no Material visual styling.

In-scope screens:
1. Onboarding (single variant: cards/grid exercise picker)
2. Home (single variant: overview MVP)
3. Training Run (single variant: minimal)
4. Rest (dedicated separate screen with Next Up preview)
5. Done (completion summary)

Out of scope for MVP:
1. Alternate onboarding/list view
2. Alternate training/zen view
3. Home calories metrics
4. Background notifications/reminders engine
5. Auth/backend/cloud sync

## 2. Product Flow

1. User enters onboarding and selects exercises (must select at least 1).
2. User continues to Home Overview.
3. User starts a training from Home.
4. Training Run shows current exercise and progress.
5. If exercise has rest > 0, app navigates to Rest screen.
6. Run continues until all exercises complete.
7. Done screen shows completion with elapsed time and return to Home.

## 3. Platform and Tech Choices

1. Flutter (single codebase for Web/iOS/Android adoption)
2. Riverpod for state management
3. go_router for navigation routes
4. shared_preferences for local persistence (versioned schema)
5. Custom design system widgets and tokens

Why this stack:
1. Keeps UI consistent across all targets.
2. Makes later mobile rollout straightforward.
3. Separates training logic from UI for maintainability.

## 4. UX and Visual Direction

Design intent:
1. Minimal + clean strong typography
2. Black/white dominant palette with sparse accent use
3. Accent color reserved for primary CTA and active timer/progress emphasis
4. Fullscreen-feeling run and rest experiences

Primary UI components:
1. Exercise card (icon + label + selected state)
2. Search input
3. Training cards on Home Overview
4. Linear progress bars (overall + exercise progress where relevant)
5. Primary and ghost action buttons

## 5. Information Architecture

Routes:
1. /onboarding
2. /home
3. /run/:sessionId
4. /rest/:sessionId
5. /done/:sessionId

Feature modules:
1. features/onboarding
2. features/home
3. features/training_run
4. features/rest
5. features/done
6. domain (models + training engine)
7. data (storage repositories)
8. design_system (tokens + reusable widgets)

## 6. Domain Model

### Exercise
1. id: String
2. name: String
3. iconKey: String

### TrainingExercise
1. exerciseId: String
2. mode: enum { time, reps }
3. value: int (seconds or reps)
4. restSeconds: int (optional, default 0)

### TrainingPlan
1. id: String
2. name: String
3. items: List<TrainingExercise>

### SessionState
1. planId: String
2. currentIndex: int
3. status: enum { running, resting, paused, done }
4. remainingSeconds: int? (for timed item/rest)
5. startedAt: DateTime
6. elapsedSeconds: int

Validation rules:
1. Training must have at least 1 item
2. value must be > 0
3. restSeconds must be >= 0

## 7. Screen Specifications

### 7.1 Onboarding (Cards Only)

Purpose:
1. Select initial exercise set

UI:
1. Header/title
2. Search field
3. Scrollable exercise cards grid
4. Continue CTA

Behavior:
1. Search filters by name
2. Tap card toggles selection
3. Continue disabled until at least one selected
4. Continue saves selection and navigates to Home

### 7.2 Home (Overview MVP Only)

Purpose:
1. Central hub for training actions

UI:
1. Greeting/title area
2. Primary training card list (saved plans)
3. Quick actions: Start, Create training, Schedule
4. Upcoming schedule summary (minimal text)

Removed:
1. Calories block/metric
2. Non-essential analytics

Behavior:
1. Start opens run flow for selected/default plan
2. Create training opens in-app builder flow (MVP basic)
3. Schedule supports one-off and recurring metadata entry

### 7.3 Training Run (Minimal Only)

Purpose:
1. Focused exercise execution

UI:
1. Overall progress linear bar
2. Current exercise name + icon
3. Timer or reps value large display
4. Optional next-up preview
5. Bottom controls: pause, complete/next, exit

Behavior:
1. Timed exercise auto-completes at 0
2. Reps exercise advances on manual complete
3. If restSeconds > 0, transition to Rest screen
4. Else advance directly to next exercise
5. Last item completion -> Done screen

### 7.4 Rest Screen

Purpose:
1. Dedicated recovery state between exercises

UI:
1. Rest label and countdown
2. Linear timer progress
3. Next Up preview
4. Controls: pause/resume, skip rest

Behavior:
1. Countdown auto-advances when reaches 0
2. Pause stops countdown
3. Skip immediately returns to run on next item

### 7.5 Done Screen

Purpose:
1. Confirm completion and return user to hub

UI:
1. Completion headline
2. Total elapsed time
3. Back Home CTA

Behavior:
1. Back Home clears active session and navigates to Home

## 8. State Management and Data Flow

Providers (Riverpod):
1. exerciseCatalogProvider
2. userExerciseSelectionProvider
3. trainingPlansProvider
4. sessionControllerProvider
5. scheduleProvider

Flow:
1. UI dispatches intents to controllers/notifiers
2. Controllers mutate immutable state
3. Repository persists changes
4. Screens reactively rebuild from provider state

## 9. Persistence Strategy

Storage engine:
1. shared_preferences JSON payloads

Keys:
1. ixercise_schema_version
2. ixercise_selected_exercises
3. ixercise_training_plans
4. ixercise_schedules

Versioning:
1. Include schema version integer
2. Migration function per version bump
3. Corrupt/invalid payload fallback to defaults + safe logging

## 10. Error Handling and Edge Cases

1. Empty training list on Home -> show empty-state CTA to create plan
2. Corrupt local data -> reset affected slice only
3. Timer drift on background tab/app pause -> recompute from timestamps
4. Invalid route sessionId -> redirect to Home
5. Deleting currently running plan is blocked during active session

## 11. Testing Strategy

Unit tests:
1. Training engine transitions (time/reps/rest/done)
2. Validation rules for plans/items
3. Persistence serialization/deserialization and migration

Widget tests:
1. Onboarding continue disabled/enabled state
2. Home overview renders plans and empty states
3. Run screen timer/reps presentation
4. Rest screen pause/skip behaviors

Integration tests:
1. End-to-end flow onboarding -> home -> run -> rest -> done
2. Resume behavior after app restart (persisted state)

## 12. MVP Acceptance Criteria

1. App runs in Flutter web with mobile layout fidelity.
2. Onboarding cards selection required before continue.
3. Home is overview-only and contains no calories UI.
4. Training run uses minimal variant only.
5. Rest is a separate screen with next-up preview.
6. Timed items auto-advance; reps are manual completion.
7. Sessions complete into Done screen with elapsed time.
8. Plans, selected exercises, and schedules persist locally.

## 13. Future-Ready Extensions (Post-MVP)

1. Push/local notifications for schedules
2. Additional visual variants and themes
3. Cloud sync/auth
4. Deeper analytics and trends
5. Wearable/health platform integrations

## 14. Spec Self-Review

Placeholder scan:
1. No TBD/TODO placeholders remain.

Consistency scan:
1. Variants are consistently constrained to onboarding=cards, home=overview, run=minimal.
2. Home calories is consistently excluded.

Scope scan:
1. Spec remains a single coherent MVP and does not require decomposition.

Ambiguity scan:
1. Manual completion behavior for reps and auto completion for timers are explicit.
2. Rest transition conditions are explicit.
