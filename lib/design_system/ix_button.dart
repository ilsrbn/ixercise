import 'package:flutter/material.dart';
import 'package:ixercise/design_system/tokens.dart';

class IxButton extends StatelessWidget {
  const IxButton._({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
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
      backgroundColor: IxColors.accent,
      textColor: Colors.white,
      borderColor: IxColors.accent,
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
      backgroundColor: Colors.transparent,
      textColor: IxColors.ink,
      borderColor: IxColors.line,
      containerKey: const Key('ix_button_ghost_container'),
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Key containerKey;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;

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
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
