import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/done/done_screen.dart';
import 'package:ixercise/features/home/home_controller.dart';
import 'package:ixercise/features/home/home_overview_screen.dart';
import 'package:ixercise/features/onboarding/exercise_icon_preview_screen.dart';
import 'package:ixercise/features/onboarding/onboarding_training_setup_screen.dart';
import 'package:ixercise/features/rest/rest_screen.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/training_run/training_run_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: <RouteBase>[
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
          child: DoneScreen(
            sessionId: state.pathParameters['sessionId'] ?? 'default',
            onBackHome: () => context.go('/home'),
          ),
        ),
      ),
    ],
  );
}

CustomTransitionPage<void> _sessionTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 620),
    child: child,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<Offset> incoming =
              Tween<Offset>(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
              );
          final Animation<Offset> outgoing =
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.38, 0),
              ).animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInOutSine,
                ),
              );
          final Animation<Offset> incomingParallax =
              Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
              );
          final Animation<double> incomingFade =
              Tween<double>(begin: 0.94, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
              );

          return SlideTransition(
            position: outgoing,
            child: SlideTransition(
              position: incoming,
              child: SlideTransition(
                position: incomingParallax,
                child: FadeTransition(opacity: incomingFade, child: child),
              ),
            ),
          );
        },
  );
}
