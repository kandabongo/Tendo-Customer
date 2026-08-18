import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/main_search.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertySearchResultView extends StatelessWidget {
  const PropertySearchResultView(this.vm, {Key? key}) : super(key: key);

  final MainSearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        // Icon
        HugeIcon(
          icon:
              HugeIcons
                  .strokeRoundedHouse01, // Using a house icon as seen in BookingPage
          size: 64,
          color: AppColor.primaryColor,
        ).centered(),
        20.heightBox,

        // Title
        "Find your perfect stay"
            .tr()
            .text
            .xl2
            .semiBold
            .color(context.textTheme.bodyLarge?.color)
            .makeCentered(),
        10.heightBox,

        // Description
        "Explore top-rated properties for your next trip. Enter your dates and guests to find the best options."
            .tr()
            .text
            .center
            .gray500
            .makeCentered()
            .px16(),
        30.heightBox,

        // Button
        CustomButton(
          title: "Search Properties".tr(),
          onPressed: vm.openPropertySearch,
          icon: Icons.search,
        ).centered(),
      ],
      crossAlignment: CrossAxisAlignment.center,
      alignment: MainAxisAlignment.center,
    ).p(20).scrollVertical();
  }
}
