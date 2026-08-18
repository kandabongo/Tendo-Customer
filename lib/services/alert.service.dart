import 'dart:async';
// import 'package:cool_alert/cool_alert.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:velocity_x/velocity_x.dart';

class AlertService {
  //

  static Future<bool> showConfirm({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
    bool closeOnConfirmBtnTap = true,
    Function? onConfirm,
  }) async {
    //
    bool result = false;
    final context = AppService().navigatorKey.currentContext!;
    await QuickAlert.show(
      borderRadius: Sizes.radiusSmall,
      context: context,
      type: QuickAlertType.confirm,
      text: text,
      title: title,
      confirmBtnText: confirmBtnText.tr(),
      cancelBtnText: cancelBtnText.tr(),
      confirmBtnColor: AppColor.primaryColor,
      onConfirmBtnTap: () {
        AppService().navigatorKey.currentContext?.pop();
        if (onConfirm == null) {
          result = true;
        } else {
          onConfirm();
        }
      },
    );

    // await CoolAlert.show(
    //   confirmBtnColor: AppColor.primaryColor,
    //   context: context,
    //   type: CoolAlertType.confirm,
    //   animType: CoolAlertAnimType.slideInDown,
    //   title: title,
    //   text: text,
    //   cancelBtnText: cancelBtnText.tr(),
    //   confirmBtnText: confirmBtnText.tr(),
    //   closeOnConfirmBtnTap: closeOnConfirmBtnTap,
    //   onConfirmBtnTap: () {
    //     if (onConfirm == null) {
    //       result = true;
    //       AppService().navigatorKey.currentContext?.pop();
    //     } else {
    //       onConfirm();
    //     }
    //   },
    // );

    //
    return result;
  }

  static Future<bool> confirm({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
    Function? onConfirm,
  }) async {
    return await showConfirm(
      title: title,
      text: text,
      cancelBtnText: cancelBtnText,
      confirmBtnText: confirmBtnText,
      onConfirm: onConfirm,
    );
  }

  static Future<bool> success({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
    bool barrierDismissible = true,
    bool closeOnConfirmBtnTap = true,
    Function? onConfirm,
    result,
  }) async {
    //
    bool result = false;
    await QuickAlert.show(
      context: AppService().navigatorKey.currentContext!,
      type: QuickAlertType.success,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      cancelBtnText: cancelBtnText.tr(),
      onConfirmBtnTap: () {
        // if (!closeOnConfirmBtnTap) {
        AppService().navigatorKey.currentContext?.pop(result);
        // }
        result = true;
        if (onConfirm != null) {
          onConfirm();
        }
      },
    );

    // await CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type: CoolAlertType.success,
    //   title: title,
    //   text: text,
    //   confirmBtnText: confirmBtnText.tr(),
    //   cancelBtnText: cancelBtnText.tr(),
    //   closeOnConfirmBtnTap: closeOnConfirmBtnTap,
    //   onConfirmBtnTap: () {
    //     result = true;
    //     if (onConfirm != null) {
    //       onConfirm();
    //     }
    //     if (!closeOnConfirmBtnTap) {
    //       AppService().navigatorKey.currentContext?.pop();
    //     }
    //   },
    // );

    //
    return result;
  }

  static Future<bool> error({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
    Function? onConfirm,
  }) async {
    //
    bool result = false;
    final context = AppService().navigatorKey.currentContext!;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: onConfirm != null
          ? () {
              result = true;
              AppService().navigatorKey.currentContext?.pop();
              onConfirm();
            }
          : null,
    );
    // await CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type: CoolAlertType.error,
    //   title: title,
    //   text: text,
    //   confirmBtnText: confirmBtnText.tr(),
    //   closeOnConfirmBtnTap: onConfirm == null,
    //   onConfirmBtnTap: onConfirm != null
    //       ? () {
    //           result = true;
    //           AppService().navigatorKey.currentContext?.pop();
    //           onConfirm();
    //         }
    //       : null,
    // );

    //
    return result;
  }

  static Future<bool> warning({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
    Function? onConfirm,
  }) async {
    //
    bool result = false;
    final context = AppService().navigatorKey.currentContext!;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: onConfirm != null
          ? () {
              result = true;
              AppService().navigatorKey.currentContext?.pop();
              onConfirm();
            }
          : null,
    );
    // await CoolAlert.show(
    //     context: AppService().navigatorKey.currentContext!,
    //     type: CoolAlertType.warning,
    //     title: title,
    //     text: text,
    //     confirmBtnText: confirmBtnText.tr(),
    //     closeOnConfirmBtnTap: false,
    //     onConfirmBtnTap: () {
    //       result = true;
    //       AppService().navigatorKey.currentContext?.pop();
    //     });

    //
    return result;
  }

  static Future<bool> custom({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
    String? cancelBtnText = "Cancel",
    AlertType? type,
    Function? onConfirm,
    TextStyle? confirmBtnTextStyle,
    TextStyle? cancelBtnTextStyle,
    String? customAsset,
  }) async {
    bool result = false;
    final context = AppService().navigatorKey.currentContext!;
    await QuickAlert.show(
      context: context,
      type: type != null
          ? QuickAlertType.values[type.index]
          : QuickAlertType.info,
      title: title,
      text: text,
      titleColor: context.textTheme.bodyLarge!.color!,
      textColor: context.textTheme.bodyLarge!.color!,
      backgroundColor: context.theme.dialogBackgroundColor,
      confirmBtnColor: AppColor.primaryColor,
      confirmBtnText: confirmBtnText.tr(),
      showCancelBtn: ((cancelBtnText ?? "").tr()).isNotEmpty,
      cancelBtnText: (cancelBtnText ?? "").tr(),
      confirmBtnTextStyle: confirmBtnTextStyle,
      cancelBtnTextStyle: cancelBtnTextStyle,
      customAsset: customAsset,
      width: context.percentWidth * 90,
      onConfirmBtnTap: onConfirm != null
          ? () {
              result = true;
              AppService().navigatorKey.currentContext?.pop();
              onConfirm();
            }
          : null,
    );
    // await CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type:
    //       type != null ? CoolAlertType.values[type.index] : CoolAlertType.info,
    //   title: title,
    //   text: text,
    //   confirmBtnText: confirmBtnText.tr(),
    //   cancelBtnText: (cancelBtnText ?? "").tr(),
    //   closeOnConfirmBtnTap: onConfirm == null,
    //   confirmBtnTextStyle: confirmBtnTextStyle,
    //   cancelBtnTextStyle: cancelBtnTextStyle,
    //   onConfirmBtnTap: onConfirm != null
    //       ? () {
    //           result = true;
    //           AppService().navigatorKey.currentContext?.pop();
    //           onConfirm();
    //         }
    //       : null,
    // );

    //
    return result;
  }

  static Future<bool> dynamic({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
    String? cancelBtnText = "Close",
    AlertType? type,
    Function? onConfirm,
  }) async {
    //
    bool result = false;
    await QuickAlert.show(
      context: AppService().navigatorKey.currentContext!,
      type: type != null
          ? QuickAlertType.values[type.index]
          : QuickAlertType.info,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      cancelBtnText: (cancelBtnText ?? "").tr(),
      onConfirmBtnTap: onConfirm != null
          ? () {
              result = true;
              AppService().navigatorKey.currentContext?.pop();
              onConfirm();
            }
          : null,
    );
    // await CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type: type ?? CoolAlertType.info,
    //   title: title,
    //   text: text,
    //   confirmBtnText: confirmBtnText.tr(),
    //   closeOnConfirmBtnTap: false,
    //   onConfirmBtnTap: () {
    //     result = true;
    //     AppService().navigatorKey.currentContext?.pop();
    //   },
    // );

    //
    return result;
  }

  static void showLoading() {
    QuickAlert.show(
      context: AppService().navigatorKey.currentContext!,
      type: QuickAlertType.loading,
      title: '',
      text: "Processing. Please wait...".tr(),
    );

    // CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type: CoolAlertType.loading,
    //   title: "".tr(),
    //   text: "Processing. Please wait...".tr(),
    //   barrierDismissible: false,
    // );
  }

  static void loading({
    bool barrierDismissible = false,
    String? title,
    String? text,
  }) {
    QuickAlert.show(
      context: AppService().navigatorKey.currentContext!,
      type: QuickAlertType.loading,
      title: '',
      text: "Processing. Please wait...".tr(),
    );

    // CoolAlert.show(
    //   context: AppService().navigatorKey.currentContext!,
    //   type: CoolAlertType.loading,
    //   title: "".tr(),
    //   text: "Processing. Please wait...".tr(),
    //   barrierDismissible: false,
    // );
  }

  static void stopLoading() {
    AppService().navigatorKey.currentContext?.pop();
  }
}

// enums
// enum AlertType { success, error, warning, confirm, info, loading, custom }
enum AlertType { success, error, warning, confirm, info, loading, custom }
