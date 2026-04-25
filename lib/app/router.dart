import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/done/done_screen.dart';
import 'package:ixercise/features/home/home_controller.dart';
import 'package:ixercise/features/home/home_overview_screen.dart';
import 'package:ixercise/features/onboarding/exercise_icon_preview_screen.dart';
import 'package:ixercise/features/onboarding/language_screen.dart';
import 'package:ixercise/features/onboarding/onboarding_training_setup_screen.dart';
import 'package:ixercise/features/rest/rest_screen.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/features/training_run/training_run_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, _) => Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final LocaleState localeState = ref.watch(localeControllerProvider);
            final HomeState home = ref.watch(homeControllerProvider);
            if (!localeState.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                if (localeState.locale == null) {
                  context.go('/language');
                } else if (!home.isLoading) {
                  context.go(home.plans.isEmpty ? '/onboarding' : '/home');
                }
              });
            }
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
      GoRoute(
        path: '/language',
        builder: (context, _) =>
            LanguageScreen(onSelected: () => context.go('/')),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, _) => OnboardingTrainingSetupScreen(
          onBack: () => context.go('/home'),
          onSaved: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/icon-preview',
        builder: (context, _) => const ExerciseIconPreviewScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, _) => Consumer(
          builder: (BuildContext context, WidgetRef ref, _) =>
              HomeOverviewScreen(
                onCreateTraining: () => context.go('/onboarding'),
                onEditTraining: (TrainingPlan plan) =>
                    context.go('/training/edit/${plan.id}'),
                onDeleteTraining: (TrainingPlan plan) async {
                  final bool? confirmed = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      title: const Text('Delete training?'),
                      content: Text('Remove "${plan.name}" permanently?'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(homeControllerProvider.notifier)
                        .deleteTraining(plan.id);
                  }
                },
                onStartTraining: (TrainingPlan plan) {
                  ref.read(sessionControllerProvider.notifier).startPlan(plan);
                  context.go('/run/${plan.id}');
                },
              ),
        ),
      ),
      GoRoute(
        path: '/training/edit/:planId',
        builder: (context, state) => Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final String planId = state.pathParameters['planId'] ?? '';
            final HomeState home = ref.watch(homeControllerProvider);
            TrainingPlan? plan;
            for (final TrainingPlan p in home.plans) {
              if (p.id == planId) {
                plan = p;
                break;
              }
            }
            if (plan == null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go('/home'),
              );
              return const Scaffold(body: SizedBox.shrink());
            }
            return OnboardingTrainingSetupScreen(
              initialPlan: plan,
              initialSchedule: home.schedulesByPlanId[planId],
              onBack: () => context.go('/home'),
              onSaved: () => context.go('/home'),
            );
          },
        ),
      ),
      GoRoute(
        path: '/run/:sessionId',
        pageBuilder: (context, state) => _sessionTransitionPage(
          state: state,
          kind: SessionTransitionKind.start,
          child: TrainingRunScreen(
            sessionId: state.pathParameters['sessionId'] ?? 'default',
            onNavigateRest: () =>
                context.go('/rest/${state.pathParameters['sessionId']}'),
            onNavigateDone: () =>
                context.go('/done/${state.pathParameters['sessionId']}'),
          ),
        ),
      ),
      GoRoute(
        path: '/rest/:sessionId',
        pageBuilder: (context, state) => _sessionTransitionPage(
          state: state,
          kind: SessionTransitionKind.phase,
          child: RestScreen(
            sessionId: state.pathParameters['sessionId'] ?? 'default',
            onNavigateRun: () =>
                context.go('/run/${state.pathParameters['sessionId']}'),
            onNavigateDone: () =>
                context.go('/done/${state.pathParameters['sessionId']}'),
          ),
        ),
      ),
      GoRoute(
        path: '/done/:sessionId',
        pageBuilder: (context, state) => _sessionTransitionPage(
          state: state,
          kind: SessionTransitionKind.done,
          child: DoneScreen(
            sessionId: state.pathParameters['sessionId'] ?? 'default',
            onBackHome: () => context.go('/home'),
          ),
        ),
      ),
    ],
  );
}

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
        : const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return switch (kind) {
        SessionTransitionKind.start =>
          _startTrainingTransition(animation, child),
        SessionTransitionKind.phase ||
        SessionTransitionKind.done =>
          _phaseTransition(animation, secondaryAnimation, child),
      };
    },
  );
}

Widget _startTrainingTransition(
  Animation<double> animation,
  Widget child,
) {
  final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
  );
  final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
  );
  final slide = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  return FadeTransition(
    opacity: fade,
    child: ScaleTransition(
      scale: scale,
      child: SlideTransition(position: slide, child: child),
    ),
  );
}

Widget _phaseTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = Tween<Offset>(
    begin: const Offset(0.10, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutSine));
  final outgoing = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.08, 0),
  ).animate(
    CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutSine),
  );
  final incomingFade = Tween<double>(begin: 0.88, end: 1.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
  );

  return SlideTransition(
    position: outgoing,
    child: SlideTransition(
      position: incoming,
      child: FadeTransition(opacity: incomingFade, child: child),
    ),
  );
}
