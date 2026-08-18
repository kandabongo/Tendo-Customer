import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:supercharged/supercharged.dart';

class AppUIStyles extends AppStrings {
  //
  static int themeUIStyle() {
    dynamic uiEnv = AppStrings.env("ui");
    if (uiEnv == null ||
        uiEnv["home"] == null ||
        uiEnv['home']["homeViewStyle"] == null) {
      return 1;
    }
    return (uiEnv['home']["homeViewStyle"].toString().toInt()) ?? 1;
  }

  static bool get isModern => themeUIStyle() == 2;
  static bool get isOriginal => [1, null].contains(themeUIStyle());

  //vendor type sizes
  static double get vendorTypeWidth {
    try {
      dynamic uiEnv = AppStrings.env("ui");
      if (uiEnv == null ||
          uiEnv["home"] == null ||
          uiEnv['home']["vendortypeWidth"] == null) {
        return double.infinity;
      }
      return double.tryParse(uiEnv['home']["vendortypeWidth"].toString()) ??
          double.infinity;
    } catch (e) {
      print(e);
      return double.infinity;
    }
  }

  static double get vendorTypeHeight {
    try {
      dynamic uiEnv = AppStrings.env("ui");
      if (uiEnv == null ||
          uiEnv["home"] == null ||
          uiEnv['home']["vendortypeHeight"] == null) {
        return 60;
      }
      return (uiEnv['home']["vendortypeHeight"].toString().toDouble()) ?? 60;
    } catch (e) {
      print(e);
      return 60;
    }
  }

  static double? get vendortypePercentageHeight {
    try {
      dynamic uiEnv = AppStrings.env("ui");
      if (uiEnv == null ||
          uiEnv["home"] == null ||
          uiEnv['home']["vendortypePercentageHeight"] == null) {
        return null;
      }
      return (uiEnv['home']["vendortypePercentageHeight"]
              .toString()
              .toDouble()) ??
          null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static double? get vendortypePercentageWidth {
    try {
      dynamic uiEnv = AppStrings.env("ui");
      if (uiEnv == null ||
          uiEnv["home"] == null ||
          uiEnv['home']["vendortypePercentageWidth"] == null) {
        return null;
      }
      return double.tryParse(
            uiEnv['home']["vendortypePercentageWidth"].toString(),
          ) ??
          null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static bool get moduleTitleOnly {
    dynamic uiEnv = AppStrings.env("ui");
    if (uiEnv == null ||
        uiEnv["home"] == null ||
        uiEnv['home']["vendortypeTitleOnly"] == null) {
      return false;
    }
    final value = uiEnv['home']["vendortypeTitleOnly"] ?? 0;
    return value is bool ? value : value.toString().toInt() == 1;
  }

  static bool get moduleCircleItemStyle {
    dynamic uiEnv = AppStrings.env("ui");
    if (uiEnv == null ||
        uiEnv["home"] == null ||
        uiEnv['home']["vendortypeItemStyle"] == null) {
      return false;
    }
    final value = uiEnv['home']["vendortypeItemStyle"] ?? "normal";
    return value == "circle";
  }

  static BoxFit get vendorTypeImageStyle {
    dynamic uiEnv = AppStrings.env("ui");
    if (uiEnv == null ||
        uiEnv["home"] == null ||
        uiEnv['home']["vendortypeImageStyle"] == null) {
      return BoxFit.cover;
    }

    //
    BoxFit boxFit = BoxFit.cover;

    switch (uiEnv['home']["vendortypeImageStyle"].toString()) {
      case "center":
        boxFit = BoxFit.contain;
        break;
      case "contain":
        boxFit = BoxFit.contain;
        break;
      case "cover":
        boxFit = BoxFit.cover;
        break;
      case "fill":
        boxFit = BoxFit.fill;
        break;
      case "none":
        boxFit = BoxFit.none;
        break;
      case "scaleDown":
        boxFit = BoxFit.scaleDown;
        break;
      default:
        return BoxFit.cover;
    }

    return boxFit;
  }
}
