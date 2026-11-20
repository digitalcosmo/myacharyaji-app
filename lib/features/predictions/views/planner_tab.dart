import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PredictionController>();
    final rc = Get.find<ReportController>();

    return SafeArea(
      child: Obx(() {
        // If no reports, show empty state
        if (!rc.hasReports) return _EmptyState();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Planner',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tx)),
            const SizedBox(height: 4),
            Text('Your personalised 5D outlook',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx3)),
            const SizedBox(height: 16),

            // ── Member selector ──
            if (rc.reportList.length > 1) ...[
              Text('SELECT MEMBER',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tx3,
                      letterSpacing: 1.4)),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rc.reportList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final m = rc.reportList[i];
                    final sel = rc.selectedIndex.value == i;
                    return GestureDetector(
                      onTap: () {
                        rc.selectMember(i);
                        // Re-fetch for new member
                        pc.changePeriod(pc.selectedPeriod.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: sel
                              ? AppColors.sun.withValues(alpha: 0.15)
                              : AppColors.card,
                          border: Border.all(
                              color: sel ? AppColors.sun : AppColors.line),
                        ),
                        child: Center(
                          child: Text(m['Name'] ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      sel ? AppColors.sun : AppColors.tx2)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],

            // ── Period toggle ──
            _PeriodToggle(pc: pc),
            const SizedBox(height: 18),

            // ── Period-specific navigation ──
            _PeriodNav(pc: pc),
            const SizedBox(height: 18),

            // ── 5D gauges ──
            if (pc.isLoading.value)
              const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.sun)))
            else if (pc.dimensions.every((d) => d['score'] == 0))
              _NoDataState()
            else ...[
              // Overall score
              _OverallScoreCard(pc: pc),
              const SizedBox(height: 18),

              _SectionHeader('5D SCORES'),
              const SizedBox(height: 10),
              _DimGrid(pc: pc),
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
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sun.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.sun, size: 36),
            ),
            const SizedBox(height: 20),
            Text('No planner data',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tx)),
            const SizedBox(height: 8),
            Text(
              'Ask your Acharyaji to prepare your reports to unlock the 5D Planner.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.tx3, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDataState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.tx3, size: 48),
          const SizedBox(height: 16),
          Text('No data for this period',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tx2)),
          const SizedBox(height: 6),
          Text('Try a different date or period.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx3)),
        ],
      ),
    );
  }
}

class _OverallScoreCard extends StatelessWidget {
  final PredictionController pc;
  const _OverallScoreCard({required this.pc});

  @override
  Widget build(BuildContext context) {
    final score = pc.overallScore;
    final zone = AppColors.zoneOf(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            zone.color.withValues(alpha: 0.12),
            AppColors.card,
          ],
        ),
        border: Border.all(color: zone.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _ArcPainter(score / 100, zone.color),
              child: Center(
                child: Text('$score',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Score',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.tx3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: zone.color.withValues(alpha: 0.15),
                      ),
                      child: Text(zone.name,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: zone.color)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(zone.description,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.tx2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.tx3,
          letterSpacing: 1.4));
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: sel
                      ? AppColors.sun.withValues(alpha: 0.18)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    p[0].toUpperCase() + p.substring(1),
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.sun : AppColors.tx3),
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

class _PeriodNav extends StatelessWidget {
  final PredictionController pc;
  const _PeriodNav({required this.pc});

  @override
  Widget build(BuildContext context) {
    final period = pc.selectedPeriod.value;

    if (period == 'daily') {
      return _DayStrip(pc: pc);
    } else if (period == 'weekly') {
      return _NavRow(
        label: 'Week ${pc.weekNumber} · ${pc.weekRange}',
        onPrev: pc.hasPrevious.value ? () => pc.changeWeek(-1) : null,
        onNext: pc.hasNext.value ? () => pc.changeWeek(1) : null,
      );
    } else {
      return _NavRow(
        label: pc.monthDisplay,
        onPrev: pc.hasPrevious.value ? () => pc.changeMonth(-1) : null,
        onNext: pc.hasNext.value ? () => pc.changeMonth(1) : null,
      );
    }
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const _NavRow({required this.label, this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _navBtn(Icons.chevron_left, onPrev),
          Expanded(
            child: Center(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tx)),
            ),
          ),
          _navBtn(Icons.chevron_right, onNext),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: enabled
              ? AppColors.sun.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Icon(icon,
            color: enabled
                ? AppColors.sun
                : AppColors.tx3.withValues(alpha: 0.4),
            size: 22),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  final PredictionController pc;
  const _DayStrip({required this.pc});

  @override
  Widget build(BuildContext context) {
    final selected = pc.currentDate.value;
    final now = DateTime.now();

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day = now.add(Duration(days: i - 3));
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final isToday =
              day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;
          return GestureDetector(
            onTap: () {
              pc.currentDate.value = day;
              pc.fetchDaily();
            },
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? AppColors.sun.withValues(alpha: 0.15)
                    : AppColors.card,
                border: Border.all(
                    color: isSelected
                        ? AppColors.sun
                        : isToday
                            ? AppColors.sun.withValues(alpha: 0.3)
                            : AppColors.line),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      DateFormat('EEE').format(day).substring(0, 2),
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.sun
                              : AppColors.tx3)),
                  const SizedBox(height: 2),
                  Text('${day.day}',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.sun
                              : AppColors.tx)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DimGrid extends StatelessWidget {
  final PredictionController pc;
  const _DimGrid({required this.pc});

  @override
  Widget build(BuildContext context) {
    final dims = pc.dimensions;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: dims
          .map((d) => _DimGauge(
                label: d['label'],
                score: d['score'],
                color:
                    AppColors.dimensionColor[d['key']] ?? AppColors.sun,
              ))
          .toList(),
    );
  }
}

class _DimGauge extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _DimGauge(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final zone = AppColors.zoneOf(score);
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
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _ArcPainter(score / 100, color),
                child: Center(
                  child: Text('$score',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tx)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tx2)),
            const SizedBox(height: 2),
            Text(zone.name,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: zone.color)),
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
    final bg = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(r, r), radius: r - 4),
        0.75 * pi,
        1.5 * pi,
        false,
        bg);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(r, r), radius: r - 4),
        0.75 * pi,
        1.5 * pi * pct,
        false,
        fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.pct != pct || old.color != color;
}

class _SentimentCard extends StatelessWidget {
  final Map<String, dynamic> s;
  const _SentimentCard(this.s);

  @override
  Widget build(BuildContext context) {
    final dim = s['dimension'] ?? '';
    final color = AppColors
            .dimensionColor[dim.toString().toLowerCase()] ??
        AppColors.sun;
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
            width: 4,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title'] ?? dim,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tx)),
                if (s['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(s['description'],
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.tx2,
                          height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: zoneColor.withValues(alpha: 0.15),
                ),
                child: Text(zoneName,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: zoneColor)),
              ),
              const Spacer(),
              if (s['dimension'] != null)
                Text(s['dimension'],
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.tx3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s['title'] ?? '',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tx)),
          if (s['description'] != null) ...[
            const SizedBox(height: 4),
            Text(s['description'],
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.tx2, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
