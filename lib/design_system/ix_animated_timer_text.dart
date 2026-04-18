import 'dart:ui';

import 'package:flutter/material.dart';

class IxAnimatedTimerText extends StatelessWidget {
  const IxAnimatedTimerText({
    super.key,
    required this.text,
    required this.style,
    this.digitWidth,
  });

  final String text;
  final TextStyle style;
  final double? digitWidth;

  @override
  Widget build(BuildContext context) {
    final double baseWidth = digitWidth ?? ((style.fontSize ?? 20) * 0.58);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(text.length, (int index) {
        final String char = text[index];
        final bool isDigit = RegExp(r'\d').hasMatch(char);
        final double width = isDigit ? baseWidth : baseWidth * 0.5;
        final Key currentKey = ValueKey<String>('d-$index-$char');

        return SizedBox(
          width: width,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeInOutSine,
            switchOutCurve: Curves.easeInOutSine,
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final bool incoming = child.key == currentKey;
              final Animation<double> t = incoming ? animation : ReverseAnimation(animation);
              final Animation<Offset> slide = Tween<Offset>(
                begin: incoming ? const Offset(0, -0.45) : Offset.zero,
                end: incoming ? Offset.zero : const Offset(0, 0.45),
              ).animate(CurvedAnimation(parent: t, curve: Curves.easeInOutSine));
              final Animation<double> fade = Tween<double>(
                begin: incoming ? 0 : 1,
                end: incoming ? 1 : 0,
              ).animate(CurvedAnimation(parent: t, curve: Curves.easeInOutSine));
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: Text(
              char,
              key: currentKey,
              style: style.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        );
      }),
    );
  }
}
