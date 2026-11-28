import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/cart.request.dart';
import 'package:fuodz/requests/payment_method.request.dart';
import 'package:fuodz/requests/taxi.request.dart';
import 'package:fuodz/requests/shared_ride.request.dart';
import 'package:fuodz/models/shared_ride.dart';
import 'package:fuodz/models/shared_trip_status.dart';
import 'package:fuodz/services/shared_status.service.dart';
import 'package:fuodz/enums/ride_type.enum.dart';
import 'package:fuodz/constants/app_taxi_settings.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/chat.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/trip.service.dart';
import 'package:fuodz/view_models/trip_taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/views/pages/taxi/shared/shared_ride_tracking.page.dart';

class TaxiViewModel extends TripTaxiViewModel {
  //
  TaxiViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //requests
  CartRequest cartRequest = CartRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  //

  VendorType? vendorType;
  //coupons
  bool canApplyCoupon = false;
  bool canScheduleTaxiOrder = false;
  Coupon? coupon;
  TextEditingController couponTEC = TextEditingController();

  //
  CheckOut? checkout = CheckOut();
  double subTotal = 0.0;
  double total = 0.0;
  double tip = 0.0;

  // SHARED RIDES (additive, flag-gated) state
  SharedRideRequest sharedRequest = SharedRideRequest();
  RideType rideType = RideType.private;
  SharedRideQuote? sharedQuote;
  // SHARED RIDES: live dispatch outcome for the booked trip (searching | assigned | no_driver).
  String sharedOutcome = "";
  bool get sharedSearching => sharedOutcome == "searching";
  bool get sharedNoDriver => sharedOutcome == "no_driver";
  bool get sharedDriverAssigned => sharedOutcome == "assigned";

  //functions
  void initialise() async {
    // super.initialise();
    //
    fetchTaxiPaymentOptions();
    //
    getOnGoingTrip();
    //set current location as pickup location
    setupCurrentLocationAsPickuplocation();
  }

  //
  bool currentStep(int step) {
    return step == currentOrderStep;
  }

  isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }

  couponCodeChange(String code) {
    canApplyCoupon = code.isNotBlank;
    notifyListeners();
  }

  toggleScheduleTaxiOrder(bool enabled) {
    if (!enabled) {
      checkout?.pickupDate = null;
      checkout?.pickupTime = null;
    }

    canScheduleTaxiOrder = enabled;
    notifyListeners();
  }

  //
  applyCoupon() async {
    //
    setBusyForObject("coupon", true);
    try {
      coupon = await cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: vendorType?.id,
      );
      if (coupon == null) {
        throw "Coupon not found".tr();
      }
      //
      if (coupon!.useLeft <= 0) {
        coupon = null;
        throw "Coupon use limit exceeded".tr();
      } else if (coupon!.expired) {
        coupon = null;
        throw "Coupon has expired".tr();
      }
      clearErrors();

      //
      calculateTotalAmount();
    } catch (error) {
      print("error ==> $error");
      setErrorForObject("coupon", error);
    }
    setBusyForObject("coupon", false);
  }

  //after locations has been selected
  proceedToStep2() async {
    //validate user has selected both pickup and drop off location
    if (dropoffLocation == null) {
      toastError("Please select pickup and drop-off location".tr());
    } else if (canScheduleTaxiOrder &&
        (checkout!.pickupDate == null || checkout!.pickupTime == null)) {
      toastError("Please select pickup date and pickup time".tr());
    } else {
      checkLocationAvailabilityForStep2();
    }
  }

  //checking if taxi booking is enabled in the given location
  checkLocationAvailabilityForStep2() async {
    setBusy(true);
    final apiResponse = await taxiRequest.locationAvailable(
      pickupLocation?.latitude ?? 0.00,
      pickupLocation?.longitude ?? 0.00,
    );
    if (apiResponse.allGood) {
      prepareStep2();
    } else {
      setCurrentStep(0);
    }
    setBusy(false);
  }

  //
  void prepareStep2() {
    setCurrentStep(2);
    drawTripPolyLines();
    fetchVehicleTypes();
  }

  //vehicle types
  fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await taxiRequest.getVehicleTypePricing(
        pickupLocation!,
        dropoffLocation!,
        countryCode: LocationService.currenctAddress?.countryCode,
      );
    } catch (error) {
      print("Error getting vehicleTypes ==> $error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  resortVehicleTypes() {
    vehicleTypes.removeWhere((e) => e.id == selectedVehicleType?.id);
    vehicleTypes.insert(0, selectedVehicleType!);
  }

  //
  changeSelectedVehicleType(VehicleType vehicleType) {
    selectedVehicleType = vehicleType;
    // resortVehicleTypes();
    calculateTotalAmount();
    //new feature
    generatePossibleDriverETA();
  }

  //
  calculateTotalAmount() async {
    if (selectedVehicleType == null) return;
    setBusyForObject("summary", true);
    try {
      final summary = await taxiRequest.getTaxiOrderSummary(
        token: selectedVehicleType!.encrypted!,
        couponCode: coupon?.code,
        tip: tip,
      );
      subTotal = summary["subtotal"].toString().toDouble();
      checkout!.discount = summary["discount"].toString().toDouble();
      tip = summary["tip"].toString().toDouble();
      total = summary["total"].toString().toDouble();
      selectedVehicleType!.encrypted = summary["token"].toString();
    } catch (error) {
      print("Error generating order summary ==> $error");
    }
    setBusyForObject("summary", false);
    notifyListeners();
  }

  //
  generatePossibleDriverETA() async {
    setBusy(true);
    try {
      possibleDriverETA = await TripService().generatePossibleDriverETA(
        lat: pickupLocation!.latitude!,
        lng: pickupLocation!.longitude!,
        vehicleTypeId: selectedVehicleType?.id,
      );
    } catch (error) {
      print("Error getting possibleDriverETA ==> $error");
    }
    setBusy(false);
  }

  // ===== SHARED RIDES (additive, flag-gated) =====
  bool get sharedRidesAvailable => AppTaxiSettings.sharedRidesEnabled;

  void selectRideType(RideType type) {
    rideType = type;
    notifyListeners();
    if (type == RideType.shared &&
        sharedRidesAvailable &&
        pickupLocation != null &&
        dropoffLocation != null &&
        selectedVehicleType != null) {
      fetchSharedQuote();
    }
  }

  Future<void> fetchSharedQuote() async {
    if (selectedVehicleType == null) return;
    setBusyForObject("sharedQuote", true);
    try {
      sharedQuote = await sharedRequest.quoteRaw(
        pickupLat: (pickupLocation?.latitude ?? 0).toDouble(),
        pickupLng: (pickupLocation?.longitude ?? 0).toDouble(),
        dropoffLat: (dropoffLocation?.latitude ?? 0).toDouble(),
        dropoffLng: (dropoffLocation?.longitude ?? 0).toDouble(),
        vehicleTypeId: selectedVehicleType!.id,
      );
    } catch (error) {
      print("Shared quote error ==> $error");
      sharedQuote = null;
    }
    setBusyForObject("sharedQuote", false);
    notifyListeners();
  }

  processSharedOrder() async {
    if (selectedVehicleType == null || selectedPaymentMethod == null) {
      AlertService.error(
        title: "Shared ride".tr(),
        text: "Please select a vehicle type and payment method".tr(),
      );
      return;
    }
    setBusy(true);
    try {
      final booking = await sharedRequest.bookRaw(
        pickupLat: (pickupLocation?.latitude ?? 0).toDouble(),
        pickupLng: (pickupLocation?.longitude ?? 0).toDouble(),
        pickupAddress: pickupLocation?.address,
        dropoffLat: (dropoffLocation?.latitude ?? 0).toDouble(),
        dropoffLng: (dropoffLocation?.longitude ?? 0).toDouble(),
        dropoffAddress: dropoffLocation?.address,
        vehicleTypeId: selectedVehicleType!.id,
        paymentMethodId: selectedPaymentMethod!.id,
      );
      setBusy(false);
      sharedOutcome = "searching";
      closeOrderSummary();
      // Open the dedicated Shared Ride tracking screen (live driver location,
      // pickup/destination markers, driver details, ETA, server-authoritative
      // status). The tracking screen owns its own polling, so we do NOT also
      // start SharedStatusService here (that would double-poll /status).
      // Falls back to a polled alert only if no trip id came back.
      if (booking.sharedTripId != null) {
        viewContext.nextPage(
          SharedRideTrackingPage(tripId: booking.sharedTripId!),
        );
      } else {
        _trackSharedStatus(booking.sharedTripId);
        AlertService.success(
          title: "Shared ride requested".tr(),
          text: booking.pooled
              ? "You've been added to a shared trip".tr()
              : "Looking for a shared trip".tr(),
        );
      }
    } catch (error) {
      setBusy(false);
      AlertService.error(
        title: "Shared booking failed".tr(),
        text: "$error",
      );
    }
  }

  // SHARED RIDES: poll the backend for the dispatch outcome (searching | assigned
  // | no_driver). The service polls on an interval and is nudged by push + resume.
  void _trackSharedStatus(int? tripId) {
    if (tripId == null) return;
    SharedStatusService().track(tripId, _onSharedStatus);
  }

  void _onSharedStatus(SharedTripStatus status) {
    final changed = sharedOutcome != status.outcome;
    sharedOutcome = status.outcome;
    notifyListeners();
    if (!changed) return; // only act on an outcome transition
    if (status.isAssigned) {
      // Driver accepted — the existing ongoing-trip UI surfaces the driver as
      // the order updates; confirm it to the customer.
      AlertService.success(
        title: "Driver assigned".tr(),
        text: "A driver is on the way for your shared trip.".tr(),
      );
    } else if (status.isNoDriver) {
      SharedStatusService().stop();
      AlertService.error(
        title: "No driver available".tr(),
        text: "Sorry, no driver was available for your shared trip.".tr(),
      );
      closeOrderSummary();
    }
  }

  //
  processNewOrder() async {
    // SHARED RIDES (additive, flag-gated): when the backend feature is ON AND
    // the customer explicitly chose Shared, route to the shared booking path.
    // When the flag is off (default) this guard is false, so the private-taxi
    // path below runs byte-for-byte unchanged.
    if (sharedRidesAvailable && rideType == RideType.shared) {
      return processSharedOrder();
    }
    //
    final params = {
      "payment_method_id": selectedPaymentMethod?.id,
      "vehicle_type_id": selectedVehicleType?.id,
      "pickup": {
        "lat": pickupLocation!.latitude,
        "lng": pickupLocation!.longitude,
        "address": pickupLocation!.address,
      },
      "dropoff": {
        "lat": dropoffLocation!.latitude,
        "lng": dropoffLocation!.longitude,
        "address": dropoffLocation!.address,
      },
      "sub_total": subTotal,
      "tax": selectedVehicleType?.tax,
      "total": total,
      "discount": checkout!.discount,
      "tip": tip,
      "coupon_code": coupon?.code,
      "vehicle_type": selectedVehicleType?.encrypted,
      "pickup_date": checkout!.pickupDate,
      "pickup_time": checkout!.pickupTime,
    };

    setBusy(true);
    try {
      final apiResponse = await taxiRequest.placeNeworder(
        params: params,
        idempotencyKey: orderIdempotencyKey,
      );
      resetOrderIdempotencyKey();
      setBusy(false);

      //if there was an issue placing the order
      if (!apiResponse.allGood) {
        AlertService.error(
          title: "Order failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //
        onGoingOrderTrip = Order.fromJson(apiResponse.body["order"]);
        //payment
        String paymentLink = apiResponse.body["link"];
        if (paymentLink.isNotBlank) {
          await openWebpageLink(paymentLink);
        }
        //
        if (checkout!.pickupDate == null || !canScheduleTaxiOrder) {
          startHandlingOnGoingTrip();
        } else {
          closeOrderSummary();
        }
      }
    } catch (error) {
      resetOrderIdempotencyKey();
      setBusy(false);
      AlertService.error(title: "Order failed".tr(), text: "$error");
    }
  }

  //
  openTripChat() {
    //
    Map<String, PeerUser> peers = {
      '${onGoingOrderTrip!.userId}': PeerUser(
        id: '${onGoingOrderTrip!.userId}',
        name: onGoingOrderTrip!.user.name,
        image: onGoingOrderTrip!.user.photo,
      ),
      '${onGoingOrderTrip?.driver?.id}': PeerUser(
        id: "${onGoingOrderTrip?.driver?.id}",
        name: onGoingOrderTrip?.driver?.name ?? "Driver".tr(),
        image: onGoingOrderTrip?.driver?.photo,
      ),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${onGoingOrderTrip?.userId}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + onGoingOrderTrip!.code + "/customerDriver/chats",
      title: "Chat with driver".tr(),
      supportMedia: AppUISettings.canCustomerChatSupportMedia,
    );
    //
    Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.chatRoute, arguments: chatEntity);
  }

  Future<Order?> getLastTripForRating() async {
    try {
      final order = await taxiRequest.getLastTripForRating();
      if (order == null || order.driver == null) {
        setCurrentStep(1);
      }
      return order;
    } catch (error) {
      return null;
    }
  }
}
