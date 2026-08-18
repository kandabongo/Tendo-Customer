import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptySubcategoriesView extends StatelessWidget {
  const EmptySubcategoriesView({
    this.type = "",
    Key? key,
  }) : super(key: key);
  final String type;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //Image
        Image.asset(
          AppImages.emptySearch,
          height: context.screenWidth * 0.3,
          width: context.screenWidth * 0.3,
          fit: BoxFit.contain,
        ).centered(),
        VStack(
          [
            //title
            "No Subcategories Found".tr().text.xl.semiBold.center.make(),
            //body
            "There are currently no active subcategories under the selected category. Please check back later"
                .tr()
                .text
                .center
                .make(),
          ],
          crossAlignment: CrossAxisAlignment.center,
          alignment: MainAxisAlignment.center,
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
      spacing: 10,
    ).p(12).centered();
  }
}
