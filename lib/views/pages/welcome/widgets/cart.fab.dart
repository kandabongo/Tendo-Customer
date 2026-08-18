import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/home.vm.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:velocity_x/velocity_x.dart';

class CartHomeFab extends StatelessWidget {
  const CartHomeFab(this.model, {Key? key}) : super(key: key);

  final HomeViewModel model;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: AppColor.primaryColorDark,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: model.openCart,
      child: StreamBuilder<int>(
        stream: CartServices.cartItemsCountStream.stream,
        initialData: CartServices.productsInCart.length,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child = HugeIcon(
            icon: HugeIcons.strokeRoundedShoppingBasket01,
            color: Utils.textColorByPrimaryColor(),
          );
          if (snapshot.hasData && snapshot.data > 0) {
            return child
                .p(Sizes.paddingSizeExtraSmall)
                .badge(
                  position:
                      Utils.isArabic
                          ? VxBadgePosition.leftTop
                          : VxBadgePosition.rightTop,
                  count: snapshot.data,
                  color: Colors.white,
                  textStyle: context.textTheme.bodyLarge?.copyWith(
                    color: AppColor.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
          }

          return child;
        },
      ),
    );
    // : SizedBox(
    //     height: 40,
    //     child: FloatingActionButton.extended(
    //       backgroundColor: AppColor.primaryColorDark,
    //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //       onPressed: model.openCart,
    //       icon: Icon(
    //         FlutterIcons.shopping_cart_faw,
    //         color: Colors.white,
    //       ).badge(
    //         position: Utils.isArabic
    //             ? VxBadgePosition.leftTop
    //             : VxBadgePosition.rightTop,
    //         count: model.totalCartItems,
    //         color: Colors.white,
    //         textStyle: context.textTheme.bodyLarge?.copyWith(
    //           color: AppColor.primaryColor,
    //           fontSize: 10,
    //         ),
    //       ),
    //       label: "Cart".tr().text.white.make(),
    //     ),
    //   );
  }
}
