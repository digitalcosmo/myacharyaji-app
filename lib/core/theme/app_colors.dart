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

  // ─── Dark Cosmic Palette ───
  static const bg = Color(0xFF080A1A);
  static const bg2 = Color(0xFF0E1130);
  static const card = Color(0x0EFFFFFF);        // ~5.5% white
  static const card2 = Color(0x17FFFFFF);       // ~9% white
  static const line = Color(0x17FFFFFF);         // ~9% white
  static const surface = Color(0xFF0E1130);

  static const tx = Color(0xFFF1EFFA);          // primary text
  static const tx2 = Color(0xFFB4B0D0);         // secondary text
  static const tx3 = Color(0xFF8682A8);          // muted text

  static const sun = Color(0xFFF7B84B);          // solar gold primary
  static const sun2 = Color(0xFFFFD889);         // solar gold light
  static const teal = Color(0xFF4FD6C4);         // teal accent
  static const vio = Color(0xFF9D8DFF);          // violet accent
  static const rose = Color(0xFFFF8A7A);         // rose accent

  // Legacy aliases for existing code
  static const scaffoldBg = bg;
  static const surfaceLight = bg2;
  static const cardBg = Color(0xFF141733);
  static const astronomicalBlue = Color(0xFF8EA8FF);
  static const solarGold = sun;
  static const orbitLine = line;
  static const textPrimary = tx;
  static const textSecondary = tx2;
  static const textMuted = tx3;

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

  // ─── 5D Dimension Colors (from prototype) ───
  static const dimCareer = Color(0xFFF7B84B);
  static const dimFinance = Color(0xFFFFD889);
  static const dimSocial = Color(0xFF4FD6C4);
  static const dimHealth = Color(0xFF9D8DFF);
  static const dimLove = Color(0xFFFF8A7A);

  static const Map<String, Color> dimensionColor = {
    'career': dimCareer,
    'finance': dimFinance,
    'social': dimSocial,
    'health': dimHealth,
    'love': dimLove,
  };

  static const Map<String, String> dimensionIcon = {
    'career': 'M4 8h16v12H4zM9 8V5h6v3',
    'finance': 'M12 3v18M16 7H10a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6H8',
    'social': 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 6M15 11a3 3 0 1 0 0-6',
    'health': 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z',
    'love': 'M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 0 0 0-7.78z',
  };

  // ─── 5D Dimension Gradients ───
  static const _dimGradients = <String, List<Color>>{
    'career':  [Color(0xFFF7B84B), Color(0xFFD4941A)],
    'finance': [Color(0xFFFFD889), Color(0xFFF7B84B)],
    'health':  [Color(0xFF9D8DFF), Color(0xFF6B5CE7)],
    'social':  [Color(0xFF4FD6C4), Color(0xFF2BAB9A)],
    'love':    [Color(0xFFFF8A7A), Color(0xFFE05545)],
  };

  static List<Color> dimensionGradient(String key) =>
      _dimGradients[key] ?? [sun, sun2];

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

  // ─── Rashi data ───
  static const rashiSymbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
  static const rashiNames = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

  // ─── Report type gradients ───
  static const reportGradients = <String, List<Color>>{
    'blueprint':  [Color(0xFF4FD6C4), Color(0xFF1A8F7F)],
    'trajectory': [Color(0xFFF7B84B), Color(0xFFD4751A)],
    'vibes':      [Color(0xFF9D8DFF), Color(0xFF4B3BB8)],
    'intensity':  [Color(0xFFFF8A7A), Color(0xFFC74040)],
    'planner':    [Color(0xFF689DFF), Color(0xFF2D5BD0)],
  };
}
