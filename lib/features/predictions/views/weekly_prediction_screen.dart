import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';
import '../../../widgets/dimension_bar.dart';

class WeeklyPredictionScreen extends StatelessWidget {
  const WeeklyPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PredictionController>();
    if (c.currentTab.value != 1) c.switchTab(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Prediction')),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => c.changeWeek(-1)),
                    Column(children: [
                      Text('Week ${c.weekNumber}', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                      Text(c.weekRange, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => c.changeWeek(1)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall Score', style: GoogleFonts.poppins(fontSize: 14)),
                    ZoneBadge(score: c.overallScore),
                  ],
                ),
                Text('${c.overallScore}', style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.astronomicalBlue)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (c.isLoading.value)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('5D Dimensions', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...c.dimensions.map((d) => DimensionBar(dimension: d['key'], label: d['label'], score: d['score'])),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      )),
    );
  }
}
