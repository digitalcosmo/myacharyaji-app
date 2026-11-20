import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';
import '../models/load_result.dart';

/// Consultant (Acharyaji) details, guidelines and FAQ.
class InfoController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  // Consultant
  final consultantStatus = LoadStatus.loading.obs;
  final consultantError = ''.obs;
  final consultantName = ''.obs;
  final consultantAddress = ''.obs;
  final consultantMobile = ''.obs;
  final consultantEmail = ''.obs;
  final consultantDescription = ''.obs;
  final consultantIcon = ''.obs;

  // Guidelines
  final guidelineStatus = LoadStatus.loading.obs;
  final guidelineContent = ''.obs;

  // FAQ
  final faqStatus = LoadStatus.loading.obs;
  final faqList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadConsultantDetails();
  }

  String _s(dynamic v) => v == null ? '' : '$v'.trim();

  Future<void> loadConsultantDetails() async {
    consultantStatus.value = LoadStatus.loading;
    try {
      final appId = await UserData.getAppId();
      final r = await _repo.getConsultantDetails(appId);
      if (r['status'] == false) {
        consultantError.value = _s(r['message'] ?? r['msg']).isEmpty
            ? 'Your Acharyaji\'s details are not available right now.'
            : _s(r['message'] ?? r['msg']);
        consultantStatus.value = LoadStatus.error;
        return;
      }
      consultantName.value = _s(r['name']);
      consultantAddress.value = _s(r['address']);
      consultantMobile.value = _s(r['mobile']);
      consultantEmail.value = _s(r['email']);
      // The API key is spelled "descripton".
      consultantDescription.value = _s(r['descripton'] ?? r['description']);
      consultantIcon.value = _s(r['icon']);
      consultantStatus.value = LoadStatus.ok;
    } catch (e) {
      consultantError.value = friendlyError(e);
      consultantStatus.value = LoadStatus.error;
    }
  }

  Future<void> loadGuidelines() async {
    guidelineStatus.value = LoadStatus.loading;
    try {
      final r = await _repo.getGuidelines();
      guidelineContent.value = _s(r['content'] ?? r['data'] ?? r['guideline']);
      guidelineStatus.value = LoadStatus.ok;
    } catch (e) {
      guidelineStatus.value = LoadStatus.error;
    }
  }

  Future<void> loadFAQs() async {
    faqStatus.value = LoadStatus.loading;
    try {
      final r = await _repo.getFaqs();
      final list = r['list'] ?? r['List'] ?? r['data'] ?? [];
      if (list is List) {
        faqList.assignAll(list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
      faqStatus.value = LoadStatus.ok;
    } catch (e) {
      faqStatus.value = LoadStatus.error;
    }
  }

  String get consultantInitials {
    final p = consultantName.value
        .replaceAll(RegExp(r'^(Pt\.?|Pandit|Acharya|Dr\.?)\s+', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (p.isEmpty) return 'A';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
