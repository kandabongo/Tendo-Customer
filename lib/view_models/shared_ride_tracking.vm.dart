import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/shared_trip_status.dart';
import 'package:fuodz/requests/shared_ride.request.dart';
import 'package:fuodz/requests/taxi.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/order_driver_location_websocket.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// SHARED RIDES (customer) — dedicated live-tracking screen view model.
///
/// Reuses existing Tendo infrastructure only:
///  - driver live GPS from Firestore `drivers/{driverId}` (same source the
///    private-taxi tracking already uses — keyed by driver id, so it works for
///    shared trips with no backend change);
///  - GoogleMap + markers + polyline (same pattern as OrderTrackingViewModel);
///  - the enriched `/taxi/shared/trip/{id}/status` payload (Change A) for driver
///    details, the customer's own leg status + coords, and aggregate progress.
///
/// It is READ-ONLY with respect to trip state: every lifecycle transition stays
/// server-authoritative. It never books, pays, or mutates the trip; it polls and
/// renders. No private-taxi completion/payment path is touched.
class SharedRideTrackingViewModel extends MyBaseViewModel {
  SharedRideTrackingViewModel(BuildContext context, this.tripId) {
    this.viewContext = context;
  }

  final int tripId;

  final SharedRideRequest _request = SharedRideRequest();
  final TaxiRequest _taxiRequest = TaxiRequest();
  Timer? _pollTimer;
  StreamSubscription? _driverLocationStream;

  SharedTripStatus? status;
  String? _lastLegStatus; // for transition notifications
  String? _subscribedDriverId;
  bool _disposed = false;

  // cancellation + completion/rating
  bool cancelling = false;
  bool ratingSubmitted = false;
  bool submittingRating = false;

  /// The customer's journey is finished (dropped off, or trip completed).
  bool get isCompleted =>
      status?.iAmDropped == true || status?.trip?.status == "completed";

  /// Terminal without service (no driver found, or the trip was cancelled).
  bool get isCancelledOrNoDriver =>
      status?.isNoDriver == true || status?.isCancelled == true;

  /// The customer may still cancel while the ride has not started/finished.
  bool get canCancel {
    final leg = status?.myLegStatus;
    return !isCompleted &&
        !isCancelledOrNoDriver &&
        leg != "onboard" &&
        leg != "dropped";
  }

  double get fareAmount => status?.me?.passengerFare ?? 0;

  // map
  GoogleMapController? controller;
  Set<Marker> mapMarkers = {};
  LatLng? pickupLatLng;
  LatLng? dropoffLatLng;
  LatLng? driverLatLng;
  final PolylinePoints _polylinePoints =
      PolylinePoints(apiKey: AppStrings.googleMapApiKey);
  final Map<PolylineId, Polyline> polylines = {};
  bool _polylineDrawn = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: AppStrings.firebaseDb,
  );

  // ---- lifecycle --------------------------------------------------------
  void initialise() {
    setBusy(true);
    _poll(); // immediate
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _driverLocationStream?.cancel();
    controller = null;
    if (AppStrings.useWebsocketAssignment) {
      try {
        OrderDriverLocationWebsocketService().disconnect();
      } catch (_) {}
    }
    super.dispose();
  }

  // ---- cancellation -----------------------------------------------------
  /// Customer cancels their own leg (server-authoritative). No charge was
  /// raised before onboard, so there is nothing to refund.
  Future<void> cancelTrip() async {
    final pid = status?.me?.passengerId;
    if (pid == null || cancelling) return;
    await AlertService.confirm(
      title: "Cancel ride?".tr(),
      text: "Are you sure you want to cancel this shared ride?".tr(),
      confirmBtnText: "Yes, cancel".tr(),
      onConfirm: () => _doCancel(pid),
    );
  }

  Future<void> _doCancel(int pid) async {
    if (cancelling) return;
    cancelling = true;
    notifyListeners();
    try {
      await _request.cancel(pid);
      _pollTimer?.cancel();
      AlertService.success(
        title: "Ride cancelled".tr(),
        text: "Your shared ride has been cancelled.".tr(),
      );
      if (!_disposed) viewContext.pop();
    } catch (e) {
      AlertService.error(title: "Couldn't cancel".tr(), text: "$e");
    }
    cancelling = false;
    if (!_disposed) notifyListeners();
  }

  // ---- rating on completion --------------------------------------------
  Future<void> submitRating(double stars, String review) async {
    final orderId = status?.me?.orderId;
    final driverId = status?.driver?.id ?? status?.driverId;
    if (orderId == null || driverId == null || submittingRating) return;
    submittingRating = true;
    notifyListeners();
    try {
      await _taxiRequest.rateDriver(orderId, driverId, stars, review);
      ratingSubmitted = true;
      AlertService.success(
        title: "Thank you!".tr(),
        text: "Your rating has been submitted.".tr(),
      );
    } catch (e) {
      AlertService.error(title: "Couldn't submit rating".tr(), text: "$e");
    }
    submittingRating = false;
    if (!_disposed) notifyListeners();
  }

  void finishAfterRating() {
    _pollTimer?.cancel();
    if (!_disposed) viewContext.pop();
  }

  void setMapController(GoogleMapController c) {
    controller = c;
    _fitCamera();
  }

  // ---- polling ----------------------------------------------------------
  Future<void> _poll() async {
    if (_disposed) return;
    try {
      final s = await _request.tripStatus(tripId);
      if (_disposed) return;
      status = s;
      setBusy(false);

      _ensureMyMarkers();
      _maybeDrawPolyline();
      _subscribeToDriverLocation(s);
      _notifyLegTransition(s);

      notifyListeners();

      // Stop polling only when the journey is truly over for this customer.
      if (s.iAmDropped || s.isNoDriver || s.isCancelled ||
          s.trip?.status == "completed") {
        _pollTimer?.cancel();
      }
    } catch (e) {
      setBusy(false);
      // transient network error — keep the last good state, keep polling
    }
  }

  // ---- markers & route --------------------------------------------------
  void _ensureMyMarkers() async {
    final me = status?.me;
    if (me == null) return;

    if (me.hasPickup && !mapMarkers.any((m) => m.markerId.value == "pickup")) {
      pickupLatLng = LatLng(me.pickupLatitude!, me.pickupLongitude!);
      final icon = await _icon(AppImages.addressPin);
      mapMarkers.add(Marker(
        markerId: const MarkerId("pickup"),
        position: pickupLatLng!,
        infoWindow: InfoWindow(title: "Pickup".tr()),
        icon: icon,
      ));
      notifyListeners();
    }
    if (me.hasDropoff && !mapMarkers.any((m) => m.markerId.value == "dropoff")) {
      dropoffLatLng = LatLng(me.dropoffLatitude!, me.dropoffLongitude!);
      final icon = await _icon(AppImages.deliveryParcel);
      mapMarkers.add(Marker(
        markerId: const MarkerId("dropoff"),
        position: dropoffLatLng!,
        infoWindow: InfoWindow(title: "Destination".tr()),
        icon: icon,
      ));
      notifyListeners();
    }
  }

  void _maybeDrawPolyline() async {
    if (_polylineDrawn || pickupLatLng == null || dropoffLatLng == null) return;
    _polylineDrawn = true;
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          destination:
              PointLatLng(dropoffLatLng!.latitude, dropoffLatLng!.longitude),
          mode: TravelMode.driving,
        ),
      );
      final coords =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      if (coords.isNotEmpty) {
        polylines[const PolylineId("route")] = Polyline(
          polylineId: const PolylineId("route"),
          color: AppColor.primaryColor,
          width: 3,
          points: coords,
        );
        notifyListeners();
      }
    } catch (_) {
      _polylineDrawn = false; // allow a retry on a later poll
    }
  }

  // ---- live driver location --------------------------------------------
  // Mirrors the EXISTING private-taxi active-trip tracking (trip_taxi.vm): the
  // transport depends on the same server setting the driver app writes with.
  //   useWebsocketAssignment == true  -> Reverb private channel
  //                                      drivers.{driverId}.location.updated
  //   useWebsocketAssignment == false -> Firestore drivers/{driverId}
  // This guarantees the customer reads from whichever source the driver is
  // actually publishing to, with no backend change.
  void _subscribeToDriverLocation(SharedTripStatus s) {
    final driverId = s.driver?.id ?? s.driverId;
    if (driverId == null) return;
    if (_subscribedDriverId == "$driverId") return; // already listening
    _subscribedDriverId = "$driverId";

    if (AppStrings.useWebsocketAssignment) {
      OrderDriverLocationWebsocketService().connectToDriverLocationChannel(
        "$driverId",
        (data) async {
          final lat = _num(data is Map ? data["lat"] : null);
          final lng = _num(data is Map ? (data["long"] ?? data["lng"]) : null);
          if (lat == null || lng == null) return;
          driverLatLng = LatLng(lat, lng);
          await _updateDriverMarker();
          notifyListeners();
          _fitCamera();
        },
      );
    } else {
      _driverLocationStream?.cancel();
      _driverLocationStream = _firestore
          .collection("drivers")
          .doc("$driverId")
          .snapshots()
          .listen((event) async {
        if (!event.exists) return;
        final data = event.data();
        if (data == null) return;
        final lat = _num(data["lat"]);
        final lng = _num(data["long"] ?? data["lng"]);
        if (lat == null || lng == null) return;
        driverLatLng = LatLng(lat, lng);
        await _updateDriverMarker();
        notifyListeners();
        _fitCamera();
      });
    }
  }

  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> _updateDriverMarker() async {
    if (driverLatLng == null) return;
    mapMarkers.removeWhere((m) => m.markerId.value == "driver");
    final icon = await _icon(AppImages.driverCar);
    mapMarkers.add(Marker(
      markerId: const MarkerId("driver"),
      position: driverLatLng!,
      infoWindow: InfoWindow(title: status?.driver?.name ?? "Driver".tr()),
      icon: icon,
    ));
  }

  // ---- derived display --------------------------------------------------
  SharedTripDriver? get driver => status?.driver;

  /// Human headline for the current leg, reflecting server-authoritative state.
  String get statusHeadline {
    final s = status;
    if (s == null) return "Loading…".tr();
    if (s.isSearching) return "Finding you a driver…".tr();
    if (s.isNoDriver) return "No driver available".tr();
    if (s.isCancelled) return "Trip cancelled".tr();
    switch (s.myLegStatus) {
      case "en_route":
        return "Driver is on the way".tr();
      case "onboard":
        return "You're on board".tr();
      case "dropped":
        return "You've arrived".tr();
      case "accepted":
      case "offered":
      default:
        return "Driver assigned".tr();
    }
  }

  String get statusSubtitle {
    final s = status;
    if (s == null) return "";
    if (s.isSearching) return "Hang tight — matching the nearest driver.".tr();
    final eta = etaMinutes;
    if (s.myLegStatus == "en_route" && eta != null) {
      return "About $eta min away".tr();
    }
    if (s.myLegStatus == "onboard" && eta != null) {
      return "About $eta min to your destination".tr();
    }
    return "";
  }

  /// Straight-line ETA estimate (urban avg ~26 km/h) from the live driver
  /// position to the customer's next relevant point. Clearly an estimate; the
  /// map + driver position remain the source of truth.
  int? get etaMinutes {
    if (driverLatLng == null) return null;
    LatLng? target;
    if (status?.myLegStatus == "onboard") {
      target = dropoffLatLng;
    } else {
      target = pickupLatLng;
    }
    if (target == null) return null;
    final km = _haversineKm(driverLatLng!, target);
    final mins = (km / 26.0) * 60.0;
    return math.max(1, mins.round());
  }

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  double _rad(double d) => d * math.pi / 180.0;

  /// "2 of 3 passengers on board" — aggregate only, no other-passenger PII.
  String get coRidersSummary {
    final t = status?.trip;
    if (t == null || (t.passengersTotal ?? 0) <= 1) return "";
    final onboard = t.passengersOnboard ?? 0;
    final total = t.passengersTotal ?? 0;
    return "$onboard of $total passengers on board".tr();
  }

  // ---- in-app milestone notifications -----------------------------------
  void _notifyLegTransition(SharedTripStatus s) {
    final leg = s.myLegStatus;
    if (leg == null || leg == _lastLegStatus) return;
    final previous = _lastLegStatus;
    _lastLegStatus = leg;
    if (previous == null) return; // first observation — no toast
    switch (leg) {
      case "en_route":
        AlertService.success(
          title: "Driver approaching".tr(),
          text: "Your driver is on the way to your pickup.".tr(),
        );
        break;
      case "onboard":
        AlertService.success(
          title: "Picked up".tr(),
          text: "You're on board. Enjoy your shared ride.".tr(),
        );
        break;
      case "dropped":
        AlertService.success(
          title: "You've arrived".tr(),
          text: "Thanks for riding with Tendo.".tr(),
        );
        break;
    }
  }

  // ---- camera & helpers -------------------------------------------------
  void _fitCamera() {
    if (_disposed || controller == null) return;
    final pts = <LatLng>[
      if (driverLatLng != null) driverLatLng!,
      if (pickupLatLng != null) pickupLatLng!,
      if (dropoffLatLng != null) dropoffLatLng!,
    ];
    if (pts.length < 2 || controller == null) {
      if (pts.length == 1) {
        controller?.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 14));
      }
      return;
    }
    controller?.animateCamera(
      CameraUpdate.newLatLngBounds(_bounds(pts), 70),
    );
  }

  LatLngBounds _bounds(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final p in list) {
      if (x0 == null) {
        x0 = x1 = p.latitude;
        y0 = y1 = p.longitude;
      } else {
        if (p.latitude > x1!) x1 = p.latitude;
        if (p.latitude < x0) x0 = p.latitude;
        if (p.longitude > y1!) y1 = p.longitude;
        if (p.longitude < y0!) y0 = p.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1 ?? 0, y1 ?? 0),
      southwest: LatLng(x0 ?? 0, y0 ?? 0),
    );
  }

  Future<BitmapDescriptor> _icon(String asset) async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.1, size: Size(28, 28)),
      asset,
    );
  }

  void callDriver() {
    final phone = status?.driver?.phone;
    if (phone == null || phone.isEmpty) return;
    launchUrlString("tel:$phone");
  }

  LatLng get initialCamera =>
      pickupLatLng ?? driverLatLng ?? const LatLng(-15.3875, 28.3228); // Lusaka
}
