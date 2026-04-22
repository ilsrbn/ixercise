import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_animated_timer_text.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/design_system/ix_progress_bar.dart';
import 'package:ixercise/features/session/session_controller.dart';

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

class _TrainingRunScreenState extends ConsumerState<TrainingRunScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final SessionUiState state = ref.read(sessionControllerProvider);
      if (state.session.status == SessionStatus.running &&
          state.currentItem.mode == ExerciseMode.time) {
        ref.read(sessionControllerProvider.notifier).tick();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);
    final SessionState session = state.session;
    final TrainingExercise item = state.currentItem;
    final bool isTime = item.mode == ExerciseMode.time;

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
      backgroundColor: const Color(0xFFFAFAFA),
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'END SESSION',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: Color(0xFF9A9A9A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Color(0xFF0A0A0A),
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
                    const Text(
                      'NOW',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Color(0xFF9A9A9A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.exerciseId,
                      style: const TextStyle(
                        fontSize: 52,
                        height: 1,
                        letterSpacing: -1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Icon(Icons.fitness_center_outlined, size: 58),
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
                    const SizedBox(height: 8),
                    Text(
                      isTime ? 'Seconds remaining' : 'Reps to complete',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                    const Spacer(),
                    if (session.currentIndex + 1 < state.plan.items.length)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                color: Color(0xFF9A9A9A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.fitness_center_outlined, size: 16),
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
                              state.plan.items[session.currentIndex + 1].mode ==
                                      ExerciseMode.time
                                  ? '${state.plan.items[session.currentIndex + 1].value}s'
                                  : '×${state.plan.items[session.currentIndex + 1].value}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                        side: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      icon: Icon(
                        session.status == SessionStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                      ),
                      label: Text(
                        session.status == SessionStatus.paused
                            ? 'Resume'
                            : 'Pause',
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
                        backgroundColor: const Color(0xFF0A0A0A),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(isTime ? 'Skip' : 'Done'),
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
