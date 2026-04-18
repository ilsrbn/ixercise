import 'package:flutter/material.dart';
import 'package:ixercise/design_system/tokens.dart';

class IxProgressBar extends StatelessWidget {
  const IxProgressBar({
    required this.value,
    this.height = 8,
    super.key,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.clamp(0, 1);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: IxColors.line,
        borderRadius: IxRadius.pill,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * safeValue,
              decoration: const BoxDecoration(
                color: IxColors.accent,
                borderRadius: IxRadius.pill,
              ),
            ),
          );
        },
      ),
    );
  }
}
