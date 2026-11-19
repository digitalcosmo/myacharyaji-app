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
  final errorMessage = ''.obs;
  final selectedCountryCode = '+91'.obs;
  final isTAndC = true.obs;

  String? registrationRequired;

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        backgroundColor: isError
            ? Colors.red.withValues(alpha: 0.8)
            : Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ───── Send OTP ─────
  Future<void> sendOtp() async {
    if (phoneController.text.length < 7) {
      _showSnackbar('Error', 'Enter a valid phone number');
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {'mobile': '${selectedCountryCode.value}${phoneController.text}'};
      final result = await _repo.sendOtp(data);
      isLoading.value = false;

      if (result['status'] == true) {
        _showSnackbar('Success', result['msg'] ?? 'OTP sent', isError: false);
        Get.toNamed(AppRoutes.otp);
      } else {
        _showSnackbar('Error', result['msg'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint('SendOTP error: $e');
      _showSnackbar('Error', 'Network error. Please check your connection.');
    }
  }

  // ───── Verify OTP ─────
  Future<void> verifyOtp() async {
    if (otpController.text.length < 4) {
      _showSnackbar('Error', 'Enter a valid OTP');
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
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
        _showSnackbar('Success', result['msg'] ?? 'Verified', isError: false);
        Get.offAllNamed(AppRoutes.acharyaCode);
      } else {
        _showSnackbar('Error', result['msg'] ?? 'Invalid OTP');
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint('VerifyOTP error: $e');
      _showSnackbar('Error', 'Network error. Please check your connection.');
    }
  }

  // ───── Validate Acharyaji Code ─────
  Future<void> validateAcharyaCode() async {
    if (acharyaCodeController.text.isEmpty) {
      _showSnackbar('Error', 'Enter Acharyaji code');
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {'app_code': acharyaCodeController.text};
      final result = await _repo.validateAppCode(data);
      isLoading.value = false;

      if (result['status'] == true) {
        await UserData.setLoggedIn(true);
        await UserData.setAppId(result['app_id'].toString());
        Get.offAllNamed(AppRoutes.home);
      } else {
        _showSnackbar('Error', 'Invalid Acharyaji Code');
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint('AppDetails error: $e');
      _showSnackbar('Error', 'Network error. Please check your connection.');
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
