import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/requests/delivery_address.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DeliveryAddressesViewModel extends MyBaseViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  List<DeliveryAddress> deliveryAddresses = [];

  //
  DeliveryAddressesViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  void initialise() {
    //
    fetchDeliveryAddresses();
  }

  //
  fetchDeliveryAddresses() async {
    //
    setBusyForObject(deliveryAddresses, true);
    try {
      deliveryAddresses = await deliveryAddressRequest.getDeliveryAddresses();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusyForObject(deliveryAddresses, false);
  }

  //
  newDeliveryAddressPressed() async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.newDeliveryAddressesRoute,
    );
    fetchDeliveryAddresses();
  }

  //
  editDeliveryAddress(DeliveryAddress deliveryAddress) async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.editDeliveryAddressesRoute,
      arguments: deliveryAddress,
    );
    fetchDeliveryAddresses();
  }

  //
  deleteDeliveryAddress(DeliveryAddress deliveryAddress) {
    //
    AlertService.confirm(
      title: "Delete Delivery Address".tr(),
      text: "Are you sure you want to delete this delivery address?".tr(),
      confirmBtnText: "Delete".tr(),
      onConfirm: () {
        processDeliveryAddressDeletion(deliveryAddress);
      },
    );
  }

  //
  processDeliveryAddressDeletion(DeliveryAddress deliveryAddress) async {
    setBusy(true);
    //
    final apiResponse = await deliveryAddressRequest.deleteDeliveryAddress(
      deliveryAddress,
    );

    //remove from list
    if (apiResponse.allGood) {
      deliveryAddresses.remove(deliveryAddress);
    }

    setBusy(false);

    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Delete Delivery Address".tr(),
      text: apiResponse.message,
    );
  }
}
