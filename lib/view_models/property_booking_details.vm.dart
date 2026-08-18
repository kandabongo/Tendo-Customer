import 'package:flutter/material.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/views/pages/booking/property_details.page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fuodz/extensions/context.dart';

class PropertyBookingDetailsViewModel extends MyBaseViewModel {
  PropertyBookingDetailsViewModel(
    BuildContext context,
    this.order, {
    this.paymentLink,
  }) {
    this.viewContext = context;
  }

  Order order;
  final String? paymentLink;

  void initialise() {
    fetchOrderDetails();
  }

  void fetchOrderDetails() async {
    setBusy(true);
    try {
      order = await OrderRequest().getOrderDetails(id: order.id);
    } catch (e) {
      toastError(e.toString());
    }
    setBusy(false);
  }

  void openPaymentLink() async {
    if (paymentLink != null && await canLaunchUrlString(paymentLink!)) {
      await launchUrlString(paymentLink!);
    }
  }

  bool showVerificationCode = false;

  void toggleVerificationCode() {
    showVerificationCode = !showVerificationCode;
    notifyListeners();
  }

  void openPropertyDetails() async {
    if (order.bookingOrder?.property != null) {
      setBusy(true);
      try {
        final property = await PropertyRequest().getPropertyDetails(
          order.bookingOrder!.property!.id,
        );
        setBusy(false);
        viewContext.push((context) => PropertyDetailsPage(property: property));
      } catch (e) {
        setBusy(false);
        toastError(e.toString());
      }
    }
  }

  void callHost() async {
    final phone = order.vendor?.phone ?? "";
    if (phone.isNotEmpty && await canLaunchUrlString("tel:$phone")) {
      await launchUrlString("tel:$phone");
    }
  }

  bool get canShowVerificationCode {
    return [
      "pending",
      "preparing",
      "ready",
      "enroute",
      "confirmed",
      "awaiting_host_approval",
      "checkin",
      "checkout",
    ].contains(order.status);
  }

  bool get showPayButton {
    return order.paymentStatus == "pending" &&
        !["cancelled", "failed", "rejected"].contains(order.status);
  }

  processOrderCancel() async {
    setBusy(true);
    try {
      await PropertyRequest().cancelBooking(id: order.id, reason: "");
      setBusy(false);
      toastSuccessful("Booking cancelled successfully");
      fetchOrderDetails();
    } catch (e) {
      setBusy(false);
      toastError(e.toString());
    }
  }
}
