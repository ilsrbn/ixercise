import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/settings/feedback_settings_controller.dart';

class SessionFeedbackService {
  SessionFeedbackService(this._ref);

  final Ref _ref;
  final AudioPlayer _player = AudioPlayer(playerId: 'session-feedback');

  Future<void> handle(SessionUiState? previous, SessionUiState next) async {
    if (previous == null) {
      return;
    }

    final FeedbackSettings settings = _ref.read(
      feedbackSettingsControllerProvider,
    );
    final SessionState previousSession = previous.session;
    final SessionState nextSession = next.session;
    final bool startedNewPlan =
        previous.plan.id != next.plan.id &&
        nextSession.status == SessionStatus.running &&
        nextSession.currentIndex == 0;
    final bool enteredRest =
        previousSession.status == SessionStatus.running &&
        nextSession.status == SessionStatus.resting;
    final bool enteredExercise =
        previousSession.status == SessionStatus.resting &&
        nextSession.status == SessionStatus.running;
    final bool finished =
        previousSession.status != SessionStatus.done &&
        nextSession.status == SessionStatus.done;
    final bool shouldTick = _shouldTick(previous, next, settings);

    if (startedNewPlan) {
      await _play(
        'sounds/start.mp3',
        settings: settings,
        haptic: HapticFeedback.mediumImpact,
      );
    } else if (finished) {
      await _play(
        'sounds/finish.wav',
        settings: settings,
        haptic: HapticFeedback.heavyImpact,
      );
    } else if (enteredRest) {
      await _play(
        'sounds/rest.wav',
        settings: settings,
        haptic: HapticFeedback.lightImpact,
      );
    } else if (enteredExercise) {
      await _play(
        'sounds/go.wav',
        settings: settings,
        haptic: HapticFeedback.mediumImpact,
      );
    } else if (shouldTick) {
      await _play(
        'sounds/tick.wav',
        settings: settings,
        haptic: HapticFeedback.selectionClick,
        volumeMultiplier: 0.55,
      );
    }
  }

  bool _shouldTick(
    SessionUiState previous,
    SessionUiState next,
    FeedbackSettings settings,
  ) {
    if (!settings.countdownTicksEnabled) {
      return false;
    }
    final SessionStatus nextStatus = next.session.status;
    final int? previousRemaining = previous.session.remainingSeconds;
    final int? nextRemaining = next.session.remainingSeconds;
    if (previousRemaining == null || nextRemaining == null) {
      return false;
    }
    final bool countdown =
        previousRemaining > nextRemaining &&
        nextRemaining > 0 &&
        nextRemaining <= 3;
    if (nextStatus == SessionStatus.running &&
        next.currentItem.mode == ExerciseMode.time) {
      return countdown;
    }
    if (nextStatus == SessionStatus.resting) {
      return countdown;
    }
    return false;
  }

  Future<void> _play(
    String asset, {
    required FeedbackSettings settings,
    required Future<void> Function() haptic,
    double volumeMultiplier = 1,
  }) async {
    if (settings.hapticsEnabled) {
      try {
        await haptic();
      } catch (_) {
        // Haptics are unavailable in some test/headless environments.
      }
    }
    if (!settings.soundEffectsEnabled) {
      return;
    }

    try {
      await _player.stop();
      await _player.play(
        AssetSource(asset),
        volume: (settings.volume * volumeMultiplier).clamp(0, 1).toDouble(),
      );
    } catch (_) {
      // Audio plugins are unavailable in some test/headless environments.
    }
  }
}

final sessionFeedbackServiceProvider = Provider<SessionFeedbackService>(
  (ref) => SessionFeedbackService(ref),
);
