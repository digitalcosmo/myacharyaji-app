import 'package:flutter/material.dart';

class ZoneInfo {
  final String name;
  final String description;
  final Color color;
  final int index;
  const ZoneInfo({required this.name, required this.description, required this.color, required this.index});
}

class AppColors {
  AppColors._();

  // ─── App Theme (Light Astronomical) ───
  static const scaffoldBg = Color(0xFFF5F7FA);
  static const surfaceLight = Color(0xFFE8EEF6);
  static const cardBg = Colors.white;
  static const astronomicalBlue = Color(0xFF1A3A6B);
  static const solarGold = Color(0xFFC9963B);
  static const orbitLine = Color(0xFFB0C4E0);
  static const textPrimary = Color(0xFF1A1D26);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // ─── CVPT Report Palette ───
  static const reportBlue = Color(0xFF689DFF);
  static const reportBlueIce = Color(0xFFCEE0FF);
  static const reportOrange = Color(0xFFF07E22);
  static const reportGreen = Color(0xFF12BA82);
  static const reportDarkBg = Color(0xFF0A2A6B);

  // ─── Sentiment ───
  static const sentimentPositive = Color(0xFF55E08B);
  static const sentimentNegative = Color(0xFFE41E1E);

  // ─── 7 Zones ───
  static const zoneCritical = Color(0xFFE5252A);
  static const zoneSevere = Color(0xFFF59E0B);
  static const zoneSensitive = Color(0xFFFACC15);
  static const zoneModerate = Color(0xFFD1D5DB);
  static const zoneStable = Color(0xFF22D3EE);
  static const zoneStrong = Color(0xFF2D7BFF);
  static const zoneOptimal = Color(0xFF5FE08A);

  static const List<Color> zoneColors = [
    zoneCritical, zoneSevere, zoneSensitive, zoneModerate,
    zoneStable, zoneStrong, zoneOptimal,
  ];

  static const List<String> zoneNames = [
    'Critical', 'Severe', 'Sensitive', 'Moderate',
    'Stable', 'Strong', 'Optimal',
  ];

  static const List<String> zoneSays = [
    'Do only what is essential', 'Delay what can wait',
    'Go slow, double-check', 'Proceed with care',
    'Carry on as usual', 'Move ahead', 'Make the most of it',
  ];

  /// Zone thresholds: value 0-100 → ZoneInfo
  static ZoneInfo zoneOf(num v) {
    int idx;
    if (v <= 15) { idx = 0; }
    else if (v <= 35) { idx = 1; }
    else if (v <= 45) { idx = 2; }
    else if (v <= 55) { idx = 3; }
    else if (v <= 65) { idx = 4; }
    else if (v <= 85) { idx = 5; }
    else { idx = 6; }
    return ZoneInfo(
      name: zoneNames[idx],
      description: zoneSays[idx],
      color: zoneColors[idx],
      index: idx,
    );
  }

  // ─── 5D Dimension Gradients ───
  static const _dimGradients = <String, List<Color>>{
    'career':  [Color(0xFFD3F7C3), Color(0xFF8EE88D)],
    'finance': [Color(0xFFA8D1FF), Color(0xFF1A8CFF)],
    'health':  [Color(0xFFDCFFFF), Color(0xFF00F0FF)],
    'social':  [Color(0xFFFFFFFF), Color(0xFFCDCDCD)],
    'love':    [Color(0xFFFF7B84), Color(0xFFD81F26)],
  };

  static List<Color> dimensionGradient(String key) =>
      _dimGradients[key] ?? [reportBlue, reportBlueIce];

  // ─── Zone Bar Gradients ───
  static List<List<Color>> zoneBarGradients = [
    [const Color(0xFFFF7B84), const Color(0xFFD81F26)],
    [const Color(0xFFFFD08A), const Color(0xFFF59E0B)],
    [const Color(0xFFFFF5A6), const Color(0xFFFACC15)],
    [const Color(0xFFFFFFFF), const Color(0xFFCDCDCD)],
    [const Color(0xFFDCFFFF), const Color(0xFF00F0FF)],
    [const Color(0xFFA8D1FF), const Color(0xFF1A8CFF)],
    [const Color(0xFFD3F7C3), const Color(0xFF8EE88D)],
  ];
}
