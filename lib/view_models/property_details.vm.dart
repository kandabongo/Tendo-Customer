import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/booking/property_chat.page.dart';
import 'package:fuodz/views/pages/booking/report_property_listing.page.dart';
import 'package:fuodz/views/pages/booking/property_booking_summary.page.dart';
import 'package:fuodz/views/pages/booking/widgets/property_booking_date_selection.page.dart';
import 'package:fuodz/views/pages/booking/widgets/property_booking_price_details.modal.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PropertyDetailsViewModel extends MyBaseViewModel {
  PropertyDetailsViewModel(BuildContext context, this.property) {
    this.viewContext = context;
  }

  Property property;
  PropertyRequest _propertyRequest = PropertyRequest();
  RefreshController refreshController = RefreshController();
  bool showAllAmenities = false;
  DateTimeRange? selectedDateRange;
  double totalPrice = 0;

  void initialise() {
    getPropertyDetails();
  }

  void getPropertyDetails() async {
    setBusy(true);
    try {
      property = await _propertyRequest.getPropertyDetails(property.id);
      //generate the selected date range
      selectedDateRange = DateTimeRange(
        start: property.availableFrom!,
        end: property.availableTo!,
      );
      generateTotalPrice();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  int get nights => selectedDateRange?.duration.inDays ?? 1;

  void toggleShowAllAmenities() {
    showAllAmenities = !showAllAmenities;
    notifyListeners();
  }

  void reportListing() {
    //go to login page it user is not logged in
    if (!AuthServices.isLoggedIn) {
      openLogin();
      return;
    }

    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => ReportPropertyListingPage(property: property),
      ),
    );
  }

  void openChatWithHost(BuildContext context) {
    //go to login page it user is not logged in
    if (!AuthServices.isLoggedIn) {
      openLogin();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PropertyChatPage(property: property);
        },
      ),
    );
  }

  void generateTotalPrice() {
    if (selectedDateRange == null) {
      totalPrice = property.price;
    } else {
      int duration = selectedDateRange!.duration.inDays;
      totalPrice = property.price * duration;
    }
    notifyListeners();
  }

  void openPropertyBookingPriceDetailsModal() async {
    final result = await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return PropertyBookingPriceDetailsModal(model: this);
      },
    );

    if (result != null) {
      processBooking();
    }
  }

  void openPropertyBookingDateSectionPage() async {
    final result = await Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) {
          return PropertyBookingDateSectionPage(
            preselectedDateRange: selectedDateRange,
            property: property,
          );
        },
      ),
    );

    if (result != null && result is DateTimeRange) {
      selectedDateRange = result;
      generateTotalPrice();
    }
  }

  //MISC.
  void processBooking() {
    //go to login page it user is not logged in
    if (!AuthServices.isLoggedIn) {
      openLogin();
      return;
    }

    //open booking summary page
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) {
          return PropertyBookingSummaryPage(
            property: property,
            selectedDateRange: selectedDateRange!,
            totalPrice: totalPrice,
          );
        },
      ),
    );
  }
}
