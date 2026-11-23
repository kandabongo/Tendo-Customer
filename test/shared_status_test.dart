import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/shared_trip_status.dart';

/// SHARED RIDES (customer) — dispatch-outcome parsing. Pure and deterministic:
/// it exercises how the app interprets the backend's real
/// `/taxi/shared/trip/{id}/status` payload, not a mocked success.
void main() {
  group('SharedTripStatus maps the three outcomes', () {
    test('searching', () {
      final s = SharedTripStatus.fromJson({'outcome': 'searching', 'trip_status': 'matching'});
      expect(s.isSearching, isTrue);
      expect(s.isAssigned, isFalse);
      expect(s.isTerminal, isFalse);
      expect(s.driverId, isNull);
    });

    test('assigned carries the driver id and is terminal', () {
      final s = SharedTripStatus.fromJson({'outcome': 'assigned', 'trip_status': 'active', 'driver_id': 42});
      expect(s.isAssigned, isTrue);
      expect(s.driverId, 42);
      expect(s.isTerminal, isTrue);
    });

    test('no_driver is terminal', () {
      final s = SharedTripStatus.fromJson({'outcome': 'no_driver', 'trip_status': 'cancelled'});
      expect(s.isNoDriver, isTrue);
      expect(s.isTerminal, isTrue);
    });

    test('defaults to searching on an empty/garbled body', () {
      final s = SharedTripStatus.fromJson(null);
      expect(s.isSearching, isTrue);
    });

    test('tolerates a string driver_id', () {
      final s = SharedTripStatus.fromJson({'outcome': 'assigned', 'driver_id': '7'});
      expect(s.driverId, 7);
    });
  });

  test('status endpoint base matches the backend route', () {
    expect(Api.sharedRideTrip, '/taxi/shared/trip');
  });
}
