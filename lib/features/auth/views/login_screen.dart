import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.orbitLine, width: 1),
                      ),
                    ),
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.astronomicalBlue,
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                    ),
                    Positioned(
                      top: 5, right: 15,
                      child: Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.solarGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome',
                style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w700,
                  color: AppColors.astronomicalBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your mobile number to get started',
                style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: c.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                style: GoogleFonts.poppins(fontSize: 18, letterSpacing: 1.5),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Text('+91', style: GoogleFonts.poppins(fontSize: 18, color: AppColors.textSecondary)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 60),
                  hintText: '00000 00000',
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isLoading.value ? null : () => c.sendOtp(),
                  child: c.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send OTP'),
                ),
              )),
              const Spacer(flex: 3),
              Center(
                child: Text(
                  'Powered by CosmoKundli',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
