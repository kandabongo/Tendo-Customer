import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_fee.dart';
import 'package:fuodz/views/pages/booking/property_booking_details.page.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/booking/widgets/property_booking_date_selection.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class PropertyBookingSummaryViewModel extends MyBaseViewModel {
  PropertyBookingSummaryViewModel(
    BuildContext context,
    this.property,
    this.selectedDateRange,
    this.totalPrice,
  ) {
    this.viewContext = context;
  }

  final Property property;
  DateTimeRange selectedDateRange;
  double totalPrice;

  // Guests
  int adults = 1;
  int children = 0;
  int infants = 0;
  int pets = 0;

  // Payment
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;

  // Fees
  double subTotal = 0.0;
  double totalFees = 0.0;
  List<PropertyFee> applicableFees = [];

  void initialise() {
    generateSummaryInfo();
    fetchPaymentMethods();
  }

  void generateSummaryInfo() {
    calculateTotal();
  }

  void calculateTotal() {
    int nights = selectedDateRange.duration.inDays;
    subTotal = property.price * nights;

    // Fees
    applicableFees = property.activeFees;
    totalFees = 0.0;
    for (var fee in applicableFees) {
      if (fee.bookingFeeType != null) {
        if (fee.bookingFeeType!.isPercentage) {
          totalFees += (subTotal * (fee.amount / 100));
        } else {
          totalFees += fee.amount;
        }
      }
    }

    totalPrice = subTotal + totalFees;
    notifyListeners();
  }

  void fetchPaymentMethods() async {
    setBusy(true);
    try {
      final response = await HttpService().get(Api.paymentMethods);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["data"];
        paymentMethods =
            data
                .map((e) => PaymentMethod.fromJson(e))
                .where((e) => e.slug != "cash" || e.isCash == 0) // No Cash
                .toList();
      }
    } catch (e) {
      print("Error fetching payment methods: $e");
    }
    setBusy(false);
  }

  void selectPaymentMethod(PaymentMethod? method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void updateGuestCount({
    int? newAdults,
    int? newChildren,
    int? newInfants,
    int? newPets,
  }) {
    // Validate Max Guests
    int totalGuests = (newAdults ?? adults) + (newChildren ?? children);
    if (totalGuests > property.maxGuests) {
      toastError("Max guests allowed is ${property.maxGuests}".tr());
      return;
    }

    if (newAdults != null) adults = newAdults;
    if (newChildren != null) children = newChildren;
    if (newInfants != null) infants = newInfants;
    if (newPets != null) pets = newPets;
    notifyListeners();
  }

  void placeOrder() async {
    if (selectedPaymentMethod == null) {
      toastError("Please select a payment method".tr());
      return;
    }

    setBusy(true);
    try {
      final apiResponse = await PropertyRequest().bookProperty(
        propertyId: property.id,
        selectedDateRange: selectedDateRange,
        totalPrice: totalPrice,
        paymentMethodId: selectedPaymentMethod!.id,
        adults: adults,
        children: children,
        infants: infants,
        pets: pets,
      );
      if (apiResponse.allGood) {
        setBusy(false);
        await AlertService.success(
          title: "Booking placed successfully".tr(),
          text: "Your booking has been placed successfully".tr(),
        );
        final order = Order.fromJson(apiResponse.body["order"]);
        String? paymentLink = apiResponse.body["payment_link"];
        //pop until home, then push to booking details
        viewContext.popUntilHome();
        AppService().navigatorKey.currentContext!.push(
          (context) =>
              PropertyBookingDetailsPage(order, paymentLink: paymentLink),
        );
        return;
      } else {
        AlertService.error(
          title: "Error placing order".tr(),
          text: apiResponse.message,
        );
      }
    } catch (e) {
      AlertService.error(title: "Error placing order".tr(), text: e.toString());
    }
    setBusy(false);
  }

  void openBookingDateSelection() async {
    final result = await viewContext.push(
      (context) => PropertyBookingDateSectionPage(
        preselectedDateRange: selectedDateRange,
        property: property,
      ),
    );
    if (result != null && result is DateTimeRange) {
      selectedDateRange = result;
      calculateTotal();
    }
  }
}
