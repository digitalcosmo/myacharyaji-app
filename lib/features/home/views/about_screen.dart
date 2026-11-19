import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InfoController>();
    c.loadConsultantDetails();

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.astronomicalBlue,
                    border: Border.all(color: AppColors.solarGold, width: 2),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text('MyAcharyaji', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('v1.0.0', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (c.isLoading.value)
            const Center(child: CircularProgressIndicator())
          else ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Consultant', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _Row('Name', c.consultantName.value.isNotEmpty ? c.consultantName.value : '-'),
                  _Row('Contact', c.consultantMobile.value.isNotEmpty ? c.consultantMobile.value : '-'),
                  _Row('Email', c.consultantEmail.value.isNotEmpty ? c.consultantEmail.value : '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (c.consultantDescription.value.isNotEmpty)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(c.consultantDescription.value, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
          ],
        ],
      )),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13))),
        ],
      ),
    );
  }
}
