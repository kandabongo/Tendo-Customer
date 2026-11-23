import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_taxi_settings.dart';

/// SHARED RIDES (customer) — the feature flag that gates the Private/Shared
/// selector in the booking panel. The summary panel renders the selector only
/// `if (vm.sharedRidesAvailable)`, which is exactly AppTaxiSettings.sharedRidesEnabled.
/// These tests lock that gating logic: OFF by default (hidden), ON only when the
/// backend app-settings say so (visible).
void main() {
  group('Shared Rides flag gates the customer selector', () {
    tearDown(() => AppStrings.appSettingsObject = null);

    test('disabled when no app settings -> selector hidden', () {
      AppStrings.appSettingsObject = null;
      expect(AppTaxiSettings.sharedRidesEnabled, isFalse);
    });

    test('disabled when sharedRides key absent', () {
      AppStrings.appSettingsObject = {"app_name": "Tendo"};
      expect(AppTaxiSettings.sharedRidesEnabled, isFalse);
    });

    test('enabled via nested boolean -> selector visible', () {
      AppStrings.appSettingsObject = {
        "sharedRides": {"enabled": true}
      };
      expect(AppTaxiSettings.sharedRidesEnabled, isTrue);
    });

    test('enabled via nested "1"', () {
      AppStrings.appSettingsObject = {
        "sharedRides": {"enabled": "1"}
      };
      expect(AppTaxiSettings.sharedRidesEnabled, isTrue);
    });

    test('explicitly disabled via nested false', () {
      AppStrings.appSettingsObject = {
        "sharedRides": {"enabled": false}
      };
      expect(AppTaxiSettings.sharedRidesEnabled, isFalse);
    });

    test('enabled via flat key', () {
      AppStrings.appSettingsObject = {"sharedRides.enabled": "1"};
      expect(AppTaxiSettings.sharedRidesEnabled, isTrue);
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
