import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_ui_styles.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/list_items/circled_vendor_type.vertical_list_item.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernVendorTypeVerticalListItem extends StatelessWidget {
  const ModernVendorTypeVerticalListItem(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    //
    //
    if (AppUIStyles.moduleCircleItemStyle) {
      return CircledVendorTypeVerticalListItem(
        this.vendorType,
        onPressed: this.onPressed,
      );
    }
    // final textColor = Utils.textColorByColor(Vx.hexToColor(vendorType.color));
    final textColor = Utils.textColorByBrightness(context);
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
          child:
              InkWell(
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
                          ).p8().centered(),
                          //
                          VStack([
                            vendorType.name.text
                                .color(textColor)
                                .medium
                                .size(12)
                                .makeCentered(),
                          ]).py4(),
                        ]).p12().centered(),

                      //image only
                      if (AppStrings.showVendorTypeImageOnly)
                        CustomImage(
                          imageUrl: vendorType.logo,
                          height: _imgHeight,
                          width: _imgWidth,
                          boxFit: AppUIStyles.vendorTypeImageStyle,
                        ).centered(),
                    ]),
                  ).box
                  .clip(Clip.antiAlias)
                  .withRounded(value: 8)
                  .outerShadow
                  .border(
                    color: AppColor.primaryColor.withOpacity(0.45),
                    width: 0.6,
                  )
                  .color(Utils.textColorByBrightness(context, true))
                  .make(),
        ),
      ),
    );
  }
}
