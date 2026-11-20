import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import '../core/utils/dates.dart';
import '../models/load_result.dart';

class Rashi {
  /// Exact value GenralPredction expects (from the original app).
  final String apiName;

  /// Name shown in the app.
  final String name;
  final String english;
  final String symbol;
  const Rashi(this.apiName, this.name, this.english, this.symbol);
}

const List<Rashi> kRashis = [
  Rashi('Mesh', 'Mesha', 'Aries', '♈'),
  Rashi('Vrishbha', 'Vrishabha', 'Taurus', '♉'),
  Rashi('Mithun', 'Mithuna', 'Gemini', '♊'),
  Rashi('Kark', 'Karka', 'Cancer', '♋'),
  Rashi('Simha', 'Simha', 'Leo', '♌'),
  Rashi('Kanya', 'Kanya', 'Virgo', '♍'),
  Rashi('Tula', 'Tula', 'Libra', '♎'),
  Rashi('Vrishchik', 'Vrishchika', 'Scorpio', '♏'),
  Rashi('Dhanu', 'Dhanu', 'Sagittarius', '♐'),
  Rashi('Makar', 'Makara', 'Capricorn', '♑'),
  Rashi('Kumbh', 'Kumbha', 'Aquarius', '♒'),
  Rashi('Meen', 'Meena', 'Pisces', '♓'),
];

/// General (rashi) 5D prediction for yesterday, today and tomorrow.
class RashiController extends GetxController {
  final ApiRepository _repo = ApiRepository();
  static const _prefKey = 'selectedRashi';

  final selected = 0.obs;

  /// -1 yesterday, 0 today, 1 tomorrow.
  final offset = 0.obs;

  final results = <String, FiveDResult>{}.obs;
  final _inflight = <String>{};

  Rashi get rashi => kRashis[selected.value];
  DateTime get date => addDays(today(), offset.value);

  String _key(int rashiIdx, DateTime d) => '${kRashis[rashiIdx].apiName}|${apiDate(d)}';

  FiveDResult? get current => results[_key(selected.value, date)];

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final i = p.getInt(_prefKey) ?? 0;
    selected.value = i.clamp(0, kRashis.length - 1);
    _loadAllDays();
  }

  Future<void> selectRashi(int i) async {
    if (i == selected.value) return;
    selected.value = i;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefKey, i);
    _loadAllDays();
  }

  void setOffset(int o) {
    offset.value = o;
    _load(selected.value, date);
  }

  /// Fetch the visible day first, then its neighbours so switching is instant.
  void _loadAllDays() {
    final idx = selected.value;
    _load(idx, date).then((_) {
      for (final o in const [-1, 0, 1]) {
        _load(idx, addDays(today(), o));
      }
    });
  }

  void retry() => _load(selected.value, date, force: true);

  Future<void> _load(int idx, DateTime d, {bool force = false}) async {
    final key = _key(idx, d);
    final existing = results[key];
    if (!force && existing != null && existing.status != LoadStatus.error) return;
    if (_inflight.contains(key)) return;
    _inflight.add(key);
    results[key] = const FiveDResult.loading();
    try {
      final r = await _repo.getGeneralPrediction({
        'rashi': kRashis[idx].apiName,
        'date': apiDate(d),
      });
      results[key] = FiveDResult.fromApi(r);
    } catch (e) {
      results[key] = FiveDResult.error(friendlyError(e));
    } finally {
      _inflight.remove(key);
    }
  }
}
