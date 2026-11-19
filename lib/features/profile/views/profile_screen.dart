import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    c.loadProfile();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        final name = '${c.firstName.value} ${c.surname.value}'.trim();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.astronomicalBlue,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name.isNotEmpty ? name : 'User', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                  Text(c.mobile.value, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                children: [
                  _InfoRow(icon: Icons.cake_outlined, label: 'Date of Birth', value: c.dob.value.isNotEmpty ? c.dob.value : '-'),
                  const Divider(height: 24),
                  _InfoRow(icon: Icons.person_outline, label: 'Gender', value: c.gender.value.isNotEmpty ? c.gender.value : '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _MenuItem(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => Get.toNamed(AppRoutes.editProfile)),
            _MenuItem(icon: Icons.info_outline, label: 'About', onTap: () => Get.toNamed(AppRoutes.about)),
            _MenuItem(icon: Icons.menu_book_outlined, label: 'Guidelines', onTap: () => Get.toNamed(AppRoutes.guidelines)),
            _MenuItem(icon: Icons.help_outline, label: 'FAQ', onTap: () => Get.toNamed(AppRoutes.faq)),
            _MenuItem(icon: Icons.logout, label: 'Logout', color: Colors.red, onTap: () {
              Get.find<HomeController>().logout();
            }),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.astronomicalBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: GoogleFonts.poppins(color: c)),
      trailing: Icon(Icons.chevron_right, color: c.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
