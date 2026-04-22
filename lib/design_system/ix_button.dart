import 'package:flutter/material.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/design_system/tokens.dart';

enum IxButtonTone { primary, ghost }

class IxButton extends StatelessWidget {
  const IxButton._({
    required this.label,
    required this.onPressed,
    required this.tone,
    required this.containerKey,
    super.key,
  });

  factory IxButton.primary({
    required String label,
    VoidCallback? onPressed,
    Key? key,
  }) {
    return IxButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      tone: IxButtonTone.primary,
      containerKey: const Key('ix_button_primary_container'),
    );
  }

  factory IxButton.ghost({
    required String label,
    VoidCallback? onPressed,
    Key? key,
  }) {
    return IxButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      tone: IxButtonTone.ghost,
      containerKey: const Key('ix_button_ghost_container'),
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final IxButtonTone tone;
  final Key containerKey;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    final bool disabled = onPressed == null;
    final bool primary = tone == IxButtonTone.primary;
    final Color backgroundColor = primary ? colors.accent : Colors.transparent;
    final Color textColor = primary ? colors.inverse : colors.ink;
    final Color borderColor = primary ? colors.accent : colors.line;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: IxRadius.pill,
        child: Container(
          key: containerKey,
          padding: const EdgeInsets.symmetric(
            horizontal: IxSpace.lg,
            vertical: IxSpace.sm,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: IxRadius.pill,
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
