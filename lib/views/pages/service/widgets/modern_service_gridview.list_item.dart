import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernServiceGridviewListItem extends StatelessWidget {
  const ModernServiceGridviewListItem({required this.service, super.key});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationService.openServiceDetails(service);
      },
      child: Container(
        padding: EdgeInsets.all(Sizes.paddingSizeSmall),
        decoration: BoxDecoration(
          color: context.canvasColor,
          borderRadius: BorderRadius.circular(Sizes.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusSmall),
              child: CustomImage(
                imageUrl: service.photos.first,
                width: double.infinity,
                height: 80,
                boxFit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            service.name.text
                .maxLines(2)
                .ellipsis
                .semiBold
                .size(AppTextSizes.sm)
                .make(),

            SizedBox(height: 4),
            Text(
              'by %s'.tr().fill([service.vendor.name]),
              style: TextStyle(fontSize: 12),
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                SizedBox(width: 4),
                Text(
                  "${service.vendor.rating}",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Text(
                  "${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}"
                      .currencyFormat(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
