import 'package:flutter/material.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/shared_ride.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/requests/shared_ride.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// SHARED RIDES — customer booking view model. Handles the quote -> confirm ->
/// book -> cancel flow with explicit loading / error / retry state, keeping the
/// customer's own journey distinct from the overall shared trip.
class SharedRideViewModel extends MyBaseViewModel {
  SharedRideViewModel(BuildContext context) {
    viewContext = context;
  }

  final SharedRideRequest _request = SharedRideRequest();

  DeliveryAddress? pickup;
  DeliveryAddress? dropoff;
  VehicleType? vehicleType;
  PaymentMethod? paymentMethod;
  int seats = 1;

  SharedRideQuote? quote;
  SharedRideBooking? booking;
  String? lastError;

  bool get canQuote =>
      pickup != null && dropoff != null && vehicleType != null;

  bool get isAvailable => quote?.enabled ?? false;

  /// Fetch a transparent per-passenger quote. Safe to call repeatedly (retry).
  Future<void> getQuote() async {
    if (!canQuote) {
      return;
    }
    lastError = null;
    setBusyForObject(quote, true);
    setBusy(true);
    try {
      quote = await _request.quote(
        pickup: pickup!,
        dropoff: dropoff!,
        vehicleTypeId: vehicleType!.id,
        seats: seats,
      );
    } catch (error) {
      lastError = "$error";
      setError(error);
    }
    setBusy(false);
    setBusyForObject(quote, false);
    notifyListeners();
  }

  /// Confirm the booking. Returns the booking on success, null on failure.
  Future<SharedRideBooking?> confirmBooking() async {
    if (!canQuote || paymentMethod == null) {
      toastError("Please select pickup, drop-off, vehicle and payment".tr());
      return null;
    }
    lastError = null;
    setBusy(true);
    try {
      booking = await _request.book(
        pickup: pickup!,
        dropoff: dropoff!,
        vehicleTypeId: vehicleType!.id,
        paymentMethodId: paymentMethod!.id,
        seats: seats,
      );
      setBusy(false);
      toastSuccessful(
        (booking?.pooled ?? false)
            ? "You've been added to a shared trip".tr()
            : "Shared ride requested".tr(),
      );
      notifyListeners();
      return booking;
    } catch (error) {
      lastError = "$error";
      setError(error);
      setBusy(false);
      toastError("$error");
      notifyListeners();
      return null;
    }
  }

  /// Cancel the customer's own seat (does not affect co-passengers).
  Future<bool> cancelMySeat() async {
    final passengerId = booking?.passengerId;
    if (passengerId == null) {
      return false;
    }
    setBusy(true);
    try {
      final res = await _request.cancel(passengerId);
      setBusy(false);
      if (res.allGood) {
        toastSuccessful("Your shared ride booking was cancelled".tr());
        notifyListeners();
        return true;
      }
      toastError(res.message ?? "Could not cancel".tr());
      return false;
    } catch (error) {
      setBusy(false);
      toastError("$error");
      return false;
    }
  }

  void retry() => getQuote();
}
