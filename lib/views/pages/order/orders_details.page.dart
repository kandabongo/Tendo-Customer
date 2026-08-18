import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/views/pages/order/widgets/order.bottomsheet.dart';
import 'package:fuodz/views/pages/order/widgets/order_address.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_attachment.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_driver_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_items.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_vendor_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_status.view.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_card.dart';
import 'package:fuodz/views/pages/order/widgets/order_status_header.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/cards/order_details_summary.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/utils/utils.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.order,
    this.isOrderTracking = false,
    Key? key,
  }) : super(key: key);

  final Order order;
  final bool isOrderTracking;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OrderDetailsViewModel>.reactive(
      viewModelBuilder: () => OrderDetailsViewModel(context, order),
      disposeViewModel: true,
      createNewViewModelOnInsert: true,
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Order Details".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy,
          elevation: 0,
          backgroundColor:
              context.isDarkMode
                  ? context.theme.scaffoldBackgroundColor
                  : Colors.grey.shade50,
          appBarColor: context.primaryColor,
          appBarItemColor: Utils.textColorByPrimaryColor(),
          onBackPressed: () => context.pop(vm.order),
          actions:
              vm.order.isPackageDelivery
                  ? [
                    Icon(
                      FlutterIcons.share_2_fea,
                      color: Utils.textColorByColor(
                        context.theme.colorScheme.surface,
                      ),
                    ).p8().onInkTap(vm.shareOrderDetails).p8(),
                  ]
                  : [],
          body:
              vm.isBusy
                  ? const BusyIndicator().centered()
                  : SmartRefresher(
                    controller: vm.refreshController,
                    onRefresh: vm.fetchOrderDetails,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child:
                          VStack([
                            // 1. Order Status Header Card
                            OrderStatusHeader(vm: vm),

                            // 2. Deliver Addresses / Path
                            if (vm.order.deliveryAddress != null)
                              OrderDetailsCard(child: OrderAddressesView(vm)),

                            if (!vm.order.isPackageDelivery &&
                                vm.order.deliveryAddress == null)
                              OrderDetailsCard(
                                child: "Customer Order Pickup"
                                    .tr()
                                    .text
                                    .italic
                                    .xl
                                    .medium
                                    .makeCentered()
                                    .py(8),
                              ),

                            // 3. Status Tracking View Card (if active tracking states)
                            if (_showTrackingCardView(vm))
                              OrderDetailsCard(
                                child: OrderStatusView(vm).py(4),
                              ),

                            // 4. Products / Services / Items Card
                            OrderDetailsCard(child: OrderDetailsItemsView(vm)),

                            // 5. Vendor Info Card
                            OrderDetailsCard(
                              child: OrderDetailsVendorInfoView(vm),
                            ),

                            // 6. Driver Info Card (If assigned)
                            if (vm.order.driver != null)
                              OrderDetailsCard(
                                child: OrderDetailsDriverInfoView(vm),
                              ),

                            // 7. Note & Attachment Card
                            if ((vm.order.note.isNotEmpty) ||
                                (vm.order.attachments != null &&
                                    vm.order.attachments!.isNotEmpty))
                              OrderDetailsCard(
                                child: VStack([
                                  if (vm.order.note.isNotEmpty) ...[
                                    "Note".tr().text.semiBold.xl.make(),
                                    "${vm.order.note}".text.light.sm.make(),
                                  ],
                                  if (vm.order.attachments!.isNotEmpty)
                                    OrderAttachmentView(vm),
                                ], spacing: 10),
                              ),

                            // 8. Payment Status & Order Summary Card
                            OrderDetailsCard(
                              child: VStack([
                                OrderPaymentInfoView(vm),
                                UiSpacer.divider().py(12),
                                OrderDetailsSummary(vm.order),
                              ]),
                            ),

                            UiSpacer.vSpace(60),
                          ], spacing: Sizes.paddingSizeDefault).p16(),
                    ),
                  ),
          bottomSheet: isOrderTracking ? null : OrderBottomSheet(vm),
        );
      },
    );
  }

  bool _showTrackingCardView(OrderDetailsViewModel vm) {
    return vm.order.status != "delivered" &&
        vm.order.status != "failed" &&
        vm.order.status != "cancelled";
  }
}
