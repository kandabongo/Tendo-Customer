import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/requests/product.request.dart';
import 'package:fuodz/requests/service.request.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/chat.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/views/pages/home.page.dart';
import 'package:fuodz/views/pages/service/service_details.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:singleton/singleton.dart';

import 'firebase_token.service.dart';

class FirebaseService {
  //
  /// Factory method that reuse same instance automatically
  factory FirebaseService() => Singleton.lazy(() => FirebaseService._());

  /// Private constructor
  FirebaseService._() {}

  //
  NotificationModel? notificationModel;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Map? notificationPayloadData;

  setUpFirebaseMessaging() async {
    //Request for notification permission
    /*NotificationSettings settings = */
    bool isPermanentlyDenied =
        await Permission.notification.isPermanentlyDenied;
    if (isPermanentlyDenied) {
      return;
    }
    bool isGranted = await Permission.notification.isGranted;
    if (!isGranted) {
      return;
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    //subscribing to all topic
    final topicPrefix = AppStrings.firebasePrefix ?? "";
    final allTopic = "${topicPrefix}all";
    firebaseMessaging.subscribeToTopic(allTopic);
    //
    FirebaseTokenService().handleDeviceTokenSync();

    //on notification tap tp bring app back to life
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      saveNewNotification(message);
      selectNotification("From onMessageOpenedApp");
      //
      refreshOrdersList(message);
    });

    //normal notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      saveNewNotification(message);
      showNotification(message);
      //
      refreshOrdersList(message);
    });
  }

  //write to notification list
  saveNewNotification(RemoteMessage? message, {String? title, String? body}) {
    //
    notificationPayloadData = message != null ? message.data : null;
    if (message?.notification == null &&
        message?.data["title"] == null &&
        title == null) {
      return;
    }
    //Saving the notification
    notificationModel = NotificationModel();
    notificationModel!.title =
        message?.notification?.title ?? title ?? message?.data["title"] ?? "";
    notificationModel!.body =
        message?.notification?.body ?? body ?? message?.data["body"] ?? "";
    //

    final imageUrl =
        message?.data["image"] ??
        (Platform.isAndroid
            ? message?.notification?.android?.imageUrl
            : message?.notification?.apple?.imageUrl);
    notificationModel!.image = imageUrl;

    //
    notificationModel!.timeStamp = DateTime.now().millisecondsSinceEpoch;

    //add to database/shared pref
    NotificationService.addNotification(notificationModel!);
  }

  //
  showNotification(RemoteMessage message) async {
    if (message.notification == null && message.data["title"] == null) {
      return;
    }

    //
    notificationPayloadData = message.data;

    //
    try {
      //
      String? imageUrl;

      try {
        imageUrl =
            message.data["image"] ??
            (Platform.isAndroid
                ? message.notification?.android?.imageUrl
                : message.notification?.apple?.imageUrl);
      } catch (error) {
        print("error getting notification image");
      }

      //
      if (imageUrl != null) {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            bigPicture: imageUrl,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.BigPicture,
            payload: Map<String, String>.from(message.data),
          ),
        );
      } else {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.Default,
            payload: Map<String, String>.from(message.data),
          ),
        );
      }

      ///
    } catch (error) {
      print("Notification Show error ===> ${error}");
    }
  }

  //handle on notification selected
  Future selectNotification(String? payload) async {
    if (payload == null) {
      return;
    }
    try {
      log("NotificationPaylod ==> ${jsonEncode(notificationPayloadData)}");
      //
      if (notificationPayloadData != null && notificationPayloadData is Map) {
        //

        //
        final isChat = notificationPayloadData!.containsKey("is_chat");
        final isOrder =
            notificationPayloadData!.containsKey("is_order") &&
            (notificationPayloadData?["is_order"].toString() == "1" ||
                (notificationPayloadData?["is_order"] is bool &&
                    notificationPayloadData?["is_order"]));

        ///
        final hasProduct = notificationPayloadData!.containsKey("product");
        final hasVendor = notificationPayloadData!.containsKey("vendor");
        final hasService = notificationPayloadData!.containsKey("service");
        //
        if (isChat) {
          //
          dynamic user = jsonDecode(notificationPayloadData!['user']);
          dynamic peer = jsonDecode(notificationPayloadData!['peer']);
          String chatPath = notificationPayloadData!['path'];
          //
          Map<String, PeerUser> peers = {
            '${user['id']}': PeerUser(
              id: '${user['id']}',
              name: "${user['name']}",
              image: "${user['photo']}",
            ),
            '${peer['id']}': PeerUser(
              id: '${peer['id']}',
              name: "${peer['name']}",
              image: "${peer['photo']}",
            ),
          };
          //
          final peerRole = peer["role"];
          //
          final chatEntity = ChatEntity(
            onMessageSent: ChatService.sendChatMessage,
            mainUser: peers['${user['id']}']!,
            peers: peers,
            //don't translate this
            path: chatPath,
            title:
                peer["role"] == null
                    ? "Chat with".tr() + " ${peer['name']}"
                    : peerRole == 'vendor'
                    ? "Chat with vendor".tr()
                    : "Chat with driver".tr(),
            supportMedia: AppUISettings.canCustomerChatSupportMedia,
          );
          //
          Navigator.of(
            AppService().navigatorKey.currentContext!,
          ).pushNamed(AppRoutes.chatRoute, arguments: chatEntity);
        }
        //order
        else if (isOrder) {
          //
          try {
            //fetch order from api
            int orderId = int.parse("${notificationPayloadData!['order_id']}");
            Order order = await OrderRequest().getOrderDetails(id: orderId);
            //
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.orderDetailsRoute, arguments: order);
          } catch (error) {
            //navigate to orders page
            await Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).push(MaterialPageRoute(builder: (_) => HomePage()));
            //then switch to orders tab
            AppService().changeHomePageIndex();
          }
        }
        //vendor type of notification
        else if (hasVendor) {
          Vendor? vendor;
          final vendorData = notificationPayloadData?['vendor'];
          try {
            vendor = Vendor.fromJson(jsonDecode(vendorData));
          } catch (error) {
            final vendorJsonData = jsonDecode(vendorData);
            final vendorId = vendorJsonData["id"];
            if (vendorId != null) {
              AlertService.loading();
              try {
                vendor = await VendorRequest().vendorDetails(vendorId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.vendorDetails, arguments: vendor);
          } catch (error) {
            ToastService.toastError("Unable to fetch vendor details".tr());
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.homeRoute);
          }

          //
        }
        //product type of notification
        else if (hasProduct) {
          //
          Product? product;
          final productData = notificationPayloadData?['product'];
          try {
            product = Product.fromJson(jsonDecode(productData));
          } catch (error) {
            final productJsonData = jsonDecode(productData);
            final productId = productJsonData["id"];
            if (productId != null) {
              AlertService.loading();
              try {
                product = await ProductRequest().productDetails(productId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.product, arguments: product);
          } catch (error) {
            ToastService.toastError("Unable to fetch product details".tr());
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.homeRoute);
          }
        }
        //service type of notification
        else if (hasService) {
          Service? service;
          final serviceData = notificationPayloadData?['service'];
          try {
            service = Service.fromJson(jsonDecode(serviceData));
            //
          } catch (error) {
            final serviceJsonData = jsonDecode(serviceData);
            final serviceId = serviceJsonData["id"];
            if (serviceId != null) {
              AlertService.loading();
              try {
                service = await ServiceRequest().serviceDetails(serviceId);
                AlertService.loading();
              } catch (error) {
                AlertService.loading();
              }
            }
          }
          try {
            Navigator.of(AppService().navigatorKey.currentContext!).push(
              MaterialPageRoute(builder: (_) => ServiceDetailsPage(service!)),
            );
          } catch (error) {
            ToastService.toastError("Unable to fetch service details".tr());
            Navigator.of(
              AppService().navigatorKey.currentContext!,
            ).pushNamed(AppRoutes.homeRoute);
          }
        }
        //regular notifications
        else {
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.notificationDetailsRoute,
            arguments: notificationModel,
          );
        }
      } else {
        Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
          AppRoutes.notificationDetailsRoute,
          arguments: notificationModel,
        );
      }
    } catch (error) {
      print("Error opening Notification ==> $error");
    }
  }

  //refresh orders list if the notification is about assigned order
  void refreshOrdersList(RemoteMessage message) async {
    if (message.data["is_order"] != null) {
      await Future.delayed(Duration(seconds: 3));
      AppService().refreshAssignedOrders.add(true);
    }
  }
}
