import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/info_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/load_result.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/controls.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';

/// The consultant who set up the client's reports, plus the client's own
/// account (profile, help, sign out).
class AcharyajiTab extends StatelessWidget {
  const AcharyajiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();
    return TabPage(
      onRefresh: ic.loadConsultantDetails,
      children: const [
        _ConsultantHero(),
        _ContactActions(),
        _AboutCard(),
        _ContactCard(),
        _YouCard(),
        _LinksCard(),
        _SignOut(),
      ],
    );
  }
}

class _ConsultantHero extends StatelessWidget {
  const _ConsultantHero();

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();
    return Obx(() {
      final st = ic.consultantStatus.value;
      if (st == LoadStatus.error) {
        return Glass(child: InlineNotice.error(ic.consultantError.value, ic.loadConsultantDetails));
      }
      final loading = st == LoadStatus.loading;
      final icon = ic.consultantIcon.value;
      return Column(
        children: [
          const SizedBox(height: 8),
          _Halo(
            child: loading
                ? const Skeleton(height: 92, width: 92, radius: 46)
                : ClipOval(
                    child: icon.startsWith('http')
                        ? Image.network(icon,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _Initials(ic.consultantInitials))
                        : _Initials(ic.consultantInitials),
                  ),
          ),
          const SizedBox(height: 18),
          if (loading) ...[
            const Skeleton(height: 22, width: 180),
            const SizedBox(height: 10),
            const Skeleton(height: 12, width: 120),
          ] else ...[
            Text(ic.consultantName.value.isEmpty ? 'Your Acharyaji' : ic.consultantName.value,
                style: T.h2, textAlign: TextAlign.center),
            if (ic.consultantAddress.value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(ic.consultantAddress.value, style: T.small, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const StrokeIcon(Ic.check, color: AppColors.teal, size: 14, strokeWidth: 2.4),
                const SizedBox(width: 6),
                Text('CosmoKundli consultant',
                    style: T.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _Halo extends StatefulWidget {
  final Widget child;
  const _Halo({required this.child});
  @override
  State<_Halo> createState() => _HaloState();
}

class _HaloState extends State<_Halo> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _c,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [
                  AppColors.sun.withValues(alpha: 0.0),
                  AppColors.sun.withValues(alpha: 0.7),
                  AppColors.vio.withValues(alpha: 0.5),
                  AppColors.sun.withValues(alpha: 0.0),
                ]),
              ),
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bg),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String text;
  const _Initials(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sun2, AppColors.sun],
        ),
      ),
      alignment: Alignment.center,
      child: Text(text, style: T.h2.copyWith(fontSize: 30, color: const Color(0xFF1A1205))),
    );
  }
}

Future<void> _open(Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    Get.snackbar('Couldn\'t open', 'No app on this phone can handle that.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.bg2,
        colorText: AppColors.tx,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 110));
  }
}

String _digits(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

/// WhatsApp needs country code without "+"; assume India for 10-digit numbers.
String _waNumber(String s) {
  var d = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length == 10) d = '91$d';
  return d;
}

class _ContactActions extends StatelessWidget {
  const _ContactActions();

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();
    return Obx(() {
      if (ic.consultantStatus.value != LoadStatus.ok) return const SizedBox.shrink();
      final m = ic.consultantMobile.value;
      final e = ic.consultantEmail.value;
      final actions = <Widget>[
        if (m.isNotEmpty)
          _Action(icon: Ic.phone, label: 'Call', color: AppColors.teal, onTap: () => _open(Uri(scheme: 'tel', path: _digits(m)))),
        if (m.isNotEmpty)
          _Action(
              icon: Ic.whatsapp,
              label: 'WhatsApp',
              color: const Color(0xFF7EE0A8),
              onTap: () => _open(Uri.parse('https://wa.me/${_waNumber(m)}'))),
        if (e.isNotEmpty)
          _Action(icon: Ic.mail, label: 'Email', color: AppColors.sun, onTap: () => _open(Uri(scheme: 'mailto', path: e))),
      ];
      if (actions.isEmpty) return const SizedBox.shrink();
      return Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: actions[i]),
          ],
        ],
      );
    });
  }
}

class _Action extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Glass(
        padding: const EdgeInsets.symmetric(vertical: 16),
        radius: 20,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
              alignment: Alignment.center,
              child: StrokeIcon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 8),
            Text(label, style: T.small.copyWith(color: AppColors.tx, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();
    return Obx(() {
      final d = ic.consultantDescription.value;
      if (ic.consultantStatus.value != LoadStatus.ok || d.isEmpty) return const SizedBox.shrink();
      return Glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader('About'),
            const SizedBox(height: 10),
            Text(d, style: T.muted),
          ],
        ),
      );
    });
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InfoController>();
    return Obx(() {
      if (ic.consultantStatus.value != LoadStatus.ok) return const SizedBox.shrink();
      final rows = <(String, String, String)>[
        if (ic.consultantMobile.value.isNotEmpty) (Ic.phone, 'Mobile', ic.consultantMobile.value),
        if (ic.consultantEmail.value.isNotEmpty) (Ic.mail, 'Email', ic.consultantEmail.value),
        if (ic.consultantAddress.value.isNotEmpty) (Ic.pin, 'Office', ic.consultantAddress.value),
      ];
      if (rows.isEmpty) return const SizedBox.shrink();
      return Glass(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              _KvRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3, last: i == rows.length - 1),
          ],
        ),
      );
    });
  }
}

class _KvRow extends StatelessWidget {
  final String icon, label, value;
  final bool last;
  final VoidCallback? onTap;
  final bool chevron;
  const _KvRow({
    required this.icon,
    required this.label,
    this.value = '',
    this.last = false,
    this.onTap,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            StrokeIcon(icon, color: AppColors.tx3, size: 17),
            const SizedBox(width: 12),
            Text(label, style: T.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: T.label.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            if (chevron) ...[
              const SizedBox(width: 6),
              const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _YouCard extends StatelessWidget {
  const _YouCard();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<ProfileController>();
    return Obx(() {
      final name = p.displayName;
      return Pressable(
        onTap: () => Get.toNamed(AppRoutes.profile),
        child: Glass(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.vio, AppColors.teal]),
                ),
                alignment: Alignment.center,
                child: name.isEmpty
                    ? const StrokeIcon(Ic.user, color: Colors.white, size: 20)
                    : Text(name[0].toUpperCase(), style: T.h3.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOU', style: T.cap),
                    const SizedBox(height: 4),
                    Text(name.isEmpty ? 'Your profile' : name, style: T.strong),
                    if (p.mobile.value.isNotEmpty) Text(p.mobile.value, style: T.small),
                  ],
                ),
              ),
              const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 18),
            ],
          ),
        ),
      );
    });
  }
}

class _LinksCard extends StatelessWidget {
  const _LinksCard();

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          _KvRow(
              icon: Ic.book,
              label: 'How to read your planner',
              chevron: true,
              onTap: () => Get.toNamed(AppRoutes.guidelines)),
          _KvRow(icon: Ic.help, label: 'FAQ', chevron: true, onTap: () => Get.toNamed(AppRoutes.faq)),
          _KvRow(
              icon: Ic.shield,
              label: 'Terms & conditions',
              chevron: true,
              last: true,
              onTap: () => _open(Uri.parse(ApiConstants.termsUrl))),
        ],
      ),
    );
  }
}

class _SignOut extends StatelessWidget {
  const _SignOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pressable(
        onTap: () => _confirm(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StrokeIcon(Ic.logout, color: AppColors.rose, size: 17),
              const SizedBox(width: 8),
              Text('Sign out', style: T.strong.copyWith(color: AppColors.rose, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showGlassSheet(context, builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sign out?', style: T.h2),
          const SizedBox(height: 8),
          Text('You\'ll need your mobile number and OTP to sign back in.', style: T.muted),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Sign out',
            onTap: () {
              Navigator.of(ctx).pop();
              Get.find<HomeController>().logout();
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: T.strong.copyWith(color: AppColors.tx2)),
            ),
          ),
        ],
      );
    });
  }
}
