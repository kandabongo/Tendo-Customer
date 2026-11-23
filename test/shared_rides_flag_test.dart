import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_taxi_settings.dart';

/// SHARED RIDES (customer) — the feature flag that gates the Private/Shared
/// selector in the booking panel. The summary panel renders the selector only
/// `if (vm.sharedRidesAvailable)`, i.e. AppTaxiSettings.sharedRidesEnabled,
/// which delegates to the pure parser below. These tests lock that parse:
/// OFF unless the backend app-settings explicitly enable it.
void main() {
  group('Shared Rides flag parser gates the customer selector', () {
    test('absent (both null) -> hidden', () {
      expect(AppTaxiSettings.sharedRidesEnabledFrom(null, null), isFalse);
    });

    test('env default empty strings -> hidden', () {
      expect(AppTaxiSettings.sharedRidesEnabledFrom("", ""), isFalse);
    });

    test('nested {enabled:true} -> visible', () {
      expect(
          AppTaxiSettings.sharedRidesEnabledFrom({"enabled": true}, null), isTrue);
    });

    test('nested {enabled:"1"} -> visible', () {
      expect(
          AppTaxiSettings.sharedRidesEnabledFrom({"enabled": "1"}, null), isTrue);
    });

    test('nested {enabled:1} -> visible', () {
      expect(
          AppTaxiSettings.sharedRidesEnabledFrom({"enabled": 1}, null), isTrue);
    });

    test('nested {enabled:false} -> hidden', () {
      expect(AppTaxiSettings.sharedRidesEnabledFrom({"enabled": false}, null),
          isFalse);
    });

    test('flat "1" -> visible', () {
      expect(AppTaxiSettings.sharedRidesEnabledFrom(null, "1"), isTrue);
    });

    test('flat "0" -> hidden', () {
      expect(AppTaxiSettings.sharedRidesEnabledFrom(null, "0"), isFalse);
    });
  });

  group('Customer shared endpoints map to the backend routes', () {
    test('quote / book / passenger paths', () {
      expect(Api.sharedRideQuote, "/taxi/shared/quote");
      expect(Api.sharedRideBook, "/taxi/shared/book");
      expect(Api.sharedRidePassenger, "/taxi/shared/passenger");
    });
  });
}
