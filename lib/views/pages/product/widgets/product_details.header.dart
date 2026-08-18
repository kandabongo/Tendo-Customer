import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/views/pages/review/product_reviews.page.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/currency_hstack.dart';
import 'package:fuodz/widgets/tags/product_tags.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailsHeader extends StatelessWidget {
  const ProductDetailsHeader({
    required this.product,
    this.showVendor = false,
    Key? key,
  }) : super(key: key);

  final Product product;
  final bool showVendor;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currentCurrencySymbol;

    return VStack([
      //product name, vendor name, and price
      HStack([
        //name
        VStack([
          //product name
          product.name.text.xl.semiBold.make(),
          HStack([
            VxRating(
              normalImage: Icons.star_border,
              selectImage: Icons.star,
              value: product.rating ?? 0,
              stepInt: true,
              selectionColor: AppColor.ratingColor,
              normalColor: AppColor.ratingColor,
              onRatingUpdate: (rating) {},
              isSelectable: false,
              size: 16,
            ),
            "(${product.reviewsCount})".text.size(Sizes.fontSizeSmall).make(),
          ], spacing: 5).onTap(() {
            context.nextPage(ProductReviewsPage(product));
          }),
          //vendor name
          CustomVisibilty(
            visible: showVendor,
            child: product.vendor.name.text.lg.medium.make(),
          ),
        ], spacing: 2).expand(),

        //price
        VStack([
          //price
          CurrencyHStack([
            currencySymbol.text.lg.bold.make(),
            (product.showDiscount
                    ? product.discountPrice.convertCurrency
                        .currencyValueFormat()
                    : product.price.convertCurrency.currencyValueFormat())
                .text
                .xl2
                .bold
                .make(),
          ], crossAlignment: CrossAxisAlignment.end),
          //discount
          CustomVisibilty(
            visible: product.showDiscount,
            child: CurrencyHStack([
              currencySymbol.text.lineThrough.xs.make(),
              product.price.convertCurrency
                  .currencyValueFormat()
                  .text
                  .lineThrough
                  .lg
                  .medium
                  .make(),
            ]),
          ),
        ]),
      ]),

      //product size details and more
      HStack([
        //deliverable or not
        (product.canBeDelivered ? "Deliverable".tr() : "Not Deliverable".tr())
            .text
            .white
            .sm
            .make()
            .py4()
            .px8()
            .box
            .roundedLg
            .color(product.canBeDelivered ? Vx.green500 : Vx.red500)
            .make(),

        //
        UiSpacer.expandedSpace(),

        //size
        CustomVisibilty(
          visible:
              !product.capacity.isEmptyOrNull && !product.unit.isEmptyOrNull,
          child: "${product.capacity} ${product.unit}".text.sm.black
              .make()
              .py4()
              .px8()
              .box
              .roundedLg
              .gray500
              .make()
              .pOnly(right: Vx.dp12),
        ),

        //package items
        CustomVisibilty(
          visible: product.packageCount != null,
          child:
              "%s Items"
                  .tr()
                  .fill(["${product.packageCount}"])
                  .text
                  .sm
                  .black
                  .make()
                  .py4()
                  .px8()
                  .box
                  .roundedLg
                  .gray500
                  .make(),
        ),
      ]).pOnly(top: Vx.dp10),

      //
      10.heightBox,
      ProductTags(product),
    ]).px20().py12();
  }
}
