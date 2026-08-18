import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/view_models/property_details.vm.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyReservationDateSection extends StatelessWidget {
  const PropertyReservationDateSection(this.model, {Key? key})
    : super(key: key);

  final PropertyDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    if (model.selectedDateRange == null) {
      return VStack([]);
    }
    DateTime startDateTime = model.selectedDateRange!.start;
    DateTime endDateTime = model.selectedDateRange!.end;
    String startDate = Jiffy.parseFromDateTime(
      startDateTime,
    ).format(pattern: "MMM dd");
    String endDate = Jiffy.parseFromDateTime(endDateTime).format(pattern: "dd");
    //not same month
    if (startDateTime.month != endDateTime.month) {
      endDate = Jiffy.parseFromDateTime(endDateTime).format(pattern: "MMM dd");
    }
    int nights = model.selectedDateRange!.duration.inDays;
    String nightsLabel = "nights".tr();
    if (nights == 1) {
      nightsLabel = "night".tr();
    }

    return GestureDetector(
      onTap: () {
        model.openPropertyBookingPriceDetailsModal();
      },
      child: VStack([
        //total price
        Container(
          child:
              "${AppStrings.currencySymbol} ${model.totalPrice}"
                  .currencyFormat()
                  .text
                  .xl2
                  .color(Vx.gray700)
                  .bold
                  .lineHeight(1.1)
                  .make(),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Vx.gray700, width: 1.7)),
          ),
        ),
        //
        "${"For".tr()} $nights $nightsLabel $startDate - $endDate"
            .text
            .gray500
            .sm
            .make(),

        //cancellation policy
        if (model.property.cancellationPolicy != null) ...[
          5.heightBox,
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.paddingSizeExtraSmall,
              horizontal: Sizes.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Vx.gray100,
              borderRadius: BorderRadius.circular(Sizes.radiusLarge),
            ),
            child: HStack([
              //PHOTO
              Icon(Icons.check, color: Vx.gray500, size: 18),
              5.widthBox,

              //name
              "${model.property.cancellationPolicy?.name}".text.gray500.sm
                  .make(),
            ]),
          ),
        ],
      ]),
    );
  }
}
