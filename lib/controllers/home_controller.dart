import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';

class HomeController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final currentNavIndex = 0.obs;
  final selectedRashi = 0.obs;
  final isLoading = false.obs;
  final generalPrediction = ''.obs;

  final rashiList = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  String get selectedRashiName => rashiList[selectedRashi.value];

  void changeNav(int index) => currentNavIndex.value = index;

  void selectRashi(int index) {
    selectedRashi.value = index;
    fetchGeneralPrediction();
  }

  Future<void> fetchGeneralPrediction() async {
    try {
      isLoading.value = true;
      final result = await _repo.getGeneralPrediction({
        'rashi': selectedRashiName,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
      isLoading.value = false;
      if (result['status'] == true) {
        generalPrediction.value = result['prediction'] ?? '';
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('General prediction error: $e');
    }
  }

  Future<void> logout() async {
    await UserData.clear();
    Get.offAllNamed('/login');
  }
}
