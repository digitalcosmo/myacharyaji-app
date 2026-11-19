import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Daily rashi predictions for yesterday / today / tomorrow (mock data).
class RashiPredictionScreen extends StatefulWidget {
  const RashiPredictionScreen({super.key});

  @override
  State<RashiPredictionScreen> createState() => _RashiPredictionScreenState();
}

class _RashiPredictionScreenState extends State<RashiPredictionScreen> {
  late int _rashiIndex;
  int _dayIndex = 1; // 0 = yesterday, 1 = today, 2 = tomorrow

  final _dayLabels = ['Yesterday', 'Today', 'Tomorrow'];

  @override
  void initState() {
    super.initState();
    _rashiIndex = (Get.arguments as int?) ?? 0;
  }

  // ── mock predictions keyed by (rashi, day) ──
  Map<String, dynamic> _prediction() {
    final rng = Random(_rashiIndex * 10 + _dayIndex + 7);
    final dims = ['Career', 'Finance', 'Health', 'Social', 'Love'];
    final keys = ['career', 'finance', 'health', 'social', 'love'];

    return {
      'overall': 30 + rng.nextInt(70),
      'summary': _mockSummary(rng),
      'dims': List.generate(5, (i) => {
        'name': dims[i],
        'key': keys[i],
        'score': 20 + rng.nextInt(80),
        'line': _dimLine(keys[i], rng),
      }),
      'tip': _mockTip(rng),
    };
  }

  String _mockSummary(Random r) {
    const pool = [
      'The cosmic currents favour patience and careful decision-making today. Let things unfold naturally.',
      'An energetic day ahead — channels opening in unexpected directions. Stay alert for opportunities.',
      'A reflective period. Inner clarity will guide you better than external advice right now.',
      'Strong GRAH alignment brings momentum. Push important plans forward with confidence.',
      'Mixed cosmic signals suggest a balanced approach. Avoid extremes in decisions or commitments.',
      'A day of consolidation. Secure what you have built rather than chasing new ventures.',
      'Creative energies are high. Express yourself and explore ideas that have been simmering.',
    ];
    return pool[r.nextInt(pool.length)];
  }

  String _dimLine(String dim, Random r) {
    const lines = {
      'career': [
        'Professional momentum building steadily.',
        'Take a step back and reassess priorities.',
        'Collaborations look promising — say yes to teamwork.',
        'A good day to pitch ideas or negotiate.',
      ],
      'finance': [
        'Avoid impulsive spending; review commitments.',
        'Steady inflow expected — stay the course.',
        'An opportunity for smart investment may arise.',
        'Conservative approach pays off today.',
      ],
      'health': [
        'Energy levels are strong — use them wisely.',
        'Rest is as productive as action today.',
        'Hydration and light movement will serve you well.',
        'Mental clarity improves through the day.',
      ],
      'social': [
        'Reconnect with someone you have been meaning to call.',
        'Social energy is high — enjoy gatherings.',
        'Boundaries matter today — protect your peace.',
        'A meaningful conversation is on the cards.',
      ],
      'love': [
        'Emotional openness strengthens bonds.',
        'Give space where it is needed — it will come back.',
        'Small gestures carry large meaning today.',
        'A day for honest, heartfelt communication.',
      ],
    };
    final pool = lines[dim] ?? lines['career']!;
    return pool[r.nextInt(pool.length)];
  }

  String _mockTip(Random r) {
    const tips = [
      'Wear something green to attract positive Budh energy.',
      'Chant "Om Surya Namah" 11 times before sunrise.',
      'Avoid signing contracts or major purchases today.',
      'Donate food grains to the needy for Shani relief.',
      'Offer water to a Peepal tree in the morning.',
      'Meditate for 10 minutes during sunset for Shukra balance.',
      'Light a ghee lamp in the east corner of your home.',
    ];
    return tips[r.nextInt(tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    final p = _prediction();
    final overall = p['overall'] as int;
    final zone = AppColors.zoneOf(overall);
    final dims = p['dims'] as List<Map<String, dynamic>>;
    final now = DateTime.now();
    final date = now.add(Duration(days: _dayIndex - 1));
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${date.day} ${months[date.month - 1]} ${date.year}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.tx), onPressed: () => Get.back()),
        title: Text('Rashi Prediction', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.tx)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // ── Rashi selector row ──
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = i == _rashiIndex;
                return GestureDetector(
                  onTap: () => setState(() => _rashiIndex = i),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: sel ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
                      border: Border.all(color: sel ? AppColors.sun : AppColors.line),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppColors.rashiSymbols[i], style: TextStyle(fontSize: 20, color: sel ? AppColors.sun : AppColors.tx2)),
                        const SizedBox(height: 1),
                        Text(AppColors.rashiNames[i].substring(0, 3), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: sel ? AppColors.sun : AppColors.tx3)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Day toggle ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColors.card),
            child: Row(
              children: List.generate(3, (i) {
                final sel = i == _dayIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _dayIndex = i),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: sel ? AppColors.sun.withValues(alpha: 0.15) : Colors.transparent,
                        border: sel ? Border.all(color: AppColors.sun.withValues(alpha: 0.5)) : null,
                      ),
                      child: Center(
                        child: Text(_dayLabels[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? AppColors.sun : AppColors.tx3)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 18),

          // ── Header card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.card, zone.color.withValues(alpha: 0.08)],
              ),
              border: Border.all(color: zone.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(AppColors.rashiSymbols[_rashiIndex], style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppColors.rashiNames[_rashiIndex], style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx)),
                          Text(dateStr, style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx3)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('$overall', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: zone.color)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: zone.color.withValues(alpha: 0.15)),
                          child: Text(zone.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: zone.color)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(p['summary'] as String, style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 5D breakdown ──
          Text('5D OUTLOOK', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
          const SizedBox(height: 12),
          ...dims.map((d) {
            final score = d['score'] as int;
            final dZone = AppColors.zoneOf(score);
            final color = AppColors.dimensionColor[d['key']] ?? AppColors.sun;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.card,
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                        ),
                        const SizedBox(width: 8),
                        Text(d['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tx)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: dZone.color.withValues(alpha: 0.12)),
                          child: Text('$score', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: dZone.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: AppColors.line),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: score / 100,
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: color)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(d['line'] as String, style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2, height: 1.4)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // ── Cosmic tip ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.sun.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.sun.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.sun, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COSMIC TIP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.sun, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(p['tip'] as String, style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
