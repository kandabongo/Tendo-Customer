import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_file_limit.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/checkout_base.vm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class PharmacyUploadPrescriptionViewModel extends CheckoutBaseViewModel {
  //
  PharmacyUploadPrescriptionViewModel(BuildContext context, this.vendor) {
    this.viewContext = context;
    this.checkout = CheckOut(subTotal: 0.00);
    this.canSelectPaymentOption = true;
  }

  //
  VendorRequest vendorRequest = VendorRequest();
  Vendor? vendor;
  final picker = ImagePicker();
  List<File> prescriptionPhotos = [];

  void initialise() async {
    calculateTotal = false;
    super.initialise();
  }

  //
  fetchVendorDetails() async {
    //
    setBusyForObject(vendor, true);
    try {
      vendor = await vendorRequest.vendorDetails(vendor!.id);
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(vendor, false);
  }

  //
  void changePhoto() async {
    //End of permission check
    //
    final pickedFiles = await picker.pickMultiImage();
    if (prescriptionPhotos.isNotEmpty) {
      prescriptionPhotos.addAll(pickedFiles.map((e) => File(e.path)).toList());
    } else {
      prescriptionPhotos = pickedFiles.map((e) => File(e.path)).toList();
    }

    //
    if (prescriptionPhotos.length > AppFileLimit.prescriptionFileLimit) {
      prescriptionPhotos = prescriptionPhotos.sublist(
        0,
        AppFileLimit.prescriptionFileLimit,
      );
      //
      AlertService.warning(
        title: "Prescription".tr(),
        text: "You can only upload %s prescription at a time".tr().fill([
          AppFileLimit.prescriptionFileLimit,
        ]),
      );
    }
    //
    notifyListeners();
  }

  void removePhoto(int index) {
    prescriptionPhotos.removeAt(index);
    //refresh list to have new index
    prescriptionPhotos = prescriptionPhotos.toList();
    notifyListeners();
  }

  //
  placeOrder({bool ignore = false}) async {
    //
    if (!isPickup && deliveryAddress == null) {
      //
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Please select delivery address".tr(),
      );
    } else if (delievryAddressOutOfRange && !isPickup) {
      //
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Delivery address is out of vendor delivery range".tr(),
      );
    } else if (prescriptionPhotos.isEmpty) {
      //
      AlertService.error(
        title: "Prescription".tr(),
        text: "Please upload prescription".tr(),
      );
    }
    //process the new order
    else {
      processOrderPlacement();
    }
  }

  //
  processOrderPlacement() async {
    setBusy(true);

    try {
      //set the total with discount as the new total
      checkout!.total = checkout!.totalWithTip;
      //
      final apiResponse = await checkoutRequest.newPrescriptionOrder(
        checkout!,
        vendor!,
        photos: prescriptionPhotos,
        note: noteTEC.text,
        idempotencyKey: orderIdempotencyKey,
      );
      resetOrderIdempotencyKey();
      //not error
      if (apiResponse.allGood) {
        //cash payment

        final paymentLink = "";
        // apiResponse.body["link"].toString();
        if (!paymentLink.isEmptyOrNull) {
          viewContext.pop();
          showOrdersTab(context: viewContext);
          openWebpageLink(paymentLink);
        }
        //cash payment
        else {
          await AlertService.success(
            title: "Checkout".tr(),
            text: apiResponse.message,
            barrierDismissible: false,
            // onConfirm: () {

            //   // if (Navigator.of(viewContext).canPop()) {
            //   //   viewContext.pop();
            //   // }
            // },
          );
          showOrdersTab(context: viewContext);
        }
      } else {
        AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
      }
    } catch (error) {
      resetOrderIdempotencyKey();
      toastError("$error");
    }
    setBusy(false);
  }
}
