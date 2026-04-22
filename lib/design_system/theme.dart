import 'package:flutter/material.dart';

@immutable
class IxThemeColors extends ThemeExtension<IxThemeColors> {
  const IxThemeColors({
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.ink,
    required this.mute,
    required this.softMute,
    required this.line,
    required this.accent,
    required this.inverse,
  });

  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color ink;
  final Color mute;
  final Color softMute;
  final Color line;
  final Color accent;
  final Color inverse;

  @override
  IxThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? ink,
    Color? mute,
    Color? softMute,
    Color? line,
    Color? accent,
    Color? inverse,
  }) {
    return IxThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      ink: ink ?? this.ink,
      mute: mute ?? this.mute,
      softMute: softMute ?? this.softMute,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      inverse: inverse ?? this.inverse,
    );
  }

  @override
  IxThemeColors lerp(ThemeExtension<IxThemeColors>? other, double t) {
    if (other is! IxThemeColors) {
      return this;
    }
    return IxThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      elevatedSurface:
          Color.lerp(elevatedSurface, other.elevatedSurface, t) ??
          elevatedSurface,
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      mute: Color.lerp(mute, other.mute, t) ?? mute,
      softMute: Color.lerp(softMute, other.softMute, t) ?? softMute,
      line: Color.lerp(line, other.line, t) ?? line,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      inverse: Color.lerp(inverse, other.inverse, t) ?? inverse,
    );
  }
}

extension IxThemeContext on BuildContext {
  IxThemeColors get ixColors {
    final ThemeData theme = Theme.of(this);
    final IxThemeColors? colors = theme.extension<IxThemeColors>();
    if (colors != null) {
      return colors;
    }

    final bool dark = theme.brightness == Brightness.dark;
    return IxThemeColors(
      background: dark ? const Color(0xFF080808) : const Color(0xFFFAFAFA),
      surface: dark ? const Color(0xFF151515) : Colors.white,
      elevatedSurface: dark ? const Color(0xFF1D1D1D) : Colors.white,
      ink: dark ? const Color(0xFFF5F5F5) : const Color(0xFF0A0A0A),
      mute: dark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
      softMute: dark ? const Color(0xFF8B8B8B) : const Color(0xFF9A9A9A),
      line: dark ? const Color(0xFF2B2B2B) : const Color(0xFFE8E8E8),
      accent: const Color(0xFFE11D2E),
      inverse: dark ? const Color(0xFF0A0A0A) : Colors.white,
    );
  }
}
