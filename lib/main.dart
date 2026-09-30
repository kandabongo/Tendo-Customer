import 'dart:async';
import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/cache.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/deep_link.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      //Forces Hybrid Composition for the Android GoogleMap platform view
      //instead of the default texture-based rendering. Some devices/GPU
      //drivers (MediaTek-based budget phones especially) hit a
      //BLASTBufferQueue buffer-acquisition stall with the default mode,
      //leaving the map tiles permanently blank while the rest of the
      //screen still works.
      final mapsImplementation = GoogleMapsFlutterPlatform.instance;
      if (mapsImplementation is GoogleMapsFlutterAndroid) {
        mapsImplementation.useAndroidViewSurface = true;
      }
      //setting up firebase notifications
      await Firebase.initializeApp();
      //App Check: debug builds use the debug provider (its token must be
      //registered once in Firebase Console -> App Check -> Manage debug
      //tokens); release builds use Play Integrity, matching the app's
      //actual signing key registered with Play/Firebase. Activating this
      //explicitly - previously neither provider was configured at all, so
      //release builds only passed via Firebase Auth's own implicit
      //Play Integrity fallback, and debug builds had no fallback whatsoever.
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
      await PhoneUtilService.init();

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      //
      await LocalStorageService.getPrefs();
      await CartServices.getCartItems();
      await CacheService.init();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      //setting up crashlytics only for production
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Initialize deep link handling
      DeepLinkService().initialize();

      //font
      GoogleFonts.pendingFonts([GoogleFonts.plusJakartaSans()]);
      // Run app!
      runApp(LocalizedApp(child: MyApp()));
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
