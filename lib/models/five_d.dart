import 'package:flutter/material.dart';

/// One of the five life dimensions returned by every CosmoKundli 5D API.
class Dim {
  final String key;
  final String label;
  final Color color;

  /// 24×24 stroke icon path (same set as the HTML prototype).
  final String icon;

  const Dim(this.key, this.label, this.color, this.icon);
}

/// Display order matches the prototype: Career, Finance, Social, Health, Love.
const List<Dim> kDims = [
  Dim('career', 'Career', Color(0xFFF7B84B), 'M4 8h16v12H4zM9 8V5h6v3'),
  Dim('finance', 'Finance', Color(0xFFFFD889),
      'M12 3v18M16 7H10a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6H8'),
  Dim('social', 'Social', Color(0xFF4FD6C4),
      'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20c.8-3.5 3.3-5 6-5s5.2 1.5 6 5M17 11a2.5 2.5 0 1 0 0-5M17 15c2 .3 3.5 1.8 4 5'),
  Dim('health', 'Health', Color(0xFF7EE0A8),
      'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z'),
  Dim('love', 'Love', Color(0xFFFF8A7A),
      'M12 21l-1-1C5.5 15 3 12.5 3 9a4.5 4.5 0 0 1 9-1 4.5 4.5 0 0 1 9 1c0 3.5-2.5 6-8 11z'),
];

/// Five percentage values (0–100) for a day, week, month or rashi.
class FiveD {
  final double career;
  final double finance;
  final double social;
  final double health;
  final double love;

  const FiveD({
    required this.career,
    required this.finance,
    required this.social,
    required this.health,
    required this.love,
  });

  factory FiveD.fromJson(Map<String, dynamic> j) => FiveD(
        career: parseNum(j['career']),
        finance: parseNum(j['finance']),
        social: parseNum(j['social']),
        health: parseNum(j['health']),
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
      case 'social':
        return social;
      case 'health':
        return health;
      case 'love':
        return love;
      default:
        return average;
    }
  }

  double get average => (career + finance + social + health + love) / 5;
}

double parseNum(dynamic v) {
  if (v is num) return v.toDouble().clamp(0, 100).toDouble();
  final p = double.tryParse('$v');
  return (p ?? 0).clamp(0, 100).toDouble();
}

/// Three-way reading used for dots, chips and legends across the app.
enum Tone { smooth, mixed, careful }

Tone toneOf(double v) => v >= 60
    ? Tone.smooth
    : v >= 45
        ? Tone.mixed
        : Tone.careful;
