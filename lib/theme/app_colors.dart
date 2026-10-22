import 'package:flutter/material.dart';

/// Every colour in BomaBook comes from here.
///
/// Screens never hard-code a hex value, so a dark theme later is a second
/// set of these values rather than a hunt through every widget.
class AppColors {
  AppColors._();

  // Brand: icon, top bars, main buttons, selected tabs
  static const Color brand = Color(0xFF1F4A33);
  static const Color brandLight = Color(0xFF2F6B48);

  // Surfaces
  static const Color background = Color(0xFFF7F6F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE2DFD6);

  // Text
  static const Color text = Color(0xFF1D2420);
  static const Color textMuted = Color(0xFF6B726C);

  // Meaning. Good news uses a lighter green than the brand so a positive
  // figure never looks like a button.
  static const Color good = Color(0xFF3F8A5A);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningSoft = Color(0xFFFBEFD6);
  static const Color danger = Color(0xFFB3473B);
}