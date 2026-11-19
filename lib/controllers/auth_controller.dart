import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final acharyaCodeController = TextEditingController();

  final isLoading = false.obs;
  final selectedCountryCode = '+91'.obs;
  final isTAndC = true.obs;

  String? registrationRequired;

  // ───── Send OTP ─────
  Future<void> sendOtp() async {
    if (phoneController.text.length < 7) {
      Get.snackbar('Error', 'Enter a valid phone number',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      final data = {'mobile': '${selectedCountryCode.value}${phoneController.text}'};
      final result = await _repo.sendOtp(data);
      isLoading.value = false;

      if (result['status'] == true) {
        Get.snackbar('Success', result['msg'] ?? 'OTP sent',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        Get.toNamed(AppRoutes.otp);
      } else {
        Get.snackbar('Error', result['msg'] ?? 'Failed to send OTP',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  // ───── Verify OTP ─────
  Future<void> verifyOtp() async {
    if (otpController.text.length < 4) {
      Get.snackbar('Error', 'Enter a valid OTP',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      final data = {
        'mobile': '${selectedCountryCode.value}${phoneController.text}',
        'otp': otpController.text,
        'deviceid': 'flutter_device',
        'macid': 'flutter_mac',
      };
      final result = await _repo.verifyOtp(data);
      isLoading.value = false;

      if (result['status'] == true) {
        await UserData.setUserId(result['uID'].toString());
        registrationRequired = result['regstration_required'];
        Get.snackbar('Success', result['msg'] ?? 'Verified',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        Get.offAllNamed(AppRoutes.acharyaCode);
      } else {
        Get.snackbar('Error', result['msg'] ?? 'Invalid OTP',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  // ───── Validate Acharyaji Code ─────
  Future<void> validateAcharyaCode() async {
    if (acharyaCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Enter Acharyaji code',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      final data = {'app_code': acharyaCodeController.text};
      final result = await _repo.validateAppCode(data);
      isLoading.value = false;

      if (result['status'] == true) {
        await UserData.setLoggedIn(true);
        await UserData.setAppId(result['app_id'].toString());
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar('Error', 'Invalid Acharyaji Code',
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  // ───── Logout ─────
  Future<void> logout() async {
    await UserData.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    acharyaCodeController.dispose();
    super.onClose();
  }
}
