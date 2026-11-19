import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InfoController>();
    c.loadGuidelines();

    return Scaffold(
      appBar: AppBar(title: const Text('Guidelines')),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (c.guidelineContent.value.isEmpty) {
          return Center(child: Text('No guidelines available', style: GoogleFonts.poppins(color: AppColors.textMuted)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Text(
              c.guidelineContent.value,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
          ),
        );
      }),
    );
  }
}
