import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';

class AcharyajiTab extends StatelessWidget {
  const AcharyajiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();

    return SafeArea(
      child: Obx(() {
        if (ic.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.sun));
        }
        final c = <String, dynamic>{
          'Name': ic.consultantName.value,
          'Mobile': ic.consultantMobile.value,
          'Email': ic.consultantEmail.value,
          'About': ic.consultantDescription.value,
          'City': ic.consultantAddress.value,
        };
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Your Acharyaji', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.tx)),
            const SizedBox(height: 20),

            // Avatar + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.sun, Color(0xFFB9741A)],
                      ),
                      boxShadow: [BoxShadow(color: AppColors.sun.withValues(alpha: 0.3), blurRadius: 24)],
                    ),
                    child: Center(
                      child: Text(
                        _initials(c['Name'] ?? 'A'),
                        style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.bg),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c['Name'] ?? 'Acharyaji', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
                        child: const Icon(Icons.check, size: 12, color: AppColors.bg),
                      ),
                    ],
                  ),
                  if (c['Specialization'] != null) ...[
                    const SizedBox(height: 4),
                    Text(c['Specialization'], style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx3)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                _ActionBtn(icon: Icons.phone_outlined, label: 'Call', color: AppColors.teal,
                  onTap: () => _launchAction('tel', c['Mobile'])),
                const SizedBox(width: 12),
                _ActionBtn(icon: Icons.chat_outlined, label: 'WhatsApp', color: Color(0xFF25D366),
                  onTap: () => _launchAction('whatsapp', c['Mobile'])),
                const SizedBox(width: 12),
                _ActionBtn(icon: Icons.calendar_today_outlined, label: 'Book', color: AppColors.vio,
                  onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),

            // About
            if (c['About'] != null && (c['About'] as String).isNotEmpty) ...[
              _Section(title: 'About', child: Text(c['About'], style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5))),
              const SizedBox(height: 16),
            ],

            // Details
            _Section(
              title: 'Details',
              child: Column(
                children: [
                  if (c['Experience'] != null) _DetailRow('Experience', '${c['Experience']} years'),
                  if (c['City'] != null) _DetailRow('Location', c['City']),
                  if (c['Language'] != null) _DetailRow('Languages', c['Language']),
                  if (c['Email'] != null) _DetailRow('Email', c['Email']),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Available reports
            _Section(
              title: 'Available Reports',
              child: Column(
                children: [
                  _ReportItem('Blueprint', Icons.architecture, AppColors.vio),
                  _ReportItem('Trajectory', Icons.timeline, AppColors.teal),
                  _ReportItem('Vibes', Icons.waves, AppColors.rose),
                  _ReportItem('Intensity', Icons.flash_on, AppColors.sun),
                  _ReportItem('Planner', Icons.calendar_month, Color(0xFF7EC8E3)),
                ],
              ),
            ),

            // FAQs
            if (ic.faqList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: 'FAQs',
                child: Column(
                  children: ic.faqList.map((f) => _FaqTile(f)).toList(),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  static void _launchAction(String scheme, String? number) {
    if (number == null || number.isEmpty) {
      Get.snackbar('Unavailable', 'Contact info not available', snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card, colorText: AppColors.tx);
      return;
    }
    // In a real app: url_launcher
    Get.snackbar('Action', '$scheme: $number', snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.card, colorText: AppColors.tx);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx3))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.tx))),
        ],
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  const _ReportItem(this.name, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final Map<String, dynamic> faq;
  const _FaqTile(this.faq);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(faq['Question'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.tx)),
      iconColor: AppColors.tx3,
      collapsedIconColor: AppColors.tx3,
      children: [
        Text(faq['Answer'] ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2, height: 1.5)),
      ],
    );
  }
}
