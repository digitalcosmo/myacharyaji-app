import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';

class ProfileController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final isLoading = false.obs;
  final firstName = ''.obs;
  final surname = ''.obs;
  final mobile = ''.obs;
  final gender = ''.obs;
  final dob = ''.obs;
  final profileImage = ''.obs;

  final fNameController = TextEditingController();
  final surNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final currentGender = 'male'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final userId = await UserData.getUserId();
      final result = await _repo.getProfile(userId);
      isLoading.value = false;

      if (result['status'] == true) {
        firstName.value = result['first_name'] ?? '';
        surname.value = result['surname'] ?? '';
        mobile.value = result['mobile'] ?? '';
        gender.value = result['Gender'] ?? '';
        dob.value = result['dob'] ?? '';
        profileImage.value = result['image'] ?? '';

        // Fill edit form
        fNameController.text = firstName.value;
        surNameController.text = surname.value;
        phoneController.text = mobile.value.replaceFirst('+91', '');
        dobController.text = dob.value;
        currentGender.value = gender.value.isNotEmpty ? gender.value : 'male';
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Profile load error: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final userId = await UserData.getUserId();
      final data = {
        'uID': userId,
        'first_name': fNameController.text,
        'surname': surNameController.text,
        'Gender': currentGender.value,
        'dob': dobController.text,
      };
      final result = await _repo.updateProfile(data);
      isLoading.value = false;

      if (result['status'] == true) {
        Get.snackbar('Success', result['msg'] ?? 'Profile updated',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        await loadProfile();
        Get.back();
      } else {
        Get.snackbar('Error', result['msg'] ?? 'Update failed',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1992, 3, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  String get displayName => '${firstName.value} ${surname.value}'.trim();

  @override
  void onClose() {
    fNameController.dispose();
    surNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
