import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/general_app.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:fuodz/services/permission.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/websocket.service.dart';

class SetupService {
  static bool _isInitialized = false;

  /// Initialize all app services - call this on app startup
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      debugPrint('SetupService: Starting app initialization...');

      // Initialize services in order
      await _initializeNotifications();
      await _initializePhoneUtil();
      await _initializeFirebaseMessaging();
      await _initializeWebsocket();

      _isInitialized = true;
      debugPrint('SetupService: App initialization completed successfully');
    } catch (e) {
      debugPrint('SetupService: Error during initialization: $e');
      _isInitialized = true; // Mark as initialized even if some parts fail
    }
  }

  /// Initialize notification-related actions
  static Future<void> _initializeNotifications() async {
    try {
      debugPrint('SetupService: Initializing notifications...');

      // Initialize awesome notifications
      await NotificationService.initializeAwesomeNotification();

      // Clear irrelevant notification channels (Android only)
      await NotificationService.clearIrrelevantNotificationChannels();

      // Set up notification action listeners
      await NotificationService.listenToActions();

      debugPrint('SetupService: Notifications initialized successfully');
    } catch (e) {
      debugPrint('SetupService: Error initializing notifications: $e');
      rethrow;
    }
  }

  /// Initialize phone utility service
  static Future<void> _initializePhoneUtil() async {
    try {
      debugPrint('SetupService: Initializing phone utility...');
      await PhoneUtilService.init();
      debugPrint('SetupService: Phone utility initialized successfully');
    } catch (e) {
      debugPrint('SetupService: Error initializing phone utility: $e');
      rethrow;
    }
  }

  /// Initialize Firebase services
  static Future<void> _initializeFirebaseMessaging() async {
    try {
      debugPrint('SetupService: Initializing Firebase...');
      // Firebase initialization is typically handled in main.dart
      // This is a placeholder for any additional Firebase setup
      await FirebaseService().setUpFirebaseMessaging();
      //handle background notification
      FirebaseMessaging.onBackgroundMessage(
        GeneralAppService.onBackgroundMessageHandler,
      );
      debugPrint('SetupService: Firebase initialized successfully');
    } catch (e) {
      debugPrint('SetupService: Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Initialize the websocket connection so it's ready before any
  /// tracking page (order details, taxi trip) needs it.
  static Future<void> _initializeWebsocket() async {
    try {
      if (!AuthServices.authenticated()) return;

      debugPrint('SetupService: Initializing websocket...');
      await WebsocketService().init();
      debugPrint('SetupService: Websocket initialized successfully');
    } catch (e) {
      debugPrint('SetupService: Error initializing websocket: $e');
      // non-fatal: feature pages fall back to lazy WebsocketService().init()
    }
  }

  /// Initialize notification system specifically
  static Future<void> initNotifications() async {
    try {
      await _initializeNotifications();
    } catch (e) {
      debugPrint('SetupService: Failed to initialize notifications: $e');
    }
  }

  /// Request all necessary permissions
  static Future<void> requestPermissions() async {
    try {
      debugPrint('SetupService: Requesting permissions...');

      // Request location permissions if needed
      await PermissionService.requestPermission();

      debugPrint('SetupService: Permissions requested');
    } catch (e) {
      debugPrint('SetupService: Error requesting permissions: $e');
    }
  }

  /// Check if setup service is initialized
  static bool get isInitialized => _isInitialized;

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    debugPrint('SetupService: Reset initialization state');
  }

  /// Get initialization status for all services
  static Map<String, bool> getInitializationStatus() {
    return {
      'setupService': _isInitialized,
      'phoneUtil': PhoneUtilService.isInitialized,
    };
  }
}
