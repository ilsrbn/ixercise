import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_animated_timer_text.dart';
import 'package:ixercise/design_system/ix_phase_transition.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/design_system/ix_progress_bar.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/l10n/app_localizations.dart';

class RestScreen extends ConsumerStatefulWidget {
  const RestScreen({
    super.key,
    required this.sessionId,
    this.onNavigateRun,
    this.onNavigateDone,
  });

  final String sessionId;
  final VoidCallback? onNavigateRun;
  final VoidCallback? onNavigateDone;

  @override
  ConsumerState<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends ConsumerState<RestScreen>
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
    final int remaining = state.session.remainingSeconds ?? 0;
    final int restTotal =
        state.plan.items[state.session.currentIndex].restSeconds;
    final double progress = restTotal <= 0 ? 1 : (1 - (remaining / restTotal));
    final int total = state.plan.items.length;
    final int index = state.session.currentIndex + 1;
    final double overallProgress = total == 0 ? 0 : state.session.currentIndex / total;

    if (state.session.status == SessionStatus.running) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onNavigateRun?.call(),
      );
    } else if (state.session.status == SessionStatus.done) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onNavigateDone?.call(),
      );
    }

    final bool hasNext =
        state.session.currentIndex + 1 < state.plan.items.length;
    final TrainingExercise? next = hasNext
        ? state.plan.items[state.session.currentIndex + 1]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Offstage(offstage: true, child: Text('Rest')),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: <Widget>[
                  const Text(
                    'REST',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Color(0x88FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: controller.endSession,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        l10n.endLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0x88FFFFFF),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: IxProgressBar(value: overallProgress, height: 3),
            ),
            Expanded(
              child: IxPhaseSwitcher(
                phaseKey: ValueKey<String>(
                  'rest-${state.session.currentIndex}',
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IxAnimatedTimerText(
                        text: '$remaining',
                        style: const TextStyle(
                          fontSize: 150,
                          height: 0.9,
                          color: Colors.white,
                          letterSpacing: -2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.secondsLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.4,
                          color: Color(0x88FFFFFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      IxProgressBar(value: progress, height: 3),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _AdjustButton(
                            label: '-15s',
                            onPressed: () =>
                                controller.adjustRestSeconds(-15),
                          ),
                          const SizedBox(width: 8),
                          _AdjustButton(
                            label: '-5s',
                            onPressed: () => controller.adjustRestSeconds(-5),
                          ),
                          const SizedBox(width: 8),
                          _AdjustButton(
                            label: '+5s',
                            onPressed: () => controller.adjustRestSeconds(5),
                          ),
                          const SizedBox(width: 8),
                          _AdjustButton(
                            label: '+15s',
                            onPressed: () =>
                                controller.adjustRestSeconds(15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: next != null
                  ? Container(
                      key: ValueKey<String>(
                        'rest-next-${next.exerciseId}-${state.session.currentIndex}',
                      ),
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExerciseGroupIcon(
                              group: groupForExerciseId(next.exerciseId),
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.nextUpLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.3,
                                    color: Color(0x88FFFFFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  next.exerciseId,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('rest-next-none'),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.pauseResume,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Color(0x33FFFFFF)),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        state.session.status == SessionStatus.paused
                            ? l10n.resume
                            : l10n.pause,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('rest_skip_button'),
                      onPressed: controller.skipRest,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A0A0A),
                      ),
                      child: Text(l10n.skipRest),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0,
              child: TextButton(
                key: const Key('rest_tick_button'),
                onPressed: () => controller.tick(seconds: 1),
                child: const Text('tick'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0x33FFFFFF)),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
