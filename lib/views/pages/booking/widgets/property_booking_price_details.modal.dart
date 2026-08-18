import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_details.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyBookingPriceDetailsModal extends StatelessWidget {
  const PropertyBookingPriceDetailsModal({required this.model, Key? key})
    : super(key: key);

  final PropertyDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    // Calculations
    final int nights = model.nights;

    final String startDate = Jiffy.parseFromDateTime(
      model.selectedDateRange!.start,
    ).format(pattern: "MMM dd");
    final String endDate = Jiffy.parseFromDateTime(
      model.selectedDateRange!.end,
    ).format(pattern: "MMM dd");

    return Container(
      padding: EdgeInsets.all(Sizes.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.radiusLarge),
          topRight: Radius.circular(Sizes.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: VStack([
          // Header
          "Price details".tr().text.xl2.bold.make(),
          UiSpacer.verticalSpace(),
          // Price Breakdown
          if (nights > 0)
            HStack([
              "$nights ${'nights'.tr()} x ${"${AppStrings.currencySymbol} ${model.property.price}".currencyFormat()}"
                  .text
                  .lg
                  .make(),
              Spacer(),
              "${"${AppStrings.currencySymbol} ${model.totalPrice}".currencyFormat()}"
                  .text
                  .lg
                  .make(),
            ]),
          UiSpacer.verticalSpace(),

          // Dates & Cancellation
          Container(
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(Sizes.radiusDefault),
            ),
            child: VStack([
              // Dates
              HStack([
                VStack([
                  "Dates".tr().text.bold.make(),
                  "$startDate - $endDate".text.make(),
                ], crossAlignment: CrossAxisAlignment.start).expand(),
                TextButton(
                  onPressed: () {
                    context.pop();
                    model.openPropertyBookingDateSectionPage();
                  },
                  child: "Edit".tr().text.bold.underline.make(),
                ),
              ]),
              UiSpacer.divider(height: 20),
              // Cancellation Policy
              if (model.property.cancellationPolicy != null)
                VStack([
                  "Cancellation policy".tr().text.bold.make(),
                  if (model.property.cancellationPolicy!.name
                      .toLowerCase()
                      .contains("free"))
                    "Free cancellation before %s."
                        .tr()
                        .fill([
                          Jiffy.parseFromDateTime(
                            model.selectedDateRange!.start.subtract(
                              Duration(days: 1),
                            ),
                          ).format(pattern: "MMM dd"),
                        ])
                        .text
                        .make()
                  else
                    model.property.cancellationPolicy!.name.text.make(),
                ], crossAlignment: CrossAxisAlignment.start),
            ]),
          ),
          UiSpacer.verticalSpace(space: 20),

          // Reserve Button
          CustomButton(
            title: "Reserve".tr(),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ).wFull(context),
        ]),
      ),
    );
  }
}
