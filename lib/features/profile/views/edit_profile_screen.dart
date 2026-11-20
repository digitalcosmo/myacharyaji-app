import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/controls.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/sub_page.dart';
import '../../../ui/tokens.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return SubPage(
      title: 'Edit profile',
      children: [
        _Field(label: 'First name', controller: c.fNameController),
        _Field(label: 'Surname', controller: c.surNameController),
        _Field(
          label: 'Date of birth',
          controller: c.dobController,
          readOnly: true,
          trailing: Ic.calendar,
          onTap: () => c.selectDate(context),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GENDER', style: T.cap),
            const SizedBox(height: 10),
            Obx(() => Segmented(
                  labels: const ['Male', 'Female', 'Other'],
                  index: const ['male', 'female', 'other'].indexOf(c.currentGender.value).clamp(0, 2),
                  onChanged: (i) => c.currentGender.value = const ['male', 'female', 'other'][i],
                )),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => c.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: AppColors.sun))
            : PrimaryButton(label: 'Save changes', onTap: c.updateProfile)),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? trailing;
  final VoidCallback? onTap;

  const _Field({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: T.cap),
        const SizedBox(height: 10),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: T.body,
                  cursorColor: AppColors.sun,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    filled: false,
                  ),
                ),
              ),
              if (trailing != null) StrokeIcon(trailing!, color: AppColors.sun, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
