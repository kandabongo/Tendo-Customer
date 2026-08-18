import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/views/pages/booking/widgets/property_fav.icon.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyListItem extends StatelessWidget {
  const PropertyListItem({required this.property, this.onPressed, Key? key})
    : super(key: key);

  final Property property;
  final Function(Property)? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed == null) {
          Navigator.pushNamed(
            context,
            AppRoutes.propertyDetailsRoute,
            arguments: property,
          );
        } else {
          onPressed!(property);
        }
      },
      child: VStack([
        // Image
        Stack(
          children: [
            CustomImage(
                  imageUrl: property.mainPhoto,
                  boxFit: BoxFit.cover,
                  width: double.infinity,
                  height: context.percentHeight * 22,
                ).box
                .clip(Clip.antiAlias)
                .withRounded(value: Sizes.radiusDefault)
                .withShadow([
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ])
                .make(),
            // Wishlist icon
            Positioned(top: 12, right: 12, child: PropertyFavIcon(property)),
          ],
        ),

        // Info
        HStack([
          VStack([
            property.name.text.semiBold.size(16).make(),
            "${property.city}, ${property.country}".text
                .maxLines(1)
                .ellipsis
                .gray500
                .size(14)
                .make(),
            "${"${AppStrings.currencySymbol} ${property.price}".currencyFormat()} /${"night".tr()}"
                .text
                .semiBold
                .size(16)
                .make()
                .pOnly(top: 4),
          ]).expand(),
          // Rating
          if (property.reviewsCount > 0)
            HStack([
              Icon(Icons.star, size: 16, color: Colors.black),
              " ${property.rating.toStringAsFixed(2)}".text.semiBold.make(),
            ], crossAlignment: CrossAxisAlignment.center),
        ], crossAlignment: CrossAxisAlignment.start).pOnly(top: 12, bottom: 20),
      ]),
    );
  }
}
