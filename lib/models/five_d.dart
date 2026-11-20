import 'package:flutter/material.dart';
import '../ui/tabler_icons.dart';

/// One of the five life dimensions returned by every CosmoKundli 5D API.
class Dim {
  final String key;
  final String label;

  /// What this dimension means (wording from the CK report guide).
  final String meaning;

  /// Identity colour — icons, chips and chart tint. Bars themselves are
  /// coloured by zone, as in the printed reports.
  final Color color;

  /// Tabler stroke icon markup.
  final String icon;

  const Dim(this.key, this.label, this.meaning, this.color, this.icon);
}

/// Fixed order everywhere, as in the CK reports:
/// Career, Finance, Health, Social, Love.
const List<Dim> kDims = [
  Dim('career', 'Career', 'How smoothly things go', Color(0xFFF5A524), TablerIcons.career),
  Dim('finance', 'Finance', 'Outcome of your efforts', Color(0xFFA78BFA), TablerIcons.finance),
  Dim('health', 'Health', 'Your holistic health', Color(0xFF34D399), TablerIcons.health),
  Dim('social', 'Social', 'Dealings with people', Color(0xFF38BDF8), TablerIcons.social),
  Dim('love', 'Love', 'People close to you', Color(0xFFF472B6), TablerIcons.love),
];

Dim dimByKey(String key) => kDims.firstWhere((d) => d.key == key, orElse: () => kDims.first);

/// Five percentage values (0–100) for a day, week, month or rashi.
///
/// There is deliberately no "average": the five dimensions measure different
/// things, so combining them into one number would mean nothing.
class FiveD {
  final double career;
  final double finance;
  final double health;
  final double social;
  final double love;

  const FiveD({
    required this.career,
    required this.finance,
    required this.health,
    required this.social,
    required this.love,
  });

  factory FiveD.fromJson(Map<String, dynamic> j) => FiveD(
        career: parseNum(j['career']),
        finance: parseNum(j['finance']),
        health: parseNum(j['health']),
        social: parseNum(j['social']),
        love: parseNum(j['love']),
      );

  /// True when the payload actually carries the five keys.
  static bool isPresentIn(Map<String, dynamic> j) =>
      kDims.every((d) => j.containsKey(d.key) && j[d.key] != null);

  double of(String key) {
    switch (key) {
      case 'career':
        return career;
      case 'finance':
        return finance;
      case 'health':
        return health;
      case 'social':
        return social;
      case 'love':
        return love;
      default:
        throw ArgumentError('Unknown dimension $key');
    }
  }
}

double parseNum(dynamic v) {
  if (v is num) return v.toDouble().clamp(0, 100).toDouble();
  final p = double.tryParse('$v');
  return (p ?? 0).clamp(0, 100).toDouble();
}
