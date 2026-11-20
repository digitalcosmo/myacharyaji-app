import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';

class InfoController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final isLoading = false.obs;

  // Guidelines
  final guidelineContent = ''.obs;

  // FAQs
  final faqList = <Map<String, dynamic>>[].obs;

  // Consultant / About
  final consultantName = ''.obs;
  final consultantAddress = ''.obs;
  final consultantMobile = ''.obs;
  final consultantEmail = ''.obs;
  final consultantDescription = ''.obs;
  final consultantIcon = ''.obs;

  Future<void> loadGuidelines() async {
    try {
      isLoading.value = true;
      final result = await _repo.getGuidelines();
      isLoading.value = false;
      guidelineContent.value = result['content'] ?? '';
    } catch (e) {
      isLoading.value = false;
      debugPrint('Guidelines error: $e');
    }
  }

  Future<void> loadFAQs() async {
    try {
      isLoading.value = true;
      final result = await _repo.getFaqs();
      isLoading.value = false;
      if (result['status'] == true) {
        final list = result['list'] ?? result['List'] ?? result['data'] ?? [];
        if (list is List) {
          faqList.value = List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('FAQ error: $e');
    }
  }

  Future<void> loadConsultantDetails() async {
    try {
      isLoading.value = true;
      final appId = await UserData.getAppId();
      final result = await _repo.getConsultantDetails(appId);
      isLoading.value = false;
      if (result['status'] == true) {
        consultantName.value = result['name'] ?? '';
        consultantAddress.value = result['address'] ?? '';
        consultantMobile.value = result['mobile'] ?? '';
        consultantEmail.value = result['email'] ?? '';
        consultantDescription.value = result['descripton'] ?? '';
        consultantIcon.value = result['icon'] ?? '';
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Consultant error: $e');
    }
  }
}
