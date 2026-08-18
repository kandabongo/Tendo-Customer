import 'package:flutter/material.dart';
import 'package:fuodz/views/pages/deep_link_loading.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:singleton/singleton.dart';

class AppService {
  //

  /// Factory method that reuse same instance automatically
  factory AppService() => Singleton.lazy(() => AppService._());

  /// Private constructor
  AppService._() {}

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  BehaviorSubject<bool> refreshAssignedOrders = BehaviorSubject<bool>();
  BehaviorSubject<bool> refreshWalletBalance = BehaviorSubject<bool>();
  int? vendorId;
  String? _pendingDeepLink;

  //
  changeHomePageIndex({int index = 2}) async {
    print("Changed Home Page");
    homePageIndex.add(index);
  }

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(translator.activeLocale.languageCode);
  }

  // Deep link handling methods
  void setPendingDeepLink(String route) {
    _pendingDeepLink = route;
  }

  String? getPendingDeepLink() {
    return _pendingDeepLink;
  }

  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  void handlePendingDeepLink() {
    if (_pendingDeepLink != null && navigatorKey.currentState != null) {
      final deepLinkData = _pendingDeepLink!;
      clearPendingDeepLink();

      // Parse the stored deep link data (format: "type/id")
      final parts = deepLinkData.split('/');
      if (parts.length == 2) {
        final type = parts[0];
        final id = parts[1];

        // Navigate to loading screen after a short delay to ensure home page is fully loaded
        Future.delayed(Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => DeepLinkLoadingPage(type: type, id: id),
            ),
          );
        });
      }
    }
  }
}
