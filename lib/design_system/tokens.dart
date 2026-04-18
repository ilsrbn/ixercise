import 'package:flutter/material.dart';

class IxColors {
  const IxColors._();

  static const Color ink = Color(0xFF0A0A0A);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color line = Color(0xFFE8E8E8);
  static const Color mute = Color(0xFF6B6B6B);
  static const Color accent = Color(0xFFE11D2E);
}

class IxSpace {
  const IxSpace._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
}

class IxRadius {
  const IxRadius._();

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
}
