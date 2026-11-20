import 'five_d.dart';

enum LoadStatus { loading, ok, locked, error }

/// Outcome of one 5D request. A `status:false` reply from CosmoKundli
/// ("Access to this report requires a subscription…") is [LoadStatus.locked]
/// and never shows numbers — the zeros in that payload are not data.
class FiveDResult {
  final LoadStatus status;
  final FiveD? data;
  final String? message;
  final bool hasNext;
  final bool hasPrevious;

  const FiveDResult._(this.status, this.data, this.message, this.hasNext, this.hasPrevious);

  const FiveDResult.loading() : this._(LoadStatus.loading, null, null, false, false);

  const FiveDResult.ok(FiveD d, {bool next = false, bool previous = false})
      : this._(LoadStatus.ok, d, null, next, previous);

  const FiveDResult.locked(String msg, {bool next = false, bool previous = false})
      : this._(LoadStatus.locked, null, msg, next, previous);

  const FiveDResult.error(String msg) : this._(LoadStatus.error, null, msg, false, false);

  bool get isOk => status == LoadStatus.ok;
  bool get isLoading => status == LoadStatus.loading;

  /// Builds a result from a raw API map.
  factory FiveDResult.fromApi(Map<String, dynamic> r) {
    final next = r['next'] == true;
    final prev = r['previous'] == true;
    final statusFalse = r['status'] == false || '${r['status']}' == 'false';
    if (statusFalse) {
      final msg = '${r['message'] ?? r['msg'] ?? ''}'.trim();
      return FiveDResult.locked(
        msg.isEmpty ? 'This period is not available on your report.' : msg,
        next: next,
        previous: prev,
      );
    }
    if (!FiveD.isPresentIn(r)) {
      return const FiveDResult.error('The server sent an incomplete reading.');
    }
    return FiveDResult.ok(FiveD.fromJson(r), next: next, previous: prev);
  }
}
