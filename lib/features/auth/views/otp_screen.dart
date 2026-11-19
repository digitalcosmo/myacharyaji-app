import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = Get.arguments as String? ?? '';
    final otpCtrls = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter verification code',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.astronomicalBlue),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to +91 $phone',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  width: 60, height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: otpCtrls[i],
                    focusNode: focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w600),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) focusNodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
                    },
                  ),
                )),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final otp = otpCtrls.map((c) => c.text).join();
                    if (otp.length == 4) {
                      // TODO: verify OTP via API
                      Get.toNamed(AppRoutes.acharyaCode);
                    }
                  },
                  child: const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () { /* TODO: resend OTP */ },
                  child: Text('Resend OTP', style: GoogleFonts.poppins(color: AppColors.solarGold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
