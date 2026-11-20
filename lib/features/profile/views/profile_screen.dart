import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/controls.dart';
import '../../../ui/glass.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/sub_page.dart';
import '../../../ui/tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _dob(String raw) {
    final d = DateTime.tryParse(raw);
    return d == null ? raw : DateFormat('d MMMM yyyy').format(d);
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return Obx(() {
      final loading = c.isLoading.value && c.displayName.isEmpty;
      final name = c.displayName;
      return SubPage(
        title: 'Your profile',
        onRefresh: c.loadProfile,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.vio, AppColors.teal]),
                  ),
                  alignment: Alignment.center,
                  child: name.isEmpty
                      ? const StrokeIcon(Ic.user, color: Colors.white, size: 34)
                      : Text(name[0].toUpperCase(), style: T.h1.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 14),
                if (loading)
                  const Skeleton(height: 20, width: 160)
                else
                  Text(name.isEmpty ? 'Add your name' : name, style: T.h2),
                const SizedBox(height: 4),
                Text(c.mobile.value, style: T.small),
              ],
            ),
          ),
          Glass(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Column(
              children: [
                _Row('Date of birth', c.dob.value.isEmpty ? '—' : _dob(c.dob.value)),
                _Row('Gender', c.gender.value.isEmpty ? '—' : _cap(c.gender.value)),
                _Row('Mobile', c.mobile.value.isEmpty ? '—' : c.mobile.value, last: true),
              ],
            ),
          ),
          SecondaryButton(
            label: 'Edit profile',
            icon: Ic.edit,
            expand: true,
            onTap: () => Get.toNamed(AppRoutes.editProfile),
          ),
        ],
      );
    });
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool last;
  const _Row(this.label, this.value, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(
        children: [
          Text(label, style: T.muted),
          const Spacer(),
          Text(value, style: T.label.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
