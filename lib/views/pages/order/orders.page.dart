import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/services/order.service.dart';
import 'package:fuodz/view_models/orders.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/order.list_item.dart';
import 'package:fuodz/widgets/list_items/order_booking.list_item.dart';
import 'package:fuodz/widgets/list_items/taxi_order.list_item.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:fuodz/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    return BasePage(
      allowTopSafeArea: true,
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack([
            //
            20.heightBox,
            "My Orders".tr().text.xl2.semiBold.make().px(20),
            10.heightBox,
            //
            if (vm.isAuthenticated())
              CustomListView(
                canPullUp: true,
                canRefresh: true,
                refreshController: vm.refreshController,
                onRefresh: () => vm.fetchMyOrders(),
                onLoading: () => vm.fetchMyOrders(initialLoading: false),
                dataSet: vm.orders,
                padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                emptyWidget: EmptyOrder(),
                separatorBuilder:
                    (_, index) => Sizes.paddingSizeSmall.heightBox,
                isLoading: vm.isBusy,
                itemBuilder: (context, index) {
                  final order = vm.orders[index];
                  //for taxi tye of order
                  if (order.taxiOrder != null) {
                    return TaxiOrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  } else if (order.isBooking) {
                    return OrderBookingListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                      onPayPressed:
                          () => OrderService.openOrderPayment(order, vm),
                    );
                  }
                  return OrderListItem(
                    order: order,
                    orderPressed: () => vm.openOrderDetails(order),
                    onPayPressed:
                        () => OrderService.openOrderPayment(order, vm),
                  );
                },
                // listView:
                //     vm.orders.map((order) {
                //       //for taxi tye of order
                //       if (order.taxiOrder != null) {
                //         return TaxiOrderListItem(
                //           order: order,
                //           orderPressed: () => vm.openOrderDetails(order),
                //         );
                //       }
                //       return OrderListItem(
                //         order: order,
                //         orderPressed: () => vm.openOrderDetails(order),
                //         onPayPressed:
                //             () => OrderService.openOrderPayment(order, vm),
                //       );
                //     }).toList(),
              ).expand(),

            if (!vm.isAuthenticated())
              EmptyState(
                auth: true,
                showAction: true,
                actionPressed: vm.openLogin,
              ).py12().centered().expand(),

            /*
              vm.isAuthenticated()
                  ? CustomListView(
                      canRefresh: true,
                      canPullUp: true,
                      refreshController: vm.refreshController,
                      onRefresh: vm.fetchMyOrders,
                      onLoading: () =>
                          vm.fetchMyOrders(initialLoading: false),
                      isLoading: vm.isBusy,
                      dataSet: vm.orders,
                      hasError: vm.hasError,
                      errorWidget: LoadingError(
                        onrefresh: vm.fetchMyOrders,
                      ),
                      //
                      emptyWidget: EmptyOrder(),
                      itemBuilder: (context, index) {
                        //
                        final order = vm.orders[index];
                        //for taxi tye of order
                        if (order.taxiOrder != null) {
                          return TaxiOrderListItem(
                            order: order,
                            orderPressed: () => vm.openOrderDetails(order),
                          );
                        }
                        return OrderListItem(
                          order: order,
                          orderPressed: () => vm.openOrderDetails(order),
                          onPayPressed: () =>
                              OrderService.openOrderPayment(order, vm),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          UiSpacer.verticalSpace(space: 2),
                    ).expand()
                  : EmptyState(
                      auth: true,
                      showAction: true,
                      actionPressed: vm.openLogin,
                    ).py12().centered().expand(),
                    */
          ]);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
