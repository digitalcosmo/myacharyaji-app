import 'package:flutter/material.dart';

/// The 7 Zones of Situations from the CK reports. They turn a 5D value into
/// advice and set each bar's colour and arrow icon.
enum Zone {
  critical(0, 15, 'Critical', 'Do only what is essential', [Color(0xFFFF7B84), Color(0xFFD81F26)], Color(0xFFE5252A)),
  severe(16, 35, 'Severe', 'Delay what can wait', [Color(0xFFFFD08A), Color(0xFFF59E0B)], Color(0xFFF59E0B)),
  sensitive(36, 45, 'Sensitive', 'Go slow, double-check', [Color(0xFFFFF5A6), Color(0xFFFACC15)], Color(0xFFFACC15)),
  moderate(46, 55, 'Moderate', 'Proceed with care', [Color(0xFFFFFFFF), Color(0xFFCDCDCD)], Color(0xFFD1D5DB)),
  stable(56, 65, 'Stable', 'Carry on as usual', [Color(0xFFDCFFFF), Color(0xFF00F0FF)], Color(0xFF22D3EE)),
  strong(66, 85, 'Strong', 'Move ahead', [Color(0xFFA8D1FF), Color(0xFF1A8CFF)], Color(0xFF2D7BFF)),
  optimal(86, 100, 'Optimal', 'Make the most of it', [Color(0xFFD3F7C3), Color(0xFF8EE88D)], Color(0xFF5FE08A));

  final int from;
  final int to;
  final String label;
  final String advice;

  /// Bar gradient, light → saturated (left → right), exactly as in the PDFs.
  final List<Color> gradient;

  /// Solid colour for text, dots and calendar cells.
  final Color color;

  const Zone(this.from, this.to, this.label, this.advice, this.gradient, this.color);

  String get svgKey => name;

  /// Zones are whole-percent bands; values are rounded first so 85.6 is
  /// Optimal (shown as 86%), never "85.6 → Strong" next to a "86%" label.
  static Zone of(double v) {
    final r = v.round().clamp(0, 100);
    for (final z in Zone.values) {
      if (r <= z.to) return z;
    }
    return Zone.optimal;
  }

  /// Text colour that stays readable on top of [color].
  Color get onColor => (this == Zone.strong || this == Zone.critical) ? Colors.white : const Color(0xFF0B0D1F);
}
