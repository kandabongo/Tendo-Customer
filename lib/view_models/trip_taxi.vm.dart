import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/requests/payment_method.request.dart';
import 'package:fuodz/requests/taxi.request.dart';
import 'package:fuodz/services/order_details_websocket.service.dart';
import 'package:fuodz/services/order_driver_location_websocket.service.dart';
import 'package:fuodz/view_models/taxi_google_map.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TripTaxiViewModel extends TaxiGoogleMapViewModel {
  //requests
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  //
  Order? onGoingOrderTrip;
  double newTripRating = 3.0;
  TextEditingController tripReviewTEC = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: AppStrings.firebaseDb,
  );
  StreamSubscription? tripUpdateStream;

  LatLng? driverPosition;
  double driverPositionRotation = 0;

  //
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;

  //vheicle types
  List<VehicleType> vehicleTypes = [];
  VehicleType? selectedVehicleType;
  int? possibleDriverETA;

  @override
  dispose() {
    tripUpdateStream?.cancel();
    driverLocationStream?.cancel();
    OrderDetailsWebsocketService().disconnect();
    super.dispose();
  }

  //get current on going trip
  getOnGoingTrip() async {
    //
    setBusyForObject(onGoingOrderTrip, true);
    try {
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      loadTripUIByOrderStatus(initial: true);
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //cancel trip
  void cancelTrip() async {
    //
    setBusyForObject(onGoingOrderTrip, true);
    try {
      final apiResponse = await taxiRequest.cancelTrip(onGoingOrderTrip!.id);
      //
      if (apiResponse.allGood) {
        toastSuccessful(
          apiResponse.message ?? "Trip cancelled successfully".tr(),
        );
        setCurrentStep(1);
        clearMapData();
      } else {
        toastError(apiResponse.message ?? "Failed to cancel trip".tr());
      }
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //
  loadTripUIByOrderStatus({bool initial = false}) {
    //
    //
    if ((initial)) {
      //
      pickupLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.pickupLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.pickupLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.pickupAddress,
      );
      //
      dropoffLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.dropoffAddress,
      );
      //set the pickup and drop off locations
      drawTripPolyLines();
      startHandlingOnGoingTrip();
    } else if (onGoingOrderTrip != null) {
      switch (onGoingOrderTrip?.status) {
        case "pending":
          setCurrentStep(3);
          break;
        case "preparing":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "ready":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "enroute":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "delivered":
          setCurrentStep(1);
          clearMapData();
          zoomToLocation(
            LatLng(
              onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull() ??
                  0.0,
              onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull() ??
                  0.0,
            ),
          );
          stopAllListeners();
          //check for last trip that requires rating
          setCurrentStep(6);
          break;
        case "failed":
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        case "cancelled":
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        default:
      }
    }

    //
    if (onGoingOrderTrip == null) {
      setCurrentStep(1);
      clearMapData();
      stopAllListeners();
      closeOrderSummary();
      OrderDetailsWebsocketService().disconnect();
      OrderDriverLocationWebsocketService().disconnect();
      //check for last trip that requires rating
      setCurrentStep(6);
    }
  }

  //
  void startHandlingOnGoingTrip() async {
    //
    if (onGoingOrderTrip == null || onGoingOrderTrip!.isScheduled) {
      setCurrentStep(1);
      return;
    }
    //clear current UI step
    setCurrentStep(3);
    //foudz
    loadTripUIByOrderStatus();
    if (onGoingOrderTrip?.driverId != null) {
      startDriverDetailsListener();
    }

    //
    if (AppStrings.useWebsocketAssignment) {
      //start websocket listening to ordr events
      OrderDetailsWebsocketService().connectToOrderChannel(
        "${onGoingOrderTrip?.id}",
        (data) async {
          //once driver is assigned
          final driverId = data["driver_id"] ?? null;
          if (driverId != null && onGoingOrderTrip?.driverId == null) {
            onGoingOrderTrip?.driverId = driverId;
          }

          //
          if (onGoingOrderTrip?.driver == null && driverId != null) {
            await loadDriverDetails();
          }
          if (onGoingOrderTrip?.driver != null) {
            startDriverDetailsListener();
          }

          //update the rest onGoingTrip details
          onGoingOrderTrip?.status = data["status"] ?? "failed";
          //
          notifyListeners();
          loadTripUIByOrderStatus();
        },
      );
    } else {
      //set new on trip step
      tripUpdateStream = firebaseFirestore
          .collection("orders")
          .doc("${onGoingOrderTrip?.code}")
          .snapshots()
          .listen((event) async {
            //once driver is assigned

            final driverId =
                event.data() != null
                    ? event.data()!["driver_id"] ?? null
                    : null;
            if (driverId != null && onGoingOrderTrip?.driverId == null) {
              onGoingOrderTrip?.driverId = event.data()!["driver_id"];
              onGoingOrderTrip?.driver = event.data()!["driver"] ?? null;
            }

            //
            if (onGoingOrderTrip?.driver == null) {
              await loadDriverDetails();
            }
            startDriverDetailsListener();

            //update the rest onGoingTrip details
            if (event.exists) {
              onGoingOrderTrip?.status = event.data()?["status"] ?? "failed";
            }
            //
            notifyListeners();
            loadTripUIByOrderStatus();
          });
    }
    //start order details listening stream
  }

  //DRIVER SECTION
  loadDriverDetails() async {
    try {
      final mDriverId = onGoingOrderTrip?.driverId;
      // onGoingOrderTrip.driver =
      //     await taxiRequest.getDriverInfo(onGoingOrderTrip.driverId);
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      //loop until driver data is gotten
      if (onGoingOrderTrip?.driver == null) {
        onGoingOrderTrip?.driver = await taxiRequest.getDriverInfo(mDriverId!);
        if (onGoingOrderTrip?.driver == null) {
          await Future.delayed(Duration(seconds: 5));
          loadDriverDetails();
        }
      }
      notifyListeners();
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
  }

  //Start listening to driver location changes
  void startDriverDetailsListener() async {
    if (AppStrings.useWebsocketAssignment) {
      OrderDriverLocationWebsocketService().connectToDriverLocationChannel(
        "${onGoingOrderTrip?.driverId}",
        (data) async {
          //
          final driverLat = data["lat"] ?? null;
          final driverLng = data["long"] ?? data["lng"] ?? null;
          final driverRotation = data["rotation"] ?? 0;
          if (driverLat != null && driverLng != null) {
            driverPosition = LatLng(
              driverLat.toString().toDouble(),
              driverLng.toString().toDouble(),
            );
            driverPositionRotation = double.parse((driverRotation).toString());
            updateDriverMarkerPosition();
            startZoomFocusDriver();
          }
        },
        onSubscribedSuccess: () {
          //initiate first sync
          OrderRequest().syncDriverLocation(onGoingOrderTrip!.id);
        },
      );
    } else {
      //
      driverLocationStream = firebaseFirestore
          .collection("drivers")
          .doc("${onGoingOrderTrip?.driverId}")
          .snapshots()
          .listen((event) {
            //
            if (!event.exists) {
              return;
            }
            //
            driverPosition = LatLng(
              event.data()?["lat"],
              event.data()?["long"],
            );
            driverPositionRotation = double.parse(
              (event.data()?["rotation"] ?? 0).toString(),
            );
            updateDriverMarkerPosition();
            startZoomFocusDriver();
          });
    }
  }

  stopDriverListener() async {
    if (AppStrings.useWebsocketAssignment) {
      await OrderDriverLocationWebsocketService().disconnect();
    }
    driverLocationStream?.cancel();
    driverLocationStream = null;
    notifyListeners();
  }

  //
  updateDriverMarkerPosition() {
    //
    Marker? driverMarker = gMapMarkers.firstOrNullWhere(
      (e) => e.markerId.value == "driverMarker",
    );
    //
    if (driverMarker == null) {
      driverMarker = Marker(
        markerId: MarkerId('driverMarker'),
        position: driverPosition!,
        rotation: driverPositionRotation,
        icon: driverIcon!,
        anchor: Offset(0.5, 0.5),
      );
      gMapMarkers.add(driverMarker);
    } else {
      driverMarker = driverMarker.copyWith(
        positionParam: driverPosition,
        rotationParam: driverPositionRotation,
        iconParam: driverIcon!,
      );
      gMapMarkers.removeWhere((e) => e.markerId.value == "driverMarker");
      gMapMarkers.add(driverMarker);
    }

    notifyListeners();
  }

  //
  startZoomFocusDriver() async {
    //create bond between driver and
    if (driverPosition == null) {
      return;
    }

    if (onGoingOrderTrip == null) {
      return;
    }

    //check status to determine the latlng bound
    if (onGoingOrderTrip!.canZoomOnPickupLocation) {
      //zoom to driver and pickup latbound
      updateCameraLocation(
        driverPosition!,
        LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        googleMapController,
      );
    } else if (onGoingOrderTrip!.canZoomOnDropoffLocation) {
      //zoom to driver and dropoff latbound
      updateCameraLocation(
        driverPosition!,
        LatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
        googleMapController,
      );
    }

    //
    await updateDriverIconDynamically(onGoingOrderTrip!.taxiOrder!.vehicleType);
    updateDriverMarkerPosition();
  }

  //
  stopAllListeners() async {
    tripUpdateStream?.cancel();
    driverLocationStream?.cancel();

    if (AppStrings.useWebsocketAssignment) {
      await OrderDriverLocationWebsocketService().disconnect();
      await OrderDetailsWebsocketService().disconnect();
    }

    //when trip is ended
    selectedVehicleType = null;
    selectedPaymentMethod = paymentMethods.firstOrNull;
    possibleDriverETA = null;

    notifyListeners();
  }

  //when trip is ended
  dismissTripRating() async {
    tripReviewTEC.clear();
    setCurrentStep(1);
    zoomToCurrentLocation();
  }

  submitTripRating(Order order) async {
    //
    setBusyForObject(newTripRating, true);
    //
    final apiResponse = await taxiRequest.rateDriver(
      order.id,
      order.driverId!,
      newTripRating,
      tripReviewTEC.text,
    );
    //
    if (apiResponse.allGood) {
      toastSuccessful(apiResponse.message ?? "Trip rated successfully".tr());
      dismissTripRating();
    } else {
      toastError(apiResponse.message ?? "Failed to rate trip".tr());
    }
    setBusyForObject(newTripRating, false);
  }

  closeOrderSummary({bool clear = true}) {
    if (clear) {
      pickupLocation = null;
      dropoffLocation = null;
      pickupLocationTEC.clear();
      dropoffLocationTEC.clear();
      selectedVehicleType = null;
      selectedPaymentMethod = paymentMethods.firstOrNull;
      possibleDriverETA = null;
      notifyListeners();
    }
    //
    selectedVehicleType = null;
    clearMapData();
    setCurrentStep(1);
  }
}
