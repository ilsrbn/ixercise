import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ixercise/app/router.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/features/home/home_controller.dart';
import 'package:ixercise/features/notifications/training_reminder_service.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/session/session_feedback_service.dart';
import 'package:ixercise/features/settings/feedback_settings_controller.dart';

class IxerciseApp extends ConsumerWidget {
  IxerciseApp({super.key, GoRouter? router})
    : _router = router ?? buildRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedbackSettings settings = ref.watch(
      feedbackSettingsControllerProvider,
    );
    ref.listen<SessionUiState>(sessionControllerProvider, (
      SessionUiState? previous,
      SessionUiState next,
    ) {
      ref.read(sessionFeedbackServiceProvider).handle(previous, next);
    });
    ref.listen<HomeState>(homeControllerProvider, (
      HomeState? previous,
      HomeState next,
    ) {
      if (next.isLoading) {
        return;
      }
      if (previous == null ||
          previous.plans != next.plans ||
          previous.schedulesByPlanId != next.schedulesByPlanId) {
        unawaited(
          ref
              .read(trainingReminderServiceProvider)
              .syncAll(
                plans: next.plans,
                schedulesByPlanId: next.schedulesByPlanId,
              ),
        );
      }
    });
    ref.listen<FeedbackSettings>(feedbackSettingsControllerProvider, (
      FeedbackSettings? previous,
      FeedbackSettings next,
    ) {
      if (previous == null ||
          (previous.trainingRemindersEnabled == next.trainingRemindersEnabled &&
              previous.reminderOffsetMinutes == next.reminderOffsetMinutes)) {
        return;
      }
      final HomeState home = ref.read(homeControllerProvider);
      if (home.isLoading) {
        return;
      }
      unawaited(
        ref
            .read(trainingReminderServiceProvider)
            .syncAll(
              plans: home.plans,
              schedulesByPlanId: home.schedulesByPlanId,
            ),
      );
    });

    return MaterialApp.router(
      title: 'Ixercise',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeModeFor(settings.themeMode),
      routerConfig: _router,
    );
  }

  ThemeMode _themeModeFor(IxThemeMode mode) {
    switch (mode) {
      case IxThemeMode.light:
        return ThemeMode.light;
      case IxThemeMode.dark:
        return ThemeMode.dark;
      case IxThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final Color background = dark
        ? const Color(0xFF080808)
        : const Color(0xFFFAFAFA);
    final Color surface = dark ? const Color(0xFF151515) : Colors.white;
    final Color ink = dark ? const Color(0xFFF5F5F5) : const Color(0xFF0A0A0A);
    final Color mute = dark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final Color line = dark ? const Color(0xFF2B2B2B) : const Color(0xFFE8E8E8);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE11D2E),
        brightness: brightness,
        surface: surface,
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: ink, displayColor: ink),
      dividerColor: line,
      extensions: <ThemeExtension<dynamic>>[
        IxThemeColors(
          background: background,
          surface: surface,
          elevatedSurface: dark ? const Color(0xFF1D1D1D) : Colors.white,
          ink: ink,
          mute: mute,
          softMute: dark ? const Color(0xFF8B8B8B) : const Color(0xFF9A9A9A),
          line: line,
          accent: const Color(0xFFE11D2E),
          inverse: dark ? const Color(0xFF0A0A0A) : Colors.white,
        ),
      ],
    );
  }
}
