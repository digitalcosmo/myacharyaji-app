import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: c.fNameController, decoration: const InputDecoration(labelText: 'First Name')),
            const SizedBox(height: 16),
            TextField(controller: c.surNameController, decoration: const InputDecoration(labelText: 'Surname')),
            const SizedBox(height: 16),
            TextField(
              controller: c.dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth', suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: () => c.selectDate(context),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
              value: c.currentGender.value,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) { if (v != null) c.currentGender.value = v; },
            )),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.isLoading.value ? null : () => c.updateProfile(),
                child: c.isLoading.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
