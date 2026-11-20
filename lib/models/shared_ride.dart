import 'package:fuodz/models/order.dart';

/// SHARED RIDES — transparent per-passenger fare breakdown.
/// Every field is nullable + null-safe parsed (a missing/null value never throws).
class SharedRideFare {
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double fareGross;
  final double poolingDiscount;
  final double passengerFare;
  final double directDistance;
  final double directMinutes;

  SharedRideFare({
    this.baseFare = 0,
    this.distanceFare = 0,
    this.timeFare = 0,
    this.fareGross = 0,
    this.poolingDiscount = 0,
    this.passengerFare = 0,
    this.directDistance = 0,
    this.directMinutes = 0,
  });

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory SharedRideFare.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return SharedRideFare(
      baseFare: _d(json["base_fare"]),
      distanceFare: _d(json["distance_fare"]),
      timeFare: _d(json["time_fare"]),
      fareGross: _d(json["fare_gross"]),
      poolingDiscount: _d(json["pooling_discount"]),
      passengerFare: _d(json["passenger_fare"]),
      directDistance: _d(json["direct_distance"]),
      directMinutes: _d(json["direct_minutes"]),
    );
  }
}

/// Response of the quote endpoint: whether shared rides are available, whether
/// this request can be pooled, and the transparent per-passenger fare.
class SharedRideQuote {
  final bool enabled;
  final bool poolable;
  final int? sharedTripId;
  final SharedRideFare fare;
  final double poolingDiscountPct;
  final String? message;

  SharedRideQuote({
    this.enabled = false,
    this.poolable = false,
    this.sharedTripId,
    SharedRideFare? fare,
    this.poolingDiscountPct = 0,
    this.message,
  }) : fare = fare ?? SharedRideFare();

  factory SharedRideQuote.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return SharedRideQuote(
      enabled: json["enabled"] == true,
      poolable: json["poolable"] == true,
      sharedTripId: json["shared_trip_id"] is num
          ? (json["shared_trip_id"] as num).toInt()
          : int.tryParse("${json["shared_trip_id"]}"),
      fare: SharedRideFare.fromJson(
          json["fare"] is Map ? Map<String, dynamic>.from(json["fare"]) : null),
      poolingDiscountPct: SharedRideFare._d(json["pooling_discount_pct"]),
      message: json["message"]?.toString(),
    );
  }
}

/// Result of a shared booking: the customer's own order, which pooled trip it
/// joined, their passenger id (used for cancellation), and their fare.
class SharedRideBooking {
  final bool success;
  final bool pooled;
  final Order? order;
  final int? sharedTripId;
  final int? passengerId;
  final SharedRideFare fare;
  final String? message;

  SharedRideBooking({
    this.success = false,
    this.pooled = false,
    this.order,
    this.sharedTripId,
    this.passengerId,
    SharedRideFare? fare,
    this.message,
  }) : fare = fare ?? SharedRideFare();

  factory SharedRideBooking.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    Order? order;
    try {
      if (json["order"] is Map) {
        order = Order.fromJson(Map<String, dynamic>.from(json["order"]));
      }
    } catch (_) {
      order = null;
    }
    return SharedRideBooking(
      success: json["success"] == true,
      pooled: json["pooled"] == true,
      order: order,
      sharedTripId: json["shared_trip_id"] is num
          ? (json["shared_trip_id"] as num).toInt()
          : int.tryParse("${json["shared_trip_id"]}"),
      passengerId: json["passenger_id"] is num
          ? (json["passenger_id"] as num).toInt()
          : int.tryParse("${json["passenger_id"]}"),
      fare: SharedRideFare.fromJson(
          json["fare"] is Map ? Map<String, dynamic>.from(json["fare"]) : null),
      message: json["message"]?.toString(),
    );
  }
}
