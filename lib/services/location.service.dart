import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/widgets/bottomsheets/location_permission.bottomsheet.dart';
import 'package:geolocator/geolocator.dart'
    show Geolocator, LocationPermission, Position;
// import 'package:geocoder/geocoder.dart';
import 'package:rxdart/rxdart.dart';
import 'geocoder.service.dart';

class LocationService {
  //
  static bool? serviceEnabled;
  static LocationPermission? _permissionGranted;
  static double? _lastLat;
  static double? _lastLng;
  static Address? currenctAddress;
  static DeliveryAddress? deliveryaddress;
  static bool _isFetchingLocation = false;
  static bool _isGeocoding = false;
  static double? _lastAcceptedLat;
  static double? _lastAcceptedLng;
  static DateTime? _lastAcceptedLocationAt;

  //fastest speed a human-carried device could plausibly travel at (~300km/h,
  //covers commercial flights) used to reject GPS fixes that jump an
  //impossible distance in too short a time (bad/glitched readings).
  static const double _maxPlausibleSpeedMetersPerSecond = 300 * 1000 / 3600;

  //
  static BehaviorSubject<Address> currenctAddressSubject =
      BehaviorSubject<Address>();
  // stream for delivery address
  static BehaviorSubject<DeliveryAddress> currenctDeliveryAddressSubject =
      BehaviorSubject<DeliveryAddress>();
  // static Stream<Address> get currenctAddressStream =>
  //     _currenctAddressSubject.stream;

  //fetches the user's current location once and geocodes it. No feature in
  //the app needs a live/continuous GPS stream, so this is a single
  //request/response instead of an open-ended position stream.
  //
  //Uses Geolocator (not the `location` package) throughout: on some
  //devices/Android versions the `location` plugin's Activity binding never
  //attaches, so every call - permission check included - throws
  //PlatformException(NO_ACTIVITY, ...) unconditionally. Geolocator doesn't
  //have that failure mode and is already used successfully elsewhere in
  //this app (e.g. setupCurrentLocationAsPickuplocation).
  static Future<void> prepareLocationListener([bool oneTime = false]) async {
    if (_isFetchingLocation) return;
    _isFetchingLocation = true;
    try {
      _permissionGranted = await Geolocator.checkPermission();
      if (_permissionGranted == LocationPermission.denied) {
        //
        bool requestPermission = true;
        if (!Platform.isIOS) {
          requestPermission = await showRequestDialog();
        }
        if (requestPermission) {
          _permissionGranted = await Geolocator.requestPermission();
        }
      }
      if (_permissionGranted == LocationPermission.denied ||
          _permissionGranted == LocationPermission.deniedForever) {
        return;
      }

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == null || serviceEnabled! == false) {
        print("Location services are disabled");
        return;
      }

      final newPosition = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException("Location fetch timed out after 8s");
        },
      );
      if (!_isPlausiblePosition(newPosition)) {
        print(
          "Ignoring implausible location fix ==> "
          "${newPosition.latitude}, ${newPosition.longitude}",
        );
        return;
      }

      _lastLat = newPosition.latitude;
      _lastLng = newPosition.longitude;
      _lastAcceptedLat = newPosition.latitude;
      _lastAcceptedLng = newPosition.longitude;
      _lastAcceptedLocationAt = DateTime.now();
      await geocodeCurrentLocation();
    } on TimeoutException catch (error) {
      print("Location fetch timed out ==> $error");
    } catch (error) {
      print("Error fetching location ==> $error");
    } finally {
      _isFetchingLocation = false;
    }
  }

  //rejects a GPS fix that would require the device to have travelled faster
  //than is humanly/vehicle-possible since the last accepted fix - a sign of
  //a glitched/bad reading rather than real movement.
  static bool _isPlausiblePosition(Position newPosition) {
    final lastLat = _lastAcceptedLat;
    final lastLng = _lastAcceptedLng;
    final lastAt = _lastAcceptedLocationAt;
    if (lastLat == null || lastLng == null || lastAt == null) {
      return true;
    }

    final elapsedSeconds =
        DateTime.now().difference(lastAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return true;
    }

    final distanceMeters = Geolocator.distanceBetween(
      lastLat,
      lastLng,
      newPosition.latitude,
      newPosition.longitude,
    );

    final impliedSpeed = distanceMeters / elapsedSeconds;
    return impliedSpeed <= _maxPlausibleSpeedMetersPerSecond;
  }

  static Future<bool> showRequestDialog() async {
    //
    var requestResult = false;
    //
    await showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return LocationPermissionDialog(
          onResult: (result) {
            requestResult = result;
          },
        );
      },
    );

    //
    return requestResult;
  }

  //geocodes the last fetched position into an address, once.
  //guarded so overlapping calls (e.g. a stale caller retrying while a
  //previous geocode is still in flight) can't pile up or race each other.
  static Future<void> geocodeCurrentLocation() async {
    if (_isGeocoding || _lastLat == null || _lastLng == null) {
      return;
    }

    _isGeocoding = true;
    final coordinates = new Coordinates(_lastLat ?? 0.0, _lastLng ?? 0.0);

    try {
      //
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        coordinates,
      );
      //
      if (addresses.isNotEmpty) {
        currenctAddress = addresses.first;
        //
        currenctAddressSubject.add(currenctAddress!);
        //set and save for next time
        final mDeliveryaddress = DeliveryAddress(
          name: currenctAddress!.featureName,
          address: currenctAddress!.addressLine,
          latitude: currenctAddress!.coordinates?.latitude,
          longitude: currenctAddress!.coordinates?.longitude,
        );
        //always save/emit the freshly resolved fix - gating this on
        //deliveryaddress==null meant that once any address (even one
        //restored from local storage on a previous cold start) was set,
        //every later GPS fix was silently dropped and
        //currenctDeliveryAddressSubject never emitted, so listeners like
        //the welcome screen's vendor types never refreshed automatically.
        saveSelectedAddressLocally(mDeliveryaddress);
      }
    } catch (error) {
      print("Error get location ==> $error");
    } finally {
      _isGeocoding = false;
    }
  }

  //coordinates to address
  static Future<Address?> addressFromCoordinates({
    required double lat,
    required double lng,
  }) async {
    Address? address;
    final coordinates = new Coordinates(lat, lng);

    try {
      //
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        coordinates,
      );
      //
      if (addresses.isNotEmpty) {
        address = addresses.first;
      }
    } catch (error) {
      print("Issue with addressFromCoordinates ==> $error");
    }
    return address;
  }

  //Helper methods

  //get current lat
  static double? get cLat {
    return LocationService.currenctAddress?.coordinates?.latitude;
  }

  //get current lng
  static double? get cLng {
    return LocationService.currenctAddress?.coordinates?.longitude;
  }

  //
  static saveSelectedAddressLocally(DeliveryAddress? mDeliveryaddress) async {
    deliveryaddress = mDeliveryaddress;
    if (mDeliveryaddress != null) {
      final pref = await LocalStorageService.getPrefs();
      await pref.setString(
        "LOCAL_ADDRESS",
        jsonEncode(mDeliveryaddress.toJson()),
      );
      //
      currenctDeliveryAddressSubject.add(mDeliveryaddress);
      //address
      final mAddress = Address(
        coordinates: Coordinates(
          mDeliveryaddress.latLng.latitude,
          mDeliveryaddress.latLng.longitude,
        ),
        addressLine: mDeliveryaddress.address,
        featureName: mDeliveryaddress.name,
        adminArea: mDeliveryaddress.state,
        subAdminArea: mDeliveryaddress.city,
        countryName: mDeliveryaddress.country,
      );
      currenctAddressSubject.add(mAddress);
    }
  }

  //
  static Future<DeliveryAddress?> getLocallySaveAddress() async {
    final pref = await LocalStorageService.getPrefs();
    final rawData = pref.getString("LOCAL_ADDRESS");
    if (rawData != null && rawData.isNotNullOrBlank) {
      return DeliveryAddress.fromJson(jsonDecode(rawData));
    }
    return null;
  }

  //MISC.
  static Future<double?> getFetchByLocationLat() async {
    final address = await getLocallySaveAddress();
    return address?.latitude ??
        LocationService.currenctAddress?.coordinates?.latitude;
  }

  static Future<double?> getFetchByLocationLng() async {
    final address = await getLocallySaveAddress();
    return address?.longitude ??
        LocationService.currenctAddress?.coordinates?.longitude;
  }
}
