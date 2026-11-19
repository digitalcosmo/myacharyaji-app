import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cosmic_bg.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _otpCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    final phone = c.phoneController.text;

    return Scaffold(
      body: CosmicBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Back + step indicator
                Row(
                  children: [
                    _iconBtn(onTap: () => Get.back(), icon: Icons.chevron_left),
                    const SizedBox(width: 16),
                    _StepDots(current: 2, total: 3),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Verify it\'s you', style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.tx)),
                const SizedBox(height: 8),
                RichText(text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.55),
                  children: [
                    const TextSpan(text: 'Enter the code sent to '),
                    TextSpan(text: '+91 $phone', style: const TextStyle(color: AppColors.tx, fontWeight: FontWeight.w700)),
                  ],
                )),
                const SizedBox(height: 32),

                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => SizedBox(
                    width: 48,
                    height: 60,
                    child: TextField(
                      controller: _otpCtrls[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.tx),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.line)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.sun)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                        if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                      },
                    ),
                  )),
                ),

                const SizedBox(height: 32),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: c.isLoading.value ? null : () {
                      final otp = _otpCtrls.map((ctrl) => ctrl.text).join();
                      if (otp.length >= 4) {
                        c.otpController.text = otp;
                        c.verifyOtp();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sun,
                      foregroundColor: const Color(0xFF1A1205),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1205)))
                        : Text('Verify', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                )),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => c.sendOtp(),
                    child: Text('Resend code', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.sun2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn({required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          color: AppColors.card,
        ),
        child: Icon(icon, color: AppColors.tx, size: 22),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) => Container(
        height: 4,
        width: 40,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: i < current ? AppColors.sun : AppColors.line,
        ),
      )),
    );
  }
}
