import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/view_models/splash.vm.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import 'local_storage.service.dart';

class AuthServices {
  //
  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static bool get isLoggedIn => authenticated();

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.rxPrefs?.write(AppStrings.authenticated, true, (
      value,
    ) {
      return value;
    });
    return LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return LocalStorageService.prefs!.setString(
      AppStrings.userAuthToken,
      token,
    );
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale) ?? "en";
  }

  static Future<bool> setLocale(language) async {
    return LocalStorageService.prefs!.setString(AppStrings.appLocale, language);
  }

  static Stream<bool?> listenToAuthState() {
    return LocalStorageService.rxPrefs!.getBoolStream(AppStrings.authenticated);
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject = await LocalStorageService.prefs?.getString(
        AppStrings.userKey,
      );
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
    }
    return currentUser!;
  }

  ///
  ///
  ///
  static Future<User?> saveUser(
    dynamic jsonObject, {
    bool reload = true,
  }) async {
    final currentUser = User.fromJson(jsonObject);
    try {
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(currentUser.toJson()),
      );

      //subscribe to firebase topic
      List<String> roles = [
        "all",
        "${currentUser.id}",
        "${currentUser.role}",
        "client",
      ];

      //topic prefix
      final topicPrefix = AppStrings.firebasePrefix ?? "";

      for (var role in roles) {
        try {
          final topic = "$topicPrefix$role";
          FirebaseService().firebaseMessaging.subscribeToTopic(topic);
        } catch (error) {
          print("Unable to subscribe to:: $role");
        }
      }

      //log the new
      if (reload) {
        await SplashViewModel(
          AppService().navigatorKey.currentContext!,
        ).loadAppSettings();
      }

      return currentUser;
    } catch (error) {
      return null;
    }
  }

  ///
  ///
  //
  static Future<void> logout() async {
    await HttpService().getCacheManager().clearAll();
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.rxPrefs?.clear();
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);

    //
    List<String> roles = [
      "${currentUser?.id}",
      "${currentUser?.role}",
      "client",
      "all",
    ];
    for (var role in roles) {
      try {
        FirebaseService().firebaseMessaging.unsubscribeFromTopic(role);
      } catch (error) {
        print("Unable to unsubscribe to:: $role");
      }
    }
    await FirebaseAuth.instance.signOut();
  }
}
