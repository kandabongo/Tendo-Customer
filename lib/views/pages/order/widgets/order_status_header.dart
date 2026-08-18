import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_card.dart';

class OrderStatusHeader extends StatelessWidget {
  const OrderStatusHeader({required this.vm, Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return OrderDetailsCard(
      child: HStack(
        [
          // vendor logo securely contained
          CustomImage(
            imageUrl: vm.order.vendor!.logo,
            width: 50,
            height: 50,
          ).box.roundedSM.clip(Clip.antiAlias).make(),
          
          UiSpacer.horizontalSpace(),
          
          VStack([
            "${vm.order.status.tr().capitalized}"
                .text
                .semiBold
                .xl
                .color(AppColor.getStausColor(vm.order.status))
                .make(),
            "${Jiffy.parseFromDateTime(vm.order.updatedAt).format(pattern: 'MMM dd, yyyy \| HH:mm')}"
                .text
                .light
                .sm
                .make(),
            "#${vm.order.code}".text.xs.gray400.make(),
          ]).expand(),
          
          // qr code verification icon if required
          if (!vm.order.isTaxi && !vm.order.isSerice)
            Icon(FlutterIcons.qrcode_ant, size: 28)
                .onInkTap(vm.showVerificationQRCode),
        ],
        crossAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
