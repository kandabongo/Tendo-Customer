import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/view_models/taxi.vm.dart';
import 'package:fuodz/widgets/currency_hstack.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class NewHorizontalVehicleTypeListItem extends StatefulWidget {
  const NewHorizontalVehicleTypeListItem(this.vm, this.vehicleType, {Key? key})
    : super(key: key);
  final VehicleType vehicleType;
  final TaxiViewModel vm;

  @override
  State<NewHorizontalVehicleTypeListItem> createState() =>
      _NewHorizontalVehicleTypeListItemState();
}

class _NewHorizontalVehicleTypeListItemState
    extends State<NewHorizontalVehicleTypeListItem> {
  bool showInfo = false;

  toggleShowInfo() {
    setState(() {
      showInfo = !showInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    final selected = widget.vm.selectedVehicleType?.id == widget.vehicleType.id;
    final currencySymbol =
        widget.vehicleType.currency != null
            ? widget.vehicleType.currency?.symbol
            : AppStrings.currentCurrencySymbol;
    //
    return VStack(
          [
            //
            CustomImage(
              imageUrl: widget.vehicleType.photo,
              height: context.percentWidth * 12,
              boxFit: BoxFit.fitWidth,
            ).centered(),

            Sizes.paddingSizeDefault.heightBox,

            VStack([
              CurrencyHStack([
                " $currencySymbol ".text.lg.bold.make(),
                " ${widget.vehicleType.total.convertIf(widget.vehicleType.currency == null)} "
                    .currencyValueFormat()
                    .text
                    .lg
                    .bold
                    .make(),
              ]),

              // surge rate
              if (widget.vehicleType.hasSurge)
                HStack([
                  Icon(
                    Icons.trending_up_outlined,
                    color: Colors.red.shade300,
                    size: 12,
                  ),
                  " ${widget.vehicleType.surgeRate}x ".text.sm.red500.bold
                      .make(),
                ]),
            ]),

            "${widget.vehicleType.name}".text.bold.maxLines(1).ellipsis.make(),
          ],
          alignment: MainAxisAlignment.center,
          crossAlignment: CrossAxisAlignment.center,
          spacing: Sizes.paddingSizeExtraSmall,
        ).box.p4
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey.shade200,
          width: 1,
        )
        .color(
          selected
              ? AppColor.primaryColor.withOpacity(0.20)
              : AppColor.primaryColor.withOpacity(0.05),
        )
        .roundedSM
        .make()
        .onTap(() => widget.vm.changeSelectedVehicleType(widget.vehicleType))
        .wFull(context);
  }
}
