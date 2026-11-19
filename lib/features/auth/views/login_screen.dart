import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cosmic_bg.dart';
import '../../../widgets/orbital_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CosmicBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const OrbitalLogo(size: 120),
                const SizedBox(height: 8),
                Text(
                  'MyAcharyaji',
                  style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.tx),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your reports and planners from your Acharyaji, beautifully in one place.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.55),
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MOBILE NUMBER',
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
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Text('+91', style: GoogleFonts.inter(fontSize: 18, color: AppColors.tx2, fontWeight: FontWeight.w600)),
                      Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.line),
                      Expanded(
                        child: TextField(
                          controller: c.phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: GoogleFonts.inter(fontSize: 18, color: AppColors.tx, letterSpacing: 0.5),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '98XXX XXXXX',
                            hintStyle: GoogleFonts.inter(fontSize: 18, color: AppColors.tx3.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            filled: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: c.isLoading.value ? null : () => c.sendOtp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sun,
                      foregroundColor: const Color(0xFF1A1205),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      elevation: 0,
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1205)))
                        : Text('Send OTP', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                )),
                const SizedBox(height: 24),
                Text(
                  'By continuing, you agree to our terms of service',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
