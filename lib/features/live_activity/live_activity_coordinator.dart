import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/session/session_controller.dart';

abstract class LiveActivityCoordinator {
  Future<void> sync(SessionUiState? previous, SessionUiState next);
}

class MethodChannelLiveActivityCoordinator implements LiveActivityCoordinator {
  const MethodChannelLiveActivityCoordinator({
    MethodChannel channel = const MethodChannel('ixercise/live_activity'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<void> sync(SessionUiState? previous, SessionUiState next) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    if (next.session.status == SessionStatus.done) {
      await _invoke('end', <String, Object?>{'sessionId': next.plan.id});
      return;
    }

    final LiveActivitySnapshot snapshot = buildLiveActivitySnapshot(next);
    await _invoke('sync', snapshot.toMap());
  }

  Future<void> _invoke(String method, Map<String, Object?> arguments) async {
    try {
      await _channel.invokeMethod<Object?>(method, arguments);
    } on MissingPluginException {
      // iOS bridge is absent in widget/unit tests and on partial native builds.
    } on PlatformException catch (error) {
      if (error.code == 'unsupported') {
        return;
      }
      rethrow;
    }
  }
}

class LiveActivitySnapshot {
  const LiveActivitySnapshot({
    required this.sessionId,
    required this.planName,
    required this.phase,
    required this.title,
    required this.subtitle,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.progress,
    required this.isPaused,
    required this.updatedAt,
  });

  final String sessionId;
  final String planName;
  final String phase;
  final String title;
  final String subtitle;
  final int? remainingSeconds;
  final int? totalSeconds;
  final double progress;
  final bool isPaused;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sessionId': sessionId,
      'planName': planName,
      'phase': phase,
      'title': title,
      'subtitle': subtitle,
      'remainingSeconds': remainingSeconds,
      'totalSeconds': totalSeconds,
      'progress': progress,
      'isPaused': isPaused,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

LiveActivitySnapshot buildLiveActivitySnapshot(SessionUiState state) {
  final TrainingExercise current = state.currentItem;
  final SessionState session = state.session;
  final bool isPaused = session.status == SessionStatus.paused;
  final bool isRest = session.status == SessionStatus.resting;
  final int? remaining = session.remainingSeconds;
  final int? totalSeconds = _totalSecondsFor(state);

  return LiveActivitySnapshot(
    sessionId: state.plan.id,
    planName: state.plan.name,
    phase: _phaseFor(session.status),
    title: isRest ? 'Rest' : current.exerciseId,
    subtitle: _subtitleFor(state),
    remainingSeconds: remaining,
    totalSeconds: totalSeconds,
    progress: _progressFor(state),
    isPaused: isPaused,
    updatedAt: DateTime.now(),
  );
}

String _phaseFor(SessionStatus status) {
  switch (status) {
    case SessionStatus.running:
      return 'Training';
    case SessionStatus.resting:
      return 'Rest';
    case SessionStatus.paused:
      return 'Paused';
    case SessionStatus.done:
      return 'Done';
  }
}

String _subtitleFor(SessionUiState state) {
  final SessionState session = state.session;
  final TrainingExercise current = state.currentItem;
  if (session.status == SessionStatus.resting) {
    final int nextIndex = session.currentIndex + 1;
    if (nextIndex < state.plan.items.length) {
      return 'Next: ${state.plan.items[nextIndex].exerciseId}';
    }
    return 'Workout complete';
  }
  if (session.status == SessionStatus.paused) {
    return current.exerciseId;
  }
  if (current.mode == ExerciseMode.reps) {
    return '${current.value} reps';
  }
  return 'Timer';
}

int? _totalSecondsFor(SessionUiState state) {
  final TrainingExercise current = state.currentItem;
  if (state.session.status == SessionStatus.resting) {
    return current.restSeconds > 0 ? current.restSeconds : null;
  }
  if (current.mode == ExerciseMode.time) {
    return current.value;
  }
  return null;
}

double _progressFor(SessionUiState state) {
  final int totalItems = state.plan.items.length;
  final int completedItems = state.session.status == SessionStatus.done
      ? totalItems
      : state.session.currentIndex;
  final int? totalSeconds = _totalSecondsFor(state);
  final int? remaining = state.session.remainingSeconds;
  if (totalSeconds != null && totalSeconds > 0 && remaining != null) {
    final double phaseProgress = (totalSeconds - remaining) / totalSeconds;
    return ((completedItems + phaseProgress.clamp(0, 1)) / totalItems).clamp(
      0,
      1,
    );
  }
  return (completedItems / totalItems).clamp(0, 1);
}

final liveActivityCoordinatorProvider = Provider<LiveActivityCoordinator>((
  ref,
) {
  return const MethodChannelLiveActivityCoordinator();
});
