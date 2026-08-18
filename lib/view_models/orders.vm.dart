import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/view_models/payment.view_model.dart';
import 'package:fuodz/views/pages/order/taxi_order_details.page.dart';
import 'package:fuodz/views/pages/booking/property_booking_details.page.dart';
import 'package:fuodz/extensions/context.dart';

class OrdersViewModel extends PaymentViewModel {
  //
  OrdersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  //
  int queryPage = 1;
  StreamSubscription? homePageChangeStream;
  StreamSubscription? refreshOrderStream;

  void initialise() async {
    await fetchMyOrders();

    homePageChangeStream = AppService().homePageIndex.stream.listen((index) {
      //
      fetchMyOrders();
    });

    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchMyOrders();
      }
    });
  }

  //
  dispose() {
    super.dispose();
    homePageChangeStream?.cancel();
    refreshOrderStream?.cancel();
  }

  //
  fetchMyOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await orderRequest.getOrders(page: queryPage);
      if (!initialLoading) {
        orders.addAll(mOrders);
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  refreshDataSet() {
    initialise();
  }

  openOrderDetails(Order order) async {
    //
    if (order.taxiOrder != null) {
      await viewContext.push((context) => TaxiOrderDetailPage(order: order));
      return;
    }

    if (order.isBooking) {
      await viewContext.push((context) => PropertyBookingDetailsPage(order));
      fetchMyOrders();
      return;
    }

    final result = await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.orderDetailsRoute, arguments: order);

    //
    if (result != null && (result is Order || result is bool)) {
      if (result is Order) {
        final orderIndex = orders.indexWhere((e) => e.id == result.id);
        orders[orderIndex] = result;
        notifyListeners();
      } else {
        fetchMyOrders();
      }
    }
  }

  void openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    notifyListeners();
    fetchMyOrders();
  }
}
