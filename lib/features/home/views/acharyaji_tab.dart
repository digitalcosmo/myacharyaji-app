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
          return const Center(
              child: CircularProgressIndicator(color: AppColors.sun));
        }
        final name = ic.consultantName.value;
        final mobile = ic.consultantMobile.value;
        final email = ic.consultantEmail.value;
        final about = ic.consultantDescription.value;
        final city = ic.consultantAddress.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            // ── Halo avatar ──
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    // Halo ring avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          startAngle: 3.5,
                          colors: [
                            AppColors.sun,
                            AppColors.sun2,
                            AppColors.vio,
                            AppColors.teal,
                            AppColors.sun,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.sun.withValues(alpha: 0.3),
                              blurRadius: 30),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bg2,
                            border: Border.all(
                                color: AppColors.bg, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              _initials(name.isNotEmpty ? name : 'A'),
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tx),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name.isNotEmpty ? 'Acharya $name' : 'Your Acharyaji',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tx),
                    ),
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(city,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.tx3)),
                    ],
                    const SizedBox(height: 8),
                    // Verified badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.teal),
                        const SizedBox(width: 5),
                        Text('Verified CosmoKundli consultant',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Action buttons ──
            Row(
              children: [
                _ActionCircle(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  color: AppColors.teal,
                  onTap: () => _launchAction('tel', mobile),
                ),
                const SizedBox(width: 12),
                _ActionCircle(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  color: const Color(0xFF7EE0A8),
                  onTap: () => _launchAction('whatsapp', mobile),
                ),
                const SizedBox(width: 12),
                _ActionCircle(
                  icon: Icons.calendar_today_outlined,
                  label: 'Book',
                  color: AppColors.sun,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── About card ──
            if (about.isNotEmpty) ...[
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ABOUT',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tx3,
                            letterSpacing: 1.4)),
                    const SizedBox(height: 10),
                    Text(about,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.tx2,
                            height: 1.55)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Details card (key-value rows with dividers) ──
            _Card(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Column(
                children: [
                  if (city.isNotEmpty)
                    _KvRow('Location', city),
                  if (email.isNotEmpty)
                    _KvRow('Email', email),
                  if (mobile.isNotEmpty)
                    _KvRow('Phone', mobile, isLast: email.isEmpty),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Stats row ──
            _Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCol('Reports', '5', 'types'),
                  Container(
                      width: 1,
                      height: 36,
                      color: AppColors.line),
                  _StatCol('Active', '—', 'members'),
                  Container(
                      width: 1,
                      height: 36,
                      color: AppColors.line),
                  _StatCol('Rating', '★', 'verified'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── FAQs ──
            if (ic.faqList.isNotEmpty) ...[
              Text('FREQUENTLY ASKED',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tx3,
                      letterSpacing: 1.4)),
              const SizedBox(height: 12),
              ...ic.faqList.map((f) => _FaqTile(f)),
            ],

            // ── Guidelines link ──
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.toNamed('/guidelines'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.card,
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.tx3, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Report guidelines & how to read them',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tx2)),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.tx3, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static void _launchAction(String scheme, String? number) {
    if (number == null || number.isEmpty) {
      Get.snackbar('Unavailable', 'Contact info not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.tx);
      return;
    }
    Get.snackbar('Action', '$scheme: $number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.tx);
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCircle(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tx2)),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _KvRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _KvRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.tx3)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tx)),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatCol(this.label, this.value, this.sub);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.sun)),
        const SizedBox(height: 2),
        Text(sub,
            style:
                GoogleFonts.inter(fontSize: 11, color: AppColors.tx3)),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final Map<String, dynamic> faq;
  const _FaqTile(this.faq);

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.faq['Question'] ?? widget.faq['question'] ?? '';
    final a = widget.faq['Answer'] ?? widget.faq['answer'] ?? '';

    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(.22, 1, .36, 1),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _open
              ? AppColors.sun.withValues(alpha: 0.06)
              : AppColors.card,
          border: Border.all(
              color: _open
                  ? AppColors.sun.withValues(alpha: 0.2)
                  : AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(q,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tx)),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.expand_more,
                      color: _open ? AppColors.sun : AppColors.tx3,
                      size: 20),
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 10),
              Text(a,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.tx2,
                      height: 1.55)),
            ],
          ],
        ),
      ),
    );
  }
}
