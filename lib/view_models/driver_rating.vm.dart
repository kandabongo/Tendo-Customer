import 'package:flutter/material.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DriverRatingViewModel extends MyBaseViewModel {
  //
  VendorRequest vendorRequest = VendorRequest();
  Order order;
  Function onSubmitted;
  int rating = 1;
  TextEditingController reviewTEC = TextEditingController();

  //
  DriverRatingViewModel(BuildContext context, this.order, this.onSubmitted) {
    this.viewContext = context;
  }

  void updateRating(String value) {
    rating = double.parse(value).ceil();
  }

  submitRating() async {
    setBusy(true);
    //
    final apiResponse = await vendorRequest.rateDriver(
      rating: rating,
      review: reviewTEC.text,
      orderId: order.id,
      driverId: order.driverId!,
    );
    setBusy(false);

    //
    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Driver Rating".tr(),
      text: apiResponse.message,
      onConfirm: apiResponse.allGood
          ? () {
              onSubmitted();
            }
          : null,
    );
  }
}
