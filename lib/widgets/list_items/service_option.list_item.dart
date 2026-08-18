import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/service_option.dart';
import 'package:fuodz/models/service_option_group.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/view_models/service_details.vm.dart';
import 'package:fuodz/widgets/currency_hstack.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceOptionListItem extends StatelessWidget {
  const ServiceOptionListItem({
    required this.option,
    required this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final ServiceOption option;
  final ServiceOptionGroup optionGroup;
  final ServiceDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currentCurrencySymbol;
    return HStack(
          [
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: model.isOptionSelected(option),
              onChanged: (value) {
                if (value != null) {
                  model.toggleOptionSelection(optionGroup, option);
                }
              },
            ),
            VStack([
              HStack(
                [
                  //image/photo
                  if (option.photo.isNotEmptyAndNotNull &&
                      option.photo.isNotDefaultImage)
                    CustomImage(
                      imageUrl: option.photo,
                      width: Vx.dp32,
                      height: Vx.dp32,
                      canZoom: true,
                      hideDefaultImg: true,
                    ).card.clip(Clip.antiAlias).roundedSM.make(),

                  //name
                  option.name.text.medium.lg.make().expand(),

                  //price
                  CurrencyHStack([
                    currencySymbol.text.sm.medium.make(),
                    option.price.convertCurrency
                        .currencyValueFormat()
                        .text
                        .sm
                        .bold
                        .make(),
                  ], crossAlignment: CrossAxisAlignment.end),
                ],
                crossAlignment: CrossAxisAlignment.center,
                spacing: 12,
              ),

              //
              //details
              (option.description.isNotEmptyAndNotNull &&
                      option.description.isNotNullOrBlank)
                  ? "${option.description}".text.sm
                      .maxLines(3)
                      .overflow(TextOverflow.ellipsis)
                      .make()
                  : 0.widthBox,
            ], spacing: 5).expand(),
          ],
          spacing: 10,
          crossAlignment: CrossAxisAlignment.start,
        )
        .p(10)
        .box
        .withRounded(value: Sizes.radiusSmall)
        .border(
          color:
              model.isOptionSelected(option)
                  ? context.primaryColor
                  : Colors.grey.shade200,
          width: model.isOptionSelected(option) ? 2.5 : 1.0,
        )
        .make();
  }
}
