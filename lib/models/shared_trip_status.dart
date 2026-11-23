/// SHARED RIDES (customer) — the dispatch outcome for a booked trip, exactly as
/// `GET /taxi/shared/trip/{id}/status` returns it. The backend is authoritative;
/// the app only renders these states. Outcomes:
///   searching  — still matching a driver
///   assigned   — a driver accepted (driver_id present)
///   no_driver  — no driver was available (trip cancelled, no charge)
///   cancelled  — cancelled for another reason
class SharedTripStatus {
  final String outcome;
  final String? tripStatus;
  final int? driverId;

  SharedTripStatus({required this.outcome, this.tripStatus, this.driverId});

  factory SharedTripStatus.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    int? driverId;
    if (j["driver_id"] != null) {
      driverId = j["driver_id"] is num
          ? (j["driver_id"] as num).toInt()
          : int.tryParse("${j["driver_id"]}");
    }
    return SharedTripStatus(
      outcome: "${j["outcome"] ?? "searching"}",
      tripStatus: j["trip_status"]?.toString(),
      driverId: driverId,
    );
  }

  bool get isSearching => outcome == "searching";
  bool get isAssigned => outcome == "assigned";
  bool get isNoDriver => outcome == "no_driver";
  bool get isTerminal => isAssigned || isNoDriver || outcome == "cancelled";
}
