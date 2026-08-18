import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';

extension NavigationExtensions on BuildContext {
  void pop([dynamic result]) {
    Navigator.of(this).pop(result);
  }

  Future<T?> push<T>(WidgetBuilder builder) {
    return Navigator.of(this).push(MaterialPageRoute(builder: builder));
  }

  //popUntilHome
  void popUntilHome() {
    //first or name: home
    Navigator.of(this).popUntil(
      (route) => route.isFirst || route.settings.name == AppRoutes.homeRoute,
    );
  }
}
