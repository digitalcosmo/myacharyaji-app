import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../core/theme/app_colors.dart';

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PredictionController>();

    return SafeArea(
      child: Obx(() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text('Planner', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.tx)),
          const SizedBox(height: 4),
          Text('Your personalised 5D outlook', style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx3)),
          const SizedBox(height: 20),

          // Period toggle
          _PeriodToggle(pc: pc),
          const SizedBox(height: 18),

          // Day picker (daily only)
          if (pc.selectedPeriod.value == 'daily') ...[
            _DayStrip(),
            const SizedBox(height: 18),
          ],

          // 5D gauges
          if (pc.isLoading.value)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.sun)))
          else ...[
            _SectionHeader('5D SCORES'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pc.dimensions.map((d) => _DimGauge(
                label: d['label'],
                score: d['score'],
                color: AppColors.dimensionColor[d['key']] ?? AppColors.sun,
              )).toList(),
            ),
            const SizedBox(height: 24),

            // Sentiments
            if (pc.sentiments.isNotEmpty) ...[
              _SectionHeader('SENTIMENTS'),
              const SizedBox(height: 10),
              ...pc.sentiments.map((s) => _SentimentCard(s)),
              const SizedBox(height: 24),
            ],

            // Situations
            if (pc.situations.isNotEmpty) ...[
              _SectionHeader('SITUATIONS'),
              const SizedBox(height: 10),
              ...pc.situations.map((s) => _SituationCard(s)),
            ],
          ],
        ],
      )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4));
}

class _PeriodToggle extends StatelessWidget {
  final PredictionController pc;
  const _PeriodToggle({required this.pc});

  @override
  Widget build(BuildContext context) {
    final periods = ['daily', 'weekly', 'monthly'];
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: periods.map((p) {
          final sel = pc.selectedPeriod.value == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => pc.changePeriod(p),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: sel ? AppColors.sun.withValues(alpha: 0.18) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    p[0].toUpperCase() + p.substring(1),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? AppColors.sun : AppColors.tx3),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day = now.add(Duration(days: i - 3));
          final isToday = i == 3;
          return Container(
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isToday ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
              border: Border.all(color: isToday ? AppColors.sun : AppColors.line),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('EEE').format(day).substring(0, 2),
                  style: GoogleFonts.inter(fontSize: 11, color: isToday ? AppColors.sun : AppColors.tx3)),
                const SizedBox(height: 2),
                Text('${day.day}',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: isToday ? AppColors.sun : AppColors.tx)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DimGauge extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _DimGauge({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.card,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 64, height: 64,
              child: CustomPaint(
                painter: _ArcPainter(score / 100, color),
                child: Center(
                  child: Text('$score', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tx2)),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double pct;
  final Color color;
  _ArcPainter(this.pct, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final bg = Paint()..color = AppColors.line..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
    final fg = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r - 4), 0.75 * pi, 1.5 * pi, false, bg);
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r - 4), 0.75 * pi, 1.5 * pi * pct, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.pct != pct || old.color != color;
}

class _SentimentCard extends StatelessWidget {
  final Map<String, dynamic> s;
  const _SentimentCard(this.s);

  @override
  Widget build(BuildContext context) {
    final dim = s['dimension'] ?? '';
    final color = AppColors.dimensionColor[dim.toString().toLowerCase()] ?? AppColors.sun;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title'] ?? dim, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tx)),
                if (s['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(s['description'], style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SituationCard extends StatelessWidget {
  final Map<String, dynamic> s;
  const _SituationCard(this.s);

  @override
  Widget build(BuildContext context) {
    final zoneVal = s['zone'];
    final zi = zoneVal is num ? AppColors.zoneOf(zoneVal) : null;
    final zoneColor = zi?.color ?? AppColors.tx3;
    final zoneName = zi?.name ?? '$zoneVal';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: zoneColor.withValues(alpha: 0.15),
                ),
                child: Text(zoneName,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: zoneColor)),
              ),
              const Spacer(),
              if (s['dimension'] != null)
                Text(s['dimension'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.tx3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s['title'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tx)),
          if (s['description'] != null) ...[
            const SizedBox(height: 4),
            Text(s['description'], style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
