import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderBookingListItem extends StatelessWidget {
  const OrderBookingListItem({
    required this.order,
    required this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function onPayPressed;
  final Function orderPressed;

  @override
  Widget build(BuildContext context) {
    final booking = order.bookingOrder;
    final property = booking?.property;

    return VStack([
          HStack([
            // Property Image
            if (property?.mainPhoto != null)
              CustomImage(
                imageUrl: property!.mainPhoto,
                width: 80,
                height: 80,
                boxFit: BoxFit.cover,
              ).cornerRadius(Sizes.radiusSmall),

            if (property?.mainPhoto != null) UiSpacer.horizontalSpace(),

            // Details
            VStack([
              // Booking Code & Price
              HStack([
                "#${order.code}".text.medium.make().expand(),
                "${AppStrings.currencySymbol} ${order.total}"
                    .currencyFormat()
                    .text
                    .lg
                    .semiBold
                    .make(),
              ]),
              UiSpacer.verticalSpace(space: 4),

              // Property Name
              (property?.name ?? "Property Name").text.lg.semiBold
                  .maxLines(1)
                  .ellipsis
                  .make(),

              // Dates
              if (booking != null)
                "${Jiffy.parse(booking.checkInDate.toString()).format(pattern: 'dd MMM')} - ${Jiffy.parse(booking.checkOutDate.toString()).format(pattern: 'dd MMM yyyy')}"
                    .text
                    .sm
                    .gray500
                    .make()
                    .py2(),

              UiSpacer.verticalSpace(space: 4),

              // Status
              HStack([
                // Payment Method
                Visibility(
                  visible: order.paymentMethod != null,
                  child:
                      "${order.paymentMethod?.name}".text.xs.medium.gray500
                          .make(),
                ).expand(),

                // Order Status
                "${order.status}"
                    .tr()
                    .capitalized
                    .text
                    .color(AppColor.getStausColor(order.status))
                    .medium
                    .make(),
              ]),
            ]).expand(),
          ], crossAlignment: CrossAxisAlignment.start).p12(),

          // Payment Button if pending
          if (order.isPaymentPending && order.isOngoing)
            CustomButton(
              title: "PAY FOR ORDER".tr(),
              titleStyle: context.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              icon: FlutterIcons.credit_card_fea,
              iconSize: 18,
              onPressed: onPayPressed,
              shapeRadius: 0,
            ),
        ]).box
        .clip(Clip.antiAlias)
        .color(context.cardColor)
        .outerShadowSm
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusSmall)
        .make()
        .onInkTap(() => orderPressed());
  }
}
