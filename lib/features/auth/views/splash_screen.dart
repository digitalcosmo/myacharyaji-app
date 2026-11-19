import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/user_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/orbital_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final loggedIn = await UserData.getLoggedIn();
    if (loggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OrbitalLogo(size: 140),
            const SizedBox(height: 16),
            Text(
              'MyAcharyaji',
              style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.tx),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading your cosmic insights…',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx3),
            ),
          ],
        ),
      ),
    );
  }
}
