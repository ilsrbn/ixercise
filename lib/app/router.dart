import 'package:go_router/go_router.dart';
import 'package:ixercise/features/done/done_screen.dart';
import 'package:ixercise/features/home/home_overview_screen.dart';
import 'package:ixercise/features/onboarding/onboarding_screen.dart';
import 'package:ixercise/features/rest/rest_screen.dart';
import 'package:ixercise/features/training_run/training_run_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (context, _) => OnboardingScreen(
          onContinue: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, _) => HomeOverviewScreen(
          onStartTraining: () => context.go('/run/default'),
        ),
      ),
      GoRoute(
        path: '/run/:sessionId',
        builder: (context, state) => TrainingRunScreen(
          onNavigateRest: () => context.go('/rest/${state.pathParameters['sessionId']}'),
          onNavigateDone: () => context.go('/done/${state.pathParameters['sessionId']}'),
        ),
      ),
      GoRoute(
        path: '/rest/:sessionId',
        builder: (context, state) => RestScreen(
          onNavigateRun: () => context.go('/run/${state.pathParameters['sessionId']}'),
          onNavigateDone: () => context.go('/done/${state.pathParameters['sessionId']}'),
        ),
      ),
      GoRoute(
        path: '/done/:sessionId',
        builder: (context, _) => DoneScreen(
          onBackHome: () => context.go('/home'),
        ),
      ),
    ],
  );
}
