import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/models/shared_ride.dart';

/// SHARED RIDES (customer) — model/contract tests. They assert the Flutter models
/// parse the ACTUAL Phase 3 backend response fields, and that missing/null values
/// never throw (the null-parsing bug class that broke the Assist catalogue).
void main() {
  group('SharedRideQuote', () {
    test('parses the backend quote response fields', () {
      // Mirrors SharedRideController@quote JSON.
      final json = {
        "enabled": true,
        "poolable": true,
        "shared_trip_id": 7,
        "pooling_discount_pct": 20,
        "fare": {
          "base_fare": 5,
          "distance_fare": 20,
          "time_fare": 20,
          "fare_gross": 45,
          "pooling_discount": 9,
          "passenger_fare": 36,
          "direct_distance": 10,
          "direct_minutes": 20,
        },
      };
      final q = SharedRideQuote.fromJson(json);
      expect(q.enabled, true);
      expect(q.poolable, true);
      expect(q.sharedTripId, 7);
      expect(q.poolingDiscountPct, 20);
      expect(q.fare.passengerFare, 36);
      expect(q.fare.poolingDiscount, 9);
      expect(q.fare.directDistance, 10);
    });

    test('disabled response parses to enabled=false', () {
      final q = SharedRideQuote.fromJson({"enabled": false, "message": "Shared rides are not available."});
      expect(q.enabled, false);
      expect(q.poolable, false);
      expect(q.message, contains("not available"));
    });

    test('null / empty json never throws', () {
      final q = SharedRideQuote.fromJson(null);
      expect(q.enabled, false);
      expect(q.fare.passengerFare, 0);
      final q2 = SharedRideQuote.fromJson({"fare": null, "shared_trip_id": null});
      expect(q2.sharedTripId, isNull);
      expect(q2.fare.baseFare, 0);
    });

    test('string numbers are coerced', () {
      final q = SharedRideQuote.fromJson({
        "enabled": true,
        "fare": {"passenger_fare": "23.20", "direct_distance": "6"},
      });
      expect(q.fare.passengerFare, 23.2);
      expect(q.fare.directDistance, 6);
    });
  });

  group('SharedRideBooking', () {
    test('parses the backend book response', () {
      // Mirrors SharedRideController@book JSON.
      final json = {
        "success": true,
        "pooled": true,
        "shared_trip_id": 7,
        "passenger_id": 42,
        "fare": {"passenger_fare": 36},
        "order": {"id": 101, "code": "SRABC123"},
      };
      final b = SharedRideBooking.fromJson(json);
      expect(b.success, true);
      expect(b.pooled, true);
      expect(b.sharedTripId, 7);
      expect(b.passengerId, 42);
      expect(b.fare.passengerFare, 36);
    });

    test('a malformed order does not break the booking parse', () {
      final b = SharedRideBooking.fromJson({
        "success": true,
        "passenger_id": 9,
        "order": "not-a-map",
        "fare": {"passenger_fare": 10},
      });
      expect(b.success, true);
      expect(b.passengerId, 9);
      expect(b.order, isNull);
      expect(b.fare.passengerFare, 10);
    });

    test('failed booking keeps success=false with message', () {
      final b = SharedRideBooking.fromJson({"success": false, "message": "Shared booking failed"});
      expect(b.success, false);
      expect(b.message, "Shared booking failed");
    });
  });
}
