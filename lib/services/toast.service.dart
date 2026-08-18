import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ToastService {
  //
  //show toast
  static toastSuccessful(String msg, {String? title}) {
    try {
      AlertController.show(
        title ?? "Successful".tr(),
        msg,
        TypeAlert.success,
      );
    } catch (error) {
      AlertService.success(
        title: title ?? "Successful".tr(),
        text: msg,
      );
    }
  }

  static toastError(String msg, {String? title}) {
    try {
      AlertController.show(
        title ?? "Error".tr(),
        msg,
        TypeAlert.error,
      );
    } catch (error) {
      AlertService.error(
        title: title ?? "Error".tr(),
        text: msg,
      );
    }
  }
}
