import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/data/repositories.dart';

enum IxThemeMode {
  system,
  light,
  dark;

  static IxThemeMode fromName(String? name) {
    for (final IxThemeMode mode in IxThemeMode.values) {
      if (mode.name == name) {
        return mode;
      }
    }
    return IxThemeMode.system;
  }
}

class FeedbackSettings {
  const FeedbackSettings({
    this.soundEffectsEnabled = true,
    this.hapticsEnabled = true,
    this.countdownTicksEnabled = true,
    this.trainingRemindersEnabled = true,
    this.reminderOffsetMinutes = 0,
    this.volume = 0.65,
    this.themeMode = IxThemeMode.system,
  });

  final bool soundEffectsEnabled;
  final bool hapticsEnabled;
  final bool countdownTicksEnabled;
  final bool trainingRemindersEnabled;
  final int reminderOffsetMinutes;
  final double volume;
  final IxThemeMode themeMode;

  FeedbackSettings copyWith({
    bool? soundEffectsEnabled,
    bool? hapticsEnabled,
    bool? countdownTicksEnabled,
    bool? trainingRemindersEnabled,
    int? reminderOffsetMinutes,
    double? volume,
    IxThemeMode? themeMode,
  }) {
    return FeedbackSettings(
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      countdownTicksEnabled:
          countdownTicksEnabled ?? this.countdownTicksEnabled,
      trainingRemindersEnabled:
          trainingRemindersEnabled ?? this.trainingRemindersEnabled,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      volume: volume ?? this.volume,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'soundEffectsEnabled': soundEffectsEnabled,
      'hapticsEnabled': hapticsEnabled,
      'countdownTicksEnabled': countdownTicksEnabled,
      'trainingRemindersEnabled': trainingRemindersEnabled,
      'reminderOffsetMinutes': reminderOffsetMinutes,
      'volume': volume,
      'themeMode': themeMode.name,
    };
  }

  static FeedbackSettings fromJson(Map<String, dynamic> json) {
    final Object? volumeRaw = json['volume'];
    final double volume = volumeRaw is num ? volumeRaw.toDouble() : 0.65;
    return FeedbackSettings(
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      countdownTicksEnabled: json['countdownTicksEnabled'] as bool? ?? true,
      trainingRemindersEnabled:
          json['trainingRemindersEnabled'] as bool? ?? true,
      reminderOffsetMinutes: _validReminderOffset(
        json['reminderOffsetMinutes'] as int? ?? 0,
      ),
      volume: volume.clamp(0, 1).toDouble(),
      themeMode: IxThemeMode.fromName(json['themeMode'] as String?),
    );
  }

  static int _validReminderOffset(int value) {
    return <int>{0, 5, 15}.contains(value) ? value : 0;
  }
}

class FeedbackSettingsController extends StateNotifier<FeedbackSettings> {
  FeedbackSettingsController(this._repository)
    : super(const FeedbackSettings()) {
    _hydrate();
  }

  final FeedbackSettingsRepository _repository;

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    await _save(state.copyWith(soundEffectsEnabled: enabled));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _save(state.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setCountdownTicksEnabled(bool enabled) async {
    await _save(state.copyWith(countdownTicksEnabled: enabled));
  }

  Future<void> setTrainingRemindersEnabled(bool enabled) async {
    await _save(state.copyWith(trainingRemindersEnabled: enabled));
  }

  Future<void> setReminderOffsetMinutes(int minutes) async {
    await _save(
      state.copyWith(
        reminderOffsetMinutes: FeedbackSettings._validReminderOffset(minutes),
      ),
    );
  }

  Future<void> setVolume(double volume) async {
    await _save(state.copyWith(volume: volume.clamp(0, 1).toDouble()));
  }

  Future<void> setThemeMode(IxThemeMode themeMode) async {
    await _save(state.copyWith(themeMode: themeMode));
  }

  Future<void> _hydrate() async {
    final Map<String, dynamic> raw = await _repository.load();
    if (raw.isEmpty) {
      return;
    }
    state = FeedbackSettings.fromJson(raw);
  }

  Future<void> _save(FeedbackSettings next) async {
    state = next;
    await _repository.save(next.toJson());
  }
}

final feedbackSettingsControllerProvider =
    StateNotifierProvider<FeedbackSettingsController, FeedbackSettings>(
      (ref) => FeedbackSettingsController(
        ref.watch(feedbackSettingsRepositoryProvider),
      ),
    );
