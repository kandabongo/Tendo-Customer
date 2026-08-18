import 'package:fuodz/services/websocket.service.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';

class OrderDriverLocationWebsocketService {
  static final OrderDriverLocationWebsocketService _instance =
      OrderDriverLocationWebsocketService._internal();
  factory OrderDriverLocationWebsocketService() => _instance;

  OrderDriverLocationWebsocketService._internal();

  PrivateChannel? _driverLocationChannel;
  String? _currentDriverId;
  Function(dynamic data)? _onLocationUpdated;
  Function? _onSubscribedSuccess;

  Future<void> connectToDriverLocationChannel(
    String driverId,
    Function(dynamic data) onLocationUpdated, {
    Function? onSubscribedSuccess,
  }) async {
    // Disconnect previous connection if it's a different driver
    if (_currentDriverId != null && _currentDriverId != driverId) {
      try {
        await disconnect();
      } catch (error) {
        print("Error Disconnecting ==> $error");
      }
    }

    await WebsocketService().init();

    _currentDriverId = driverId;
    _onLocationUpdated = onLocationUpdated;
    _onSubscribedSuccess = onSubscribedSuccess;

    _subscribeToChannel();

    final echo = WebsocketService().echoClient;
    if (echo == null) return;

    // Setup reconnect-related listeners
    echo.connector.onReconnecting((event) {
      print("WebSocket reconnecting...");
    });

    echo.connector.onDisconnect((event) {
      print("WebSocket disconnected.");
    });

    echo.connector.onError((error) {
      print("WebSocket error: $error");
    });

    // Workaround: try to re-subscribe after a short delay assuming reconnect success
    // You may tweak timing or hook this to an external ping/pong monitor if needed
    Future.delayed(Duration(seconds: 10), () {
      if (_currentDriverId != null) {
        print("Re-subscribing to driver channel: $_currentDriverId");
        _subscribeToChannel();
      }
    });
  }

  void _subscribeToChannel() {
    final echo = WebsocketService().echoClient;
    if (echo == null || _currentDriverId == null || _onLocationUpdated == null)
      return;

    _driverLocationChannel?.unsubscribe(); // Clean previous
    _driverLocationChannel = echo.private(
      "drivers.$_currentDriverId.location.updated",
    );
    _driverLocationChannel?.subscribe();
    _driverLocationChannel?.onSubscribedSuccess((args) {
      if (_onSubscribedSuccess != null) {
        _onSubscribedSuccess!();
      }
    });

    _driverLocationChannel?.listen(".LocationUpdated", (event) {
      print("Received LocationUpdated event: $event");
      _onLocationUpdated?.call(event);
    });
  }

  Future<void> disconnect() async {
    _driverLocationChannel?.unsubscribe();
    _driverLocationChannel = null;
    _currentDriverId = null;
    _onLocationUpdated = null;
    _onSubscribedSuccess = null;
  }
}
