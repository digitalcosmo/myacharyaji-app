import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cosmic_bg.dart';

class AcharyaCodeScreen extends StatelessWidget {
  const AcharyaCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      body: CosmicBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.line),
                          color: AppColors.card,
                        ),
                        child: const Icon(Icons.chevron_left, color: AppColors.tx, size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Step 3/3
                    Row(
                      children: List.generate(3, (i) => Container(
                        height: 4, width: 40,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.sun,
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Connect your Acharyaji',
                  style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.tx),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code your Acharyaji shared with you. It links your reports to them.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.55),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACHARYAJI CODE',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: c.acharyaCodeController,
                    textCapitalization: TextCapitalization.characters,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => c.validateAcharyaCode(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.tx, letterSpacing: 3),
                    decoration: InputDecoration(
                      hintText: 'e.g. ACH001',
                      hintStyle: GoogleFonts.spaceGrotesk(fontSize: 20, color: AppColors.tx3.withValues(alpha: 0.5), letterSpacing: 3),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: c.isLoading.value ? null : () => c.validateAcharyaCode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sun,
                      foregroundColor: const Color(0xFF1A1205),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1205)))
                        : Text('Continue', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
