import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive Scale utility.
/// Calculates scale factors based on screen width so that fonts,
/// spacing, and widget sizes adapt fluidly across all devices.
///
/// Reference width: 375 (iPhone 8 / SE2).
/// On smaller screens (e.g. 320) elements shrink; on larger ones they grow.
class RS {
  RS._();

  /// Raw scale factor: screenWidth / 375, clamped to [0.78, 1.4].
  static double scale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w / 375).clamp(0.78, 1.4);
  }

  /// Scale a font size.  Uses a dampened formula so text doesn't
  /// shrink/grow too aggressively:
  ///   result = base * (0.5 + 0.5 * scale)
  /// Clamped so it never drops below 60 % of base.
  static double fontSize(BuildContext context, double base) {
    final s = scale(context);
    return max(base * 0.60, base * (0.5 + 0.5 * s));
  }

  /// Scale spacing / padding proportionally.
  static double space(BuildContext context, double base) {
    final s = scale(context);
    return max(base * 0.55, base * s);
  }

  /// Convenience: screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// True when screen width < 360 (very small phones).
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  /// True when screen width < 400 (normal phones).
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 400;
}
