import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InfoController>();
    c.loadFAQs();

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (c.faqList.isEmpty) return Center(child: Text('No FAQs available', style: GoogleFonts.poppins(color: AppColors.textMuted)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.faqList.length,
          itemBuilder: (_, i) {
            final f = c.faqList[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(f['question'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(f['answer'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
