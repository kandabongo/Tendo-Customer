import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_booking_summary.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingGuestSelelctionBottomSheet extends StatefulWidget {
  final PropertyBookingSummaryViewModel model;

  BookingGuestSelelctionBottomSheet(this.model);

  @override
  _BookingGuestSelelctionBottomSheetState createState() =>
      _BookingGuestSelelctionBottomSheetState();
}

class _BookingGuestSelelctionBottomSheetState
    extends State<BookingGuestSelelctionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyBookingSummaryViewModel>.reactive(
      viewModelBuilder: () => widget.model,
      disposeViewModel: false,
      builder: (context, model, child) {
        return Container(
          padding: EdgeInsets.all(Sizes.paddingSizeDefault),
          child: SafeArea(
            child: VStack([
              HStack([
                "Guests".tr().text.xl.bold.make(),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              UiSpacer.verticalSpace(),
              _buildGuestCounter(
                title: "Adults".tr(),
                subtitle: "Ages 13 or above".tr(),
                value: model.adults,
                onChanged: (val) => model.updateGuestCount(newAdults: val),
              ),
              UiSpacer.divider(),
              _buildGuestCounter(
                title: "Children".tr(),
                subtitle: "Ages 2-12".tr(),
                value: model.children,
                onChanged: (val) => model.updateGuestCount(newChildren: val),
              ),
              UiSpacer.divider(),
              _buildGuestCounter(
                title: "Infants".tr(),
                subtitle: "Under 2".tr(),
                value: model.infants,
                onChanged: (val) => model.updateGuestCount(newInfants: val),
              ),
              UiSpacer.divider(),
              _buildGuestCounter(
                title: "Pets".tr(),
                subtitle: "Service animals welcome".tr(),
                value: model.pets,
                onChanged: (val) => model.updateGuestCount(newPets: val),
              ),
              UiSpacer.verticalSpace(space: 20),
              CustomButton(
                title: "Save".tr(),
                onPressed: () => Navigator.pop(context),
              ).wFull(context),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildGuestCounter({
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
  }) {
    return HStack([
      VStack([
        title.text.semiBold.make(),
        subtitle.text.xs.gray500.make(),
      ], crossAlignment: CrossAxisAlignment.start).expand(),
      HStack([
        // Minus Button
        Icon(Icons.remove, size: 20)
            .p8()
            .box
            .roundedFull
            .border(color: value > 0 ? Colors.grey : Colors.grey.shade200)
            .make()
            .onInkTap(() {
              if (value > 0) onChanged(value - 1);
            }),
        UiSpacer.horizontalSpace(),
        value.text.lg.semiBold.make().w(20).centered(),
        UiSpacer.horizontalSpace(),
        // Plus Button
        Icon(
          Icons.add,
          size: 20,
        ).p8().box.roundedFull.border(color: Colors.grey).make().onInkTap(() {
          onChanged(value + 1);
        }),
      ]),
    ]).py12();
  }
}
