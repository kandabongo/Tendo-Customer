import 'package:fuodz/services/websocket.service.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';

class OrderDetailsWebsocketService {
  static final OrderDetailsWebsocketService _instance =
      OrderDetailsWebsocketService._internal();
  factory OrderDetailsWebsocketService() => _instance;

  OrderDetailsWebsocketService._internal();

  PrivateChannel? _orderChannel;
  String? _currentOrderId;
  Function(dynamic data)? _onOrderUpdated;

  Future<void> connectToOrderChannel(
    String orderId,
    Function(dynamic data) onOrderUpdated,
  ) async {
    // Disconnect previous connection if it's a different order
    if (_currentOrderId != null && _currentOrderId != orderId) {
      try {
        await disconnect();
      } catch (error) {
        print("Error Disconnecting ==> $error");
      }
    }

    await WebsocketService().init();

    _currentOrderId = orderId;
    _onOrderUpdated = onOrderUpdated;

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
    Future.delayed(Duration(seconds: 3), () {
      if (_currentOrderId != null) {
        print("Re-subscribing to order channel: $_currentOrderId");
        _subscribeToChannel();
      }
    });
  }

  void _subscribeToChannel() {
    final echo = WebsocketService().echoClient;
    if (echo == null || _currentOrderId == null || _onOrderUpdated == null)
      return;

    _orderChannel?.unsubscribe(); // Clean previous
    _orderChannel = echo.private("orders.updated.$_currentOrderId");
    _orderChannel?.subscribe();
    _orderChannel?.listen(".OrderUpdated", (event) {
      print("Received OrderUpdated event: $event");
      _onOrderUpdated?.call(event);
    });
  }

  Future<void> disconnect() async {
    _orderChannel?.unsubscribe();
    _orderChannel = null;
    _currentOrderId = null;
    _onOrderUpdated = null;
  }
}
