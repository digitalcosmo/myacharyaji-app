import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class AcharyaCodeScreen extends StatelessWidget {
  const AcharyaCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Acharyaji Code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter your Acharyaji code',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.astronomicalBlue),
              ),
              const SizedBox(height: 8),
              Text(
                'This code links you to your astrologer. Ask them for it if you don\'t have one.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: c.acharyaCodeController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.poppins(fontSize: 18, letterSpacing: 2),
                decoration: const InputDecoration(hintText: 'e.g. ACH001'),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isLoading.value ? null : () => c.validateAcharyaCode(),
                  child: c.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Continue'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
