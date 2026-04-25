import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/features/settings/feedback_settings_controller.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/l10n/app_localizations.dart';

class FeedbackSettingsSheet extends ConsumerWidget {
  const FeedbackSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedbackSettings settings = ref.watch(
      feedbackSettingsControllerProvider,
    );
    final FeedbackSettingsController controller = ref.read(
      feedbackSettingsControllerProvider.notifier,
    );
    final LocaleState localeState = ref.watch(localeControllerProvider);
    final AppLocalizations l10n = ref.watch(appStringsProvider);
    final IxThemeColors colors = context.ixColors;

    final double maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: ColoredBox(
        color: colors.background,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ThemeModePicker(
                    value: settings.themeMode,
                    onChanged: controller.setThemeMode,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 14),
                  _LanguagePicker(
                    current: localeState.locale?.languageCode ?? 'en',
                    onChanged: (String code) => ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(Locale(code)),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 14),
                  _SwitchRow(
                    icon: Icons.volume_up_outlined,
                    label: l10n.soundEffects,
                    value: settings.soundEffectsEnabled,
                    onChanged: controller.setSoundEffectsEnabled,
                  ),
                  _SwitchRow(
                    icon: Icons.vibration_rounded,
                    label: l10n.haptics,
                    value: settings.hapticsEnabled,
                    onChanged: controller.setHapticsEnabled,
                  ),
                  _SwitchRow(
                    icon: Icons.timer_outlined,
                    label: l10n.countdownTicks,
                    value: settings.countdownTicksEnabled,
                    onChanged: controller.setCountdownTicksEnabled,
                  ),
                  _SwitchRow(
                    icon: Icons.notifications_active_outlined,
                    label: l10n.trainingReminders,
                    value: settings.trainingRemindersEnabled,
                    onChanged: controller.setTrainingRemindersEnabled,
                  ),
                  if (settings.trainingRemindersEnabled) ...<Widget>[
                    const SizedBox(height: 6),
                    _ReminderOffsetPicker(
                      value: settings.reminderOffsetMinutes,
                      onChanged: controller.setReminderOffsetMinutes,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.graphic_eq_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              l10n.soundVolume,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(settings.volume * 100).round()}%',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.mute,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: colors.ink,
                            inactiveTrackColor: colors.line,
                            thumbColor: colors.ink,
                            overlayColor: colors.ink.withValues(alpha: 0.08),
                          ),
                          child: Slider(
                            value: settings.volume,
                            onChanged: settings.soundEffectsEnabled
                                ? controller.setVolume
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.current,
    required this.onChanged,
    required this.l10n,
  });

  final String current;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: <Widget>[
          _LangSegment(
            label: l10n.langEnglish,
            active: current == 'en',
            onTap: () => onChanged('en'),
          ),
          _LangSegment(
            label: l10n.langUkrainian,
            active: current == 'uk',
            onTap: () => onChanged('uk'),
          ),
        ],
      ),
    );
  }
}

class _LangSegment extends StatelessWidget {
  const _LangSegment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: active ? colors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? colors.inverse : colors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderOffsetPicker extends StatelessWidget {
  const _ReminderOffsetPicker({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.schedule_rounded, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.reminderTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _ReminderOffsetSegment(
                label: l10n.atTime,
                active: value == 0,
                onTap: () => onChanged(0),
              ),
              _ReminderOffsetSegment(
                label: l10n.fiveMin,
                active: value == 5,
                onTap: () => onChanged(5),
              ),
              _ReminderOffsetSegment(
                label: l10n.fifteenMin,
                active: value == 15,
                onTap: () => onChanged(15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderOffsetSegment extends StatelessWidget {
  const _ReminderOffsetSegment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          margin: const EdgeInsets.only(right: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? colors.ink : colors.elevatedSurface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: active ? colors.ink : colors.line),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? colors.inverse : colors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: colors.ink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final IxThemeMode value;
  final ValueChanged<IxThemeMode> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: <Widget>[
          _ThemeModeSegment(
            label: l10n.systemTheme,
            icon: Icons.brightness_auto_rounded,
            active: value == IxThemeMode.system,
            onTap: () => onChanged(IxThemeMode.system),
          ),
          _ThemeModeSegment(
            label: l10n.lightTheme,
            icon: Icons.light_mode_outlined,
            active: value == IxThemeMode.light,
            onTap: () => onChanged(IxThemeMode.light),
          ),
          _ThemeModeSegment(
            label: l10n.darkTheme,
            icon: Icons.dark_mode_outlined,
            active: value == IxThemeMode.dark,
            onTap: () => onChanged(IxThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSegment extends StatelessWidget {
  const _ThemeModeSegment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: active ? colors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 17, color: active ? colors.inverse : colors.ink),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? colors.inverse : colors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
