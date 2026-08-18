import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/package_type_pricing.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageTypePricingCardInfo extends StatelessWidget {
  final PackageTypePricing pricing;
  final EdgeInsetsGeometry? padding;
  final bool showTitle;
  final String? title;

  const PackageTypePricingCardInfo({
    Key? key,
    required this.pricing,
    this.padding,
    this.showTitle = true,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          (title ?? 'Pricing Breakdown').tr().text.semiBold.make(),
          5.heightBox,
        ],

        GridView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Sizes.paddingSizeSmall,
            mainAxisSpacing: Sizes.paddingSizeSmall,
            childAspectRatio: 2.6,
          ),

          children: [
            _buildPricingChip(
              context,
              'Max Booking Days'.tr(),
              '%s days'.tr().fill([pricing.maxBookingDays]),
              Icons.calendar_today,
            ),
            _buildPricingChip(
              context,
              'Size Price'.tr(),
              _formatPrice(pricing.sizePrice.convertCurrency),
              Icons.aspect_ratio,
            ),
            _buildPricingChip(
              context,
              'Price per KG'.tr(),
              _formatPrice(pricing.pricePerKg.convertCurrency),
              Icons.fitness_center,
            ),
            _buildPricingChip(
              context,
              'Distance Price'.tr(),
              _formatPrice(pricing.distancePrice.convertCurrency),
              Icons.straighten,
            ),
            _buildPricingChip(
              context,
              'Base Price'.tr(),
              _formatPrice(pricing.basePrice.convertCurrency),
              Icons.attach_money,
            ),
            _buildPricingChip(
              context,
              'Multiple Stop Fee'.tr(),
              _formatPrice(pricing.multipleStopFee.convertCurrency),
              Icons.location_on,
            ),
            _buildPricingChip(
              context,
              'Price per KM'.tr(),
              _formatPrice(pricing.pricePerKm.convertCurrency),
              Icons.route,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(Sizes.paddingSizeSmall),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(Sizes.radiusSmall),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: HStack(
        [
          Container(
            padding: const EdgeInsets.all(Sizes.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.swatch.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColor.primaryColor.swatch.shade600,
            ),
          ),
          VStack([
            label.text.sm.semiBold.maxLines(2).ellipsis.make(),
            value.text.bold.lg.make(),
          ]).fittedBox(alignment: Alignment.centerLeft).expand(),
        ],
        spacing: Sizes.paddingSizeSmall,
        crossAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return 'N/A';
    return '${AppStrings.currentCurrencySymbol} $price'.currencyFormat();
  }
}
