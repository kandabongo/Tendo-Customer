/// SHARED RIDES (customer) — the dispatch outcome AND live-tracking payload for a
/// booked trip, exactly as `GET /taxi/shared/trip/{id}/status` returns it.
/// The backend is authoritative; the app only renders these states.
///
/// Outcomes:
///   searching  — still matching a driver
///   assigned   — a driver accepted (driver_id present)
///   no_driver  — no driver was available (trip cancelled, no charge)
///   cancelled  — cancelled for another reason
///
/// Change A additions (all nullable, null-safe): `driver`, `me`, `trip`.
/// Older backends simply omit them, so every field degrades gracefully.
class SharedTripStatus {
  final String outcome;
  final String? tripStatus;
  final int? driverId;
  final SharedTripDriver? driver;
  final SharedTripMe? me;
  final SharedTripProgress? trip;

  SharedTripStatus({
    required this.outcome,
    this.tripStatus,
    this.driverId,
    this.driver,
    this.me,
    this.trip,
  });

  static double? _dn(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _in(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse("$v");
  }

  factory SharedTripStatus.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return SharedTripStatus(
      outcome: "${j["outcome"] ?? "searching"}",
      tripStatus: j["trip_status"]?.toString(),
      driverId: _in(j["driver_id"]),
      driver: j["driver"] is Map
          ? SharedTripDriver.fromJson(Map<String, dynamic>.from(j["driver"]))
          : null,
      me: j["me"] is Map
          ? SharedTripMe.fromJson(Map<String, dynamic>.from(j["me"]))
          : null,
      trip: j["trip"] is Map
          ? SharedTripProgress.fromJson(Map<String, dynamic>.from(j["trip"]))
          : null,
    );
  }

  bool get isSearching => outcome == "searching";
  bool get isAssigned => outcome == "assigned";
  bool get isNoDriver => outcome == "no_driver";
  bool get isCancelled => outcome == "cancelled";
  bool get isTerminal => isAssigned || isNoDriver || outcome == "cancelled";

  /// The customer's leg status, when the backend supplies it. One of:
  /// offered / accepted / en_route / onboard / dropped / cancelled / rejected.
  String? get myLegStatus => me?.status;

  bool get iAmOnboard => me?.status == "onboard";
  bool get iAmDropped => me?.status == "dropped";
  bool get driverEnRouteToMe => me?.status == "en_route";
}

/// Assigned driver + their vehicle. Null until a driver is assigned.
class SharedTripDriver {
  final int? id;
  final String? name;
  final String? photo;
  final String? phone;
  final String? rating;
  final SharedTripVehicle? vehicle;

  SharedTripDriver({this.id, this.name, this.photo, this.phone, this.rating, this.vehicle});

  factory SharedTripDriver.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return SharedTripDriver(
      id: SharedTripStatus._in(j["id"]),
      name: j["name"]?.toString(),
      photo: j["photo"]?.toString(),
      phone: j["phone"]?.toString(),
      rating: j["rating"]?.toString(),
      vehicle: j["vehicle"] is Map
          ? SharedTripVehicle.fromJson(Map<String, dynamic>.from(j["vehicle"]))
          : null,
    );
  }

  String get displayRating {
    final r = double.tryParse(rating ?? "");
    return r == null ? "" : r.toStringAsFixed(1);
  }
}

class SharedTripVehicle {
  final String? name;
  final String? regNumber;
  final String? colour;
  final String? vehicleType;

  SharedTripVehicle({this.name, this.regNumber, this.colour, this.vehicleType});

  factory SharedTripVehicle.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return SharedTripVehicle(
      name: j["name"]?.toString(),
      regNumber: j["reg_number"]?.toString(),
      colour: j["colour"]?.toString(),
      vehicleType: j["vehicle_type"]?.toString(),
    );
  }

  /// "Silver Toyota Corolla · RCZ1234" — only the parts we actually have.
  String get summary {
    final parts = <String>[];
    if ((colour ?? "").isNotEmpty) parts.add(colour!);
    if ((name ?? "").isNotEmpty) parts.add(name!);
    final left = parts.join(" ");
    if ((regNumber ?? "").isNotEmpty) {
      return left.isEmpty ? regNumber! : "$left · $regNumber";
    }
    return left;
  }
}

/// The authenticated customer's OWN leg. Coordinates drive the map markers;
/// status drives the approach/pickup/arrival messaging.
class SharedTripMe {
  final int? passengerId;
  final String? status;
  final int? seatCount;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;

  SharedTripMe({
    this.passengerId,
    this.status,
    this.seatCount,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
  });

  factory SharedTripMe.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return SharedTripMe(
      passengerId: SharedTripStatus._in(j["passenger_id"]),
      status: j["status"]?.toString(),
      seatCount: SharedTripStatus._in(j["seat_count"]),
      pickupLatitude: SharedTripStatus._dn(j["pickup_latitude"]),
      pickupLongitude: SharedTripStatus._dn(j["pickup_longitude"]),
      dropoffLatitude: SharedTripStatus._dn(j["dropoff_latitude"]),
      dropoffLongitude: SharedTripStatus._dn(j["dropoff_longitude"]),
    );
  }

  bool get hasPickup => pickupLatitude != null && pickupLongitude != null;
  bool get hasDropoff => dropoffLatitude != null && dropoffLongitude != null;
}

/// Aggregate trip progress — counts only, never other passengers' details.
class SharedTripProgress {
  final int? id;
  final String? status;
  final int? maxSeats;
  final int? seatsTaken;
  final int? passengersTotal;
  final int? passengersOnboard;
  final int? passengersDropped;

  SharedTripProgress({
    this.id,
    this.status,
    this.maxSeats,
    this.seatsTaken,
    this.passengersTotal,
    this.passengersOnboard,
    this.passengersDropped,
  });

  factory SharedTripProgress.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return SharedTripProgress(
      id: SharedTripStatus._in(j["id"]),
      status: j["status"]?.toString(),
      maxSeats: SharedTripStatus._in(j["max_seats"]),
      seatsTaken: SharedTripStatus._in(j["seats_taken"]),
      passengersTotal: SharedTripStatus._in(j["passengers_total"]),
      passengersOnboard: SharedTripStatus._in(j["passengers_onboard"]),
      passengersDropped: SharedTripStatus._in(j["passengers_dropped"]),
    );
  }
}
