import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/design_system/ix_progress_bar.dart';
import 'package:ixercise/features/session/session_controller.dart';

class RestScreen extends ConsumerWidget {
  const RestScreen({
    super.key,
    this.onNavigateRun,
    this.onNavigateDone,
  });

  final VoidCallback? onNavigateRun;
  final VoidCallback? onNavigateDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);
    final int remaining = state.session.remainingSeconds ?? 0;
    final int restTotal = state.plan.items[state.session.currentIndex].restSeconds;
    final double progress = restTotal <= 0 ? 1 : (1 - (remaining / restTotal));

    if (state.session.status == SessionStatus.running) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onNavigateRun?.call());
    } else if (state.session.status == SessionStatus.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onNavigateDone?.call());
    }

    final bool hasNext = state.session.currentIndex + 1 < state.plan.items.length;
    final TrainingExercise? next = hasNext ? state.plan.items[state.session.currentIndex + 1] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: const <Widget>[
                  Text(
                    'REST',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'END',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0x88FFFFFF),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$remaining',
                      style: const TextStyle(
                        fontSize: 150,
                        height: 0.9,
                        color: Colors.white,
                        letterSpacing: -4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SECONDS',
                      style: TextStyle(
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
                      children: const <Widget>[
                        _AdjustButton(label: '-15s'),
                        SizedBox(width: 8),
                        _AdjustButton(label: '-5s'),
                        SizedBox(width: 8),
                        _AdjustButton(label: '+5s'),
                        SizedBox(width: 8),
                        _AdjustButton(label: '+15s'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (next != null)
              Container(
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
                      child: const Icon(Icons.fitness_center_outlined, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'NEXT UP',
                            style: TextStyle(
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
                        state.session.status == SessionStatus.paused ? 'Resume' : 'Pause',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('rest_skip_button'),
                      onPressed: controller.completeOrNext,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A0A0A),
                      ),
                      child: const Text('Skip rest →'),
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
  const _AdjustButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
