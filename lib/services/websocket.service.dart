import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:singleton/singleton.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as PUSHER;

class WebsocketService {
  //
  static String websocketServerSettingsKey = "WebsocketServerSettings";

  /// Factory method that reuse same instance automatically
  factory WebsocketService() => Singleton.lazy(() => WebsocketService._());

  /// Private constructor
  WebsocketService._() {}

  //
  Echo<PUSHER.PusherClient, PusherChannel>? echoClient;
  Channel? publicChannel;
  PrivateChannel? privateChannel;

  //
  init() async {
    if (echoClient != null) {
      return;
    }

    try {
      String authBaseUrl = Api.baseUrl;
      if (authBaseUrl.endsWith("/api")) {
        authBaseUrl = authBaseUrl.substring(0, authBaseUrl.length - 4);
      }
      String wsHost = getWebsocketDetail("REVERB_HOST");
      String wsPort = getWebsocketDetail("REVERB_PORT");
      String wsAppKey = getWebsocketDetail("REVERB_APP_KEY");

      echoClient = Echo<PUSHER.PusherClient, PusherChannel>(
        PusherConnector(
          wsAppKey,
          authEndPoint: "$authBaseUrl/broadcasting/auth",
          authHeaders: () async {
            final userToken = await AuthServices.getAuthBearerToken();
            return {'Authorization': 'Bearer $userToken'};
          },
          host: wsHost,
          wsPort: wsPort.toInt(),
          wssPort: wsPort.toInt(),
          encrypted: true,
          // activityTimeout: 25000,
          // pongTimeout: 30000,
          enableLogging: kDebugMode,
          autoConnect: true,
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  closeConnection() async {
    if (echoClient == null) {
      return;
    }

    //disconnect the cleint
    echoClient?.disconnect();
    echoClient = null;
  }

  //MISC.
  Future<bool> saveWebsocketDetails(
    Map<String, dynamic> websocketSettings,
  ) async {
    return await LocalStorageService.prefs!.setString(
      websocketServerSettingsKey,
      jsonEncode(websocketSettings),
    );
  }

  String getWebsocketDetail(String key) {
    dynamic websocketSettings = LocalStorageService.prefs!.getString(
      websocketServerSettingsKey,
    );

    if (websocketSettings != null) {
      return jsonDecode(websocketSettings)[key] ?? "";
    }
    return "";
  }
}
