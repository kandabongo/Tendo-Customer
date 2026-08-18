import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_ui_styles.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CircledVendorTypeVerticalListItem extends StatelessWidget {
  const CircledVendorTypeVerticalListItem(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    //
    double _imgWidth =
        AppUIStyles.vendortypePercentageWidth == null
            ? AppUIStyles.vendorTypeWidth
            : (context.percentWidth * AppUIStyles.vendortypePercentageWidth!);
    double _imgHeight =
        AppUIStyles.vendortypePercentageHeight == null
            ? AppUIStyles.vendorTypeHeight
            : (context.percentHeight * AppUIStyles.vendortypePercentageHeight!);
    //
    return AnimationConfiguration.staggeredList(
      position: vendorType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: () => onPressed(),
            child: VStack([
              //image + details
              if (!AppStrings.showVendorTypeImageOnly)
                VStack([
                  //
                  CustomImage(
                        imageUrl: vendorType.logo,
                        boxFit: AppUIStyles.vendorTypeImageStyle,
                        height: _imgHeight,
                        width: _imgWidth,
                      ).box
                      .clip(Clip.antiAliasWithSaveLayer)
                      .color(Vx.hexToColor(vendorType.color))
                      .roundedFull
                      .make(),
                  //
                  VStack([
                    vendorType
                        .name
                        .text
                        .lg
                        // .color(textColor)
                        .semiBold
                        .base
                        .center
                        .make(),
                    if (vendorType.description.isNotEmpty &&
                        !AppUIStyles.moduleTitleOnly)
                      "${vendorType.description}"
                          .text
                          // .color(textColor)
                          .center
                          .sm
                          .make()
                          .pOnly(top: 5),
                  ], crossAlignment: CrossAxisAlignment.center),
                ], crossAlignment: CrossAxisAlignment.center),

              //image only
              if (AppStrings.showVendorTypeImageOnly)
                CustomImage(
                      imageUrl: vendorType.logo,
                      boxFit: AppUIStyles.vendorTypeImageStyle,
                      height: _imgHeight,
                      width: _imgWidth,
                    ).box
                    .clip(Clip.antiAliasWithSaveLayer)
                    .color(Vx.hexToColor(vendorType.color))
                    .roundedFull
                    .make(),
            ], crossAlignment: CrossAxisAlignment.center),
          ),
        ),
      ),
    );
  }
}
