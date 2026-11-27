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

  group('SharedTripStatus parses the Change A enrichment', () {
    // Mirrors the enriched SharedRideController@customerTripStatus JSON.
    final enriched = {
      'success': true,
      'outcome': 'assigned',
      'trip_status': 'active',
      'driver_id': 42,
      'driver': {
        'id': 42,
        'name': 'Jane Driver',
        'photo': 'https://cdn/x.png',
        'phone': '+260977000000',
        'rating': '4.6',
        'vehicle': {
          'name': 'Toyota Corolla',
          'reg_number': 'RCZ1234',
          'colour': 'Silver',
          'vehicle_type': 'Sedan',
        },
      },
      'me': {
        'passenger_id': 9,
        'order_id': 4321,
        'status': 'en_route',
        'seat_count': 1,
        'passenger_fare': 42.5,
        'pickup_latitude': -15.38,
        'pickup_longitude': 28.32,
        'dropoff_latitude': -15.41,
        'dropoff_longitude': 28.28,
      },
      'trip': {
        'id': 5,
        'status': 'active',
        'max_seats': 4,
        'seats_taken': 3,
        'passengers_total': 3,
        'passengers_onboard': 1,
        'passengers_dropped': 0,
      },
    };

    test('driver + vehicle details', () {
      final s = SharedTripStatus.fromJson(enriched);
      expect(s.driver, isNotNull);
      expect(s.driver!.id, 42);
      expect(s.driver!.name, 'Jane Driver');
      expect(s.driver!.phone, '+260977000000');
      expect(s.driver!.displayRating, '4.6');
      expect(s.driver!.vehicle!.regNumber, 'RCZ1234');
      expect(s.driver!.vehicle!.summary, contains('RCZ1234'));
      expect(s.driver!.vehicle!.summary, contains('Silver'));
    });

    test("customer's own leg status and coordinates", () {
      final s = SharedTripStatus.fromJson(enriched);
      expect(s.me, isNotNull);
      expect(s.me!.passengerId, 9);
      expect(s.me!.orderId, 4321);
      expect(s.me!.passengerFare, closeTo(42.5, 1e-9));
      expect(s.myLegStatus, 'en_route');
      expect(s.driverEnRouteToMe, isTrue);
      expect(s.me!.hasPickup, isTrue);
      expect(s.me!.hasDropoff, isTrue);
      expect(s.me!.pickupLatitude, closeTo(-15.38, 1e-9));
    });

    test('aggregate progress counts', () {
      final s = SharedTripStatus.fromJson(enriched);
      expect(s.trip, isNotNull);
      expect(s.trip!.maxSeats, 4);
      expect(s.trip!.passengersTotal, 3);
      expect(s.trip!.passengersOnboard, 1);
    });

    test('backward compatible: an old body without the new keys never throws', () {
      final s = SharedTripStatus.fromJson(
          {'outcome': 'assigned', 'trip_status': 'active', 'driver_id': 7});
      expect(s.isAssigned, isTrue);
      expect(s.driver, isNull);
      expect(s.me, isNull);
      expect(s.trip, isNull);
      expect(s.myLegStatus, isNull);
    });
  });
}
