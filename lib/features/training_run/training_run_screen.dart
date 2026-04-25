import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_animated_timer_text.dart';
import 'package:ixercise/design_system/ix_phase_transition.dart';
import 'package:ixercise/design_system/ix_progress_bar.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/l10n/app_localizations.dart';

class TrainingRunScreen extends ConsumerStatefulWidget {
  const TrainingRunScreen({
    super.key,
    required this.sessionId,
    this.onNavigateRest,
    this.onNavigateDone,
  });

  final String sessionId;
  final VoidCallback? onNavigateRest;
  final VoidCallback? onNavigateDone;

  @override
  ConsumerState<TrainingRunScreen> createState() => _TrainingRunScreenState();
}

class _TrainingRunScreenState extends ConsumerState<TrainingRunScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(sessionControllerProvider.notifier).reconcileClock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sessionControllerProvider.notifier).reconcileClock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);
    final AppLocalizations l10n = ref.watch(appStringsProvider);
    final SessionState session = state.session;
    final TrainingExercise item = state.currentItem;
    final bool isTime = item.mode == ExerciseMode.time;
    final IxThemeColors colors = context.ixColors;

    if (session.status == SessionStatus.resting) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onNavigateRest?.call(),
      );
    } else if (session.status == SessionStatus.done) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onNavigateDone?.call(),
      );
    }

    final int total = state.plan.items.length;
    final int index = session.currentIndex + 1;
    final double progress = total == 0 ? 0 : session.currentIndex / total;
    final int remaining = session.remainingSeconds ?? 0;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Offstage(offstage: true, child: Text('Training Run')),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: controller.endSession,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        l10n.endSession,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: colors.softMute,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: colors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: IxProgressBar(value: progress, height: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.nowLabel,
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: colors.softMute,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IxPhaseSwitcher(
                      phaseKey: ValueKey<String>(
                        'run-title-${session.currentIndex}-${item.exerciseId}',
                      ),
                      child: Text(
                        item.exerciseId,
                        style: const TextStyle(
                          fontSize: 52,
                          height: 1,
                          letterSpacing: -1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    IxPhaseSwitcher(
                      phaseKey: ValueKey<String>(
                        'run-cluster-${session.currentIndex}-${item.mode.name}',
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ExerciseGroupIcon(
                              group: groupForExerciseId(item.exerciseId),
                              size: 62,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IxAnimatedTimerText(
                            text: isTime
                                ? _fmt(remaining)
                                : item.value.toString(),
                            style: const TextStyle(
                              fontSize: 96,
                              height: 0.9,
                              letterSpacing: -2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        isTime ? l10n.secondsRemaining : l10n.repsToComplete,
                        key: ValueKey<String>(item.mode.name),
                        style: TextStyle(fontSize: 14, color: colors.mute),
                      ),
                    ),
                    const Spacer(),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: session.currentIndex + 1 <
                                state.plan.items.length
                            ? Container(
                                key: ValueKey<String>(
                                  'run-next-${session.currentIndex + 1}',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.line),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      l10n.nextLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        color: colors.softMute,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ExerciseGroupIcon(
                                      group: groupForExerciseId(
                                        state
                                            .plan
                                            .items[session.currentIndex + 1]
                                            .exerciseId,
                                      ),
                                      size: 18,
                                      color: colors.ink,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state
                                            .plan
                                            .items[session.currentIndex + 1]
                                            .exerciseId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      state
                                                  .plan
                                                  .items[session.currentIndex +
                                                      1]
                                                  .mode ==
                                              ExerciseMode.time
                                          ? '${state.plan.items[session.currentIndex + 1].value}s'
                                          : '×${state.plan.items[session.currentIndex + 1].value}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.mute,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey<String>('run-next-none'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.pauseResume,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                        foregroundColor: colors.ink,
                        side: BorderSide(color: colors.line),
                      ),
                      icon: Icon(
                        session.status == SessionStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                      ),
                      label: Text(
                        session.status == SessionStatus.paused
                            ? l10n.resume
                            : l10n.pause,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('run_next_button'),
                      onPressed: controller.completeOrNext,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                        backgroundColor: colors.ink,
                        foregroundColor: colors.inverse,
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(isTime ? l10n.skipLabel : l10n.doneLabel),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0,
              child: TextButton(
                key: const Key('run_tick_button'),
                onPressed: () => controller.tick(seconds: 1),
                child: const Text('tick'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
