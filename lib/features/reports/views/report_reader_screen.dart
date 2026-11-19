import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Mock data generator for report content (no API for these yet)
class _MockData {
  static final _rng = Random(42);

  static const grahNames = ['Surya', 'Chandra', 'Rahu', 'Ketu', 'Guru', 'Shani', 'Mangal', 'Shukra', 'Budh'];
  static const grahEnglish = ['Sun', 'Moon', 'Rahu', 'Ketu', 'Jupiter', 'Saturn', 'Mars', 'Venus', 'Mercury'];
  static const grahSymbols = ['☉', '☾', '☊', '☋', '♃', '♄', '♂', '♀', '☿'];

  static List<int> vibesData(int months) =>
      List.generate(months, (_) => 20 + _rng.nextInt(80));

  static List<List<int>> intensityData(int days) =>
      List.generate(9, (_) => List.generate(days, (_) => 5 + _rng.nextInt(95)));

  static List<int> grahPower() =>
      List.generate(9, (_) => 10 + _rng.nextInt(90));

  static Map<String, int> cosmoPrakruti() => {
    'Agni': 15 + _rng.nextInt(30),
    'Jal': 10 + _rng.nextInt(25),
    'Prithvi': 10 + _rng.nextInt(25),
    'Vayu': 5 + _rng.nextInt(20),
    'Akash': 5 + _rng.nextInt(15),
  };
}

class ReportReaderScreen extends StatelessWidget {
  const ReportReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final type = args['type'] as String? ?? 'blueprint';

    final tabs = _tabsForType(type);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.tx),
            onPressed: () => Get.back(),
          ),
          title: Text(
            _titleForType(type),
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.tx),
          ),
          bottom: TabBar(
            isScrollable: tabs.length > 3,
            indicatorColor: AppColors.sun,
            indicatorWeight: 3,
            labelColor: AppColors.sun,
            unselectedLabelColor: AppColors.tx3,
            labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: tabs.map((t) => Tab(text: t['label'] as String)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((t) => t['widget'] as Widget).toList(),
        ),
      ),
    );
  }

  String _titleForType(String type) {
    switch (type) {
      case 'blueprint': return 'CK Blueprint';
      case 'trajectory': return 'CK Trajectory';
      case 'vibes': return 'CK Vibes';
      case 'intensity': return 'CK Intensity';
      case 'planner': return 'CK Planner';
      default: return 'Report';
    }
  }

  List<Map<String, dynamic>> _tabsForType(String type) {
    switch (type) {
      case 'blueprint':
        return [
          {'label': 'Overview', 'widget': const _BlueprintOverview()},
          {'label': 'GRAH Power', 'widget': const _GrahPowerTab()},
          {'label': 'Prakruti', 'widget': const _PrakrutiTab()},
          {'label': 'How to Read', 'widget': _HowToReadTab(type: type)},
        ];
      case 'vibes':
        return [
          {'label': 'Overview', 'widget': const _VibesOverview()},
          {'label': 'Charts', 'widget': const _VibesChartsTab()},
          {'label': 'How to Read', 'widget': _HowToReadTab(type: type)},
        ];
      case 'intensity':
        return [
          {'label': 'Overview', 'widget': const _IntensityOverview()},
          {'label': 'Charts', 'widget': const _IntensityChartsTab()},
          {'label': 'How to Read', 'widget': _HowToReadTab(type: type)},
        ];
      case 'planner':
        return [
          {'label': 'Overview', 'widget': const _PlannerOverview()},
          {'label': '5D Scores', 'widget': const _Planner5DTab()},
          {'label': 'How to Read', 'widget': _HowToReadTab(type: type)},
        ];
      default: // trajectory
        return [
          {'label': 'Overview', 'widget': const _TrajectoryOverview()},
          {'label': 'GRAH Power', 'widget': const _GrahPowerTab()},
          {'label': 'Vibes', 'widget': const _VibesChartsTab()},
          {'label': 'How to Read', 'widget': _HowToReadTab(type: type)},
        ];
    }
  }
}

// ════════════════════════════════════════
// BLUEPRINT
// ════════════════════════════════════════

class _BlueprintOverview extends StatelessWidget {
  const _BlueprintOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.architecture,
          title: 'Your Cosmic Blueprint',
          body: 'The Blueprint is your foundational cosmic configuration present at birth. '
              'It maps the position of all 9 GRAHs and reveals your inherent strengths, '
              'tendencies and life patterns.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.auto_awesome,
          title: 'Consultation Flow',
          body: 'Blueprint → Diagnosis → Remedy → Tracking\n\n'
              'Your Acharyaji uses the Blueprint as the starting point for all analysis.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.layers,
          title: 'Report Layers',
          body: '• CK Blueprint — Your foundation (this report)\n'
              '• CK Trajectory — Your movement (Vibes + Intensity)\n'
              '• CK Predictions — Your planning (Planner family)',
        ),
      ],
    );
  }
}

// ════════════════════════════════════════
// GRAH POWER (CosmoBal)
// ════════════════════════════════════════

class _GrahPowerTab extends StatelessWidget {
  const _GrahPowerTab();

  @override
  Widget build(BuildContext context) {
    final power = _MockData.grahPower();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('GRAH POWER (CosmoBal)',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Text('How much power each GRAH holds in your birth chart.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2)),
        const SizedBox(height: 18),
        ...List.generate(9, (i) {
          final pct = power[i] / 100;
          final zone = AppColors.zoneOf(power[i]);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
                      Text(_MockData.grahSymbols[i], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(_MockData.grahNames[i], style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: zone.color.withValues(alpha: 0.15),
                        ),
                        child: Text(zone.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: zone.color)),
                      ),
                      const SizedBox(width: 8),
                      Text('${power[i]}%', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tx)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.line),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: zone.color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_MockData.grahEnglish[i], style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════
// PRAKRUTI (Flavour)
// ════════════════════════════════════════

class _PrakrutiTab extends StatelessWidget {
  const _PrakrutiTab();

  @override
  Widget build(BuildContext context) {
    final data = _MockData.cosmoPrakruti();
    final total = data.values.fold<int>(0, (s, v) => s + v);
    final tattvaColors = {
      'Agni': const Color(0xFFFF6B35),
      'Jal': const Color(0xFF4FC3F7),
      'Prithvi': const Color(0xFF8BC34A),
      'Vayu': const Color(0xFFB0BEC5),
      'Akash': const Color(0xFF9D8DFF),
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('COSMO PRAKRUTI (Flavour)',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Text('The elemental composition of your cosmic pattern — which Tattva dominates.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2)),
        const SizedBox(height: 20),

        // Pie-like horizontal bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 24,
            child: Row(
              children: data.entries.map((e) {
                return Expanded(
                  flex: e.value,
                  child: Container(color: tattvaColors[e.key] ?? AppColors.tx3),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 18),

        ...data.entries.map((e) {
          final pct = total > 0 ? (e.value / total * 100).round() : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(width: 14, height: 14, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: tattvaColors[e.key],
                )),
                const SizedBox(width: 10),
                SizedBox(width: 70, child: Text(e.key, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tx))),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.line),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct / 100,
                      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: tattvaColors[e.key])),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$pct%', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.tx)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════
// VIBES
// ════════════════════════════════════════

class _VibesOverview extends StatelessWidget {
  const _VibesOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.waves,
          title: 'GRAH Vibes',
          body: 'Vibes show how favourable or unfavourable each GRAH is during a particular period. '
              'Every transiting GRAH connects with each GRAH in your Blueprint; their combined effect '
              'is that GRAH\'s current Trajectory.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.insights,
          title: 'How to read Vibes',
          body: '1. Find the GRAH you want to check\n'
              '2. Look at the monthly bar — higher is more favourable\n'
              '3. Check the zone colour for quick assessment\n\n'
              'Read Vibes together with Intensity for the full picture.',
        ),
      ],
    );
  }
}

class _VibesChartsTab extends StatelessWidget {
  const _VibesChartsTab();

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('MONTHLY GRAH VIBES',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Text('Bar height = how favourable that GRAH was each month.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2)),
        const SizedBox(height: 18),
        ...List.generate(9, (gi) {
          final data = _MockData.vibesData(12);
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.card,
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_MockData.grahSymbols[gi], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(_MockData.grahNames[gi], style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx)),
                      const SizedBox(width: 6),
                      Text('(${_MockData.grahEnglish[gi]})', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (mi) {
                        final v = data[mi];
                        final zone = AppColors.zoneOf(v);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('$v', style: GoogleFonts.inter(fontSize: 9, color: AppColors.tx3)),
                                const SizedBox(height: 2),
                                Container(
                                  height: v * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: zone.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(months[mi].substring(0, 1), style: GoogleFonts.inter(fontSize: 9, color: AppColors.tx3)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════
// INTENSITY
// ════════════════════════════════════════

class _IntensityOverview extends StatelessWidget {
  const _IntensityOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.flash_on,
          title: 'GRAH Intensity',
          body: 'Intensity shows how strongly each GRAH is activated, day by day. '
              'A higher Intensity zone does NOT automatically mean a better result — '
              'it only means the GRAH is more strongly activated.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.insights,
          title: 'How to read Intensity',
          body: '1. Find the GRAH\n'
              '2. Look for patterns — sustained highs or lows\n'
              '3. Check the Zone — from Critical (barely any push) to Optimal (expect Vibes in full)\n\n'
              'Read Intensity together with Vibes for the full picture.',
        ),
        const SizedBox(height: 14),
        _ZoneLegend(),
      ],
    );
  }
}

class _IntensityChartsTab extends StatelessWidget {
  const _IntensityChartsTab();

  @override
  Widget build(BuildContext context) {
    final days = 30;
    final allData = _MockData.intensityData(days);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('DAILY GRAH INTENSITY',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Text('Daily activation curve for the current month.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2)),
        const SizedBox(height: 18),
        ...List.generate(9, (gi) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.card,
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_MockData.grahSymbols[gi], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(_MockData.grahNames[gi], style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _IntensityCurvePainter(allData[gi]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1', style: GoogleFonts.inter(fontSize: 10, color: AppColors.tx3)),
                      Text('$days', style: GoogleFonts.inter(fontSize: 10, color: AppColors.tx3)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _IntensityCurvePainter extends CustomPainter {
  final List<int> data;
  _IntensityCurvePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final w = size.width;
    final h = size.height;

    // Zone bands
    final zones = [15, 35, 45, 55, 65, 85, 100];
    final zoneColors = AppColors.zoneColors;
    double prevY = h;
    for (int z = 0; z < zones.length; z++) {
      final curY = h - (zones[z] / 100 * h);
      canvas.drawRect(
        Rect.fromLTRB(0, curY, w, prevY),
        Paint()..color = zoneColors[z].withValues(alpha: 0.08),
      );
      prevY = curY;
    }

    // Curve
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * w;
      final y = h - (data[i] / 100 * h);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, Paint()
      ..color = AppColors.sun
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round);

    // Fill under curve
    final fill = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fill, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.sun.withValues(alpha: 0.25), AppColors.sun.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));
  }

  @override
  bool shouldRepaint(covariant _IntensityCurvePainter old) => false;
}

// ════════════════════════════════════════
// TRAJECTORY
// ════════════════════════════════════════

class _TrajectoryOverview extends StatelessWidget {
  const _TrajectoryOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.timeline,
          title: 'CK Trajectory',
          body: 'Trajectory tracks how your cosmic pattern changes over time. '
              'It combines two views:\n\n'
              '• Vibes — the quality (favourable / unfavourable)\n'
              '• Intensity — the strength (how activated)',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.lightbulb_outline,
          title: 'Why both matter',
          body: 'A GRAH can be strongly activated (high Intensity) but unfavourable (low Vibes), '
              'or gently active but very favourable. Reading both together gives the full picture.',
        ),
      ],
    );
  }
}

// ════════════════════════════════════════
// PLANNER
// ════════════════════════════════════════

class _PlannerOverview extends StatelessWidget {
  const _PlannerOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.calendar_month,
          title: 'CK Planner',
          body: 'Your personalised action planner powered by all 9 GRAHs. '
              'The Planner gives daily Sentiments, Situations and 5D scores '
              'across Career, Finance, Health, Social and Love.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.layers,
          title: 'Planner family',
          body: '• Planner — Sentiments & Situations\n'
              '• Planner Plus — adds 5D coverage\n'
              '• Planner Max — adds detailed 5D breakdowns',
        ),
      ],
    );
  }
}

class _Planner5DTab extends StatelessWidget {
  const _Planner5DTab();

  @override
  Widget build(BuildContext context) {
    final dims = ['Career', 'Finance', 'Health', 'Social', 'Love'];
    final keys = ['career', 'finance', 'health', 'social', 'love'];
    final rng = Random(99);
    final scores = List.generate(5, (_) => 20 + rng.nextInt(80));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('5D DIMENSION SCORES',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Text('How your 5 life dimensions shape up this month.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2)),
        const SizedBox(height: 18),
        ...List.generate(5, (i) {
          final color = AppColors.dimensionColor[keys[i]] ?? AppColors.sun;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.card,
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: color.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text('${scores[i]}', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dims[i], style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tx)),
                        const SizedBox(height: 6),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.line),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: scores[i] / 100,
                            child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.sun, size: 22),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.tx)),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5)),
        ],
      ),
    );
  }
}

class _HowToReadTab extends StatelessWidget {
  final String type;
  const _HowToReadTab({required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.menu_book,
          title: 'Understanding the Zones',
          body: 'Every score maps to one of 7 zones. These zones tell you how to act.',
        ),
        const SizedBox(height: 14),
        _ZoneLegend(),
        const SizedBox(height: 14),
        if (type == 'vibes' || type == 'trajectory')
          _InfoCard(
            icon: Icons.bar_chart,
            title: 'Reading Vibes bars',
            body: 'Each bar represents one month. The height shows the Vibes score (0–100). '
                'Higher bars mean more favourable conditions for that GRAH. '
                'The colour matches the Zone.',
          ),
        if (type == 'intensity')
          _InfoCard(
            icon: Icons.show_chart,
            title: 'Reading Intensity curves',
            body: 'The curve plots daily activation. Look for sustained highs (opportunity windows) '
                'and dips (rest phases). The background bands show the Zones. '
                'High Intensity ≠ good or bad — check Vibes for that.',
          ),
        if (type == 'blueprint')
          _InfoCard(
            icon: Icons.pie_chart_outline,
            title: 'Reading GRAH Power',
            body: 'Each GRAH\'s Power (CosmoBal) shows its strength in your birth chart. '
                'The Prakruti (Flavour) shows the elemental balance across all GRAHs. '
                'These are fixed at birth and do not change.',
          ),
        if (type == 'planner')
          _InfoCard(
            icon: Icons.dashboard,
            title: 'Reading 5D Scores',
            body: 'Each dimension (Career, Finance, Health, Social, Love) is scored 0–100. '
                'The score reflects the combined effect of all 9 GRAHs on that life area '
                'for the selected period.',
          ),
      ],
    );
  }
}

class _ZoneLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zones = [
      {'name': 'Optimal', 'range': '86–100', 'says': 'Make the most of it'},
      {'name': 'Strong', 'range': '66–85', 'says': 'Move ahead'},
      {'name': 'Stable', 'range': '56–65', 'says': 'Carry on as usual'},
      {'name': 'Moderate', 'range': '46–55', 'says': 'Proceed with care'},
      {'name': 'Sensitive', 'range': '36–45', 'says': 'Go slow, double-check'},
      {'name': 'Severe', 'range': '16–35', 'says': 'Delay what can wait'},
      {'name': 'Critical', 'range': '0–15', 'says': 'Do only what is essential'},
    ];
    final colors = AppColors.zoneColors.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE 7 ZONES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
          const SizedBox(height: 12),
          ...List.generate(7, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: colors[i],
                )),
                const SizedBox(width: 10),
                SizedBox(width: 80, child: Text(zones[i]['name']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tx))),
                SizedBox(width: 55, child: Text(zones[i]['range']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3))),
                Expanded(child: Text(zones[i]['says']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx2))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
