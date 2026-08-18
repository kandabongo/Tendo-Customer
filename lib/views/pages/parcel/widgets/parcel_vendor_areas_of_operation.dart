import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AreasOfOperationWidget extends StatelessWidget {
  final List<String>? countries;
  final List<String>? states;
  final List<String>? cities;
  final EdgeInsetsGeometry? padding;

  const AreasOfOperationWidget({
    Key? key,
    this.countries,
    this.states,
    this.cities,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (countries?.isNotEmpty == true)
            _buildOperationSection(
              'Countries'.tr(),
              countries!,
              Icons.public,
              AppColor.primaryColor,
            ),
          if (states?.isNotEmpty == true)
            _buildOperationSection(
              'States/Provinces'.tr(),
              states!,
              Icons.map,
              AppColor.primaryColor,
            ),
          if (cities?.isNotEmpty == true)
            _buildOperationSection(
              'Cities'.tr(),
              cities!,
              Icons.location_city,
              AppColor.primaryColor,
            ),
          if (_isEmpty()) _buildEmptyState(context),
        ],
      ),
    );
  }

  Widget _buildOperationSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusSmall),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: title.text.xl.semiBold.make(),
          subtitle:
              ("${items.length} " +
                      (items.length != 1 ? 'locations'.tr() : 'location'.tr()))
                  .text
                  .medium
                  .make(),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                Sizes.fontSizeDefault,
                0,
                Sizes.fontSizeDefault,
                Sizes.fontSizeDefault,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    items
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                Sizes.radiusDefault,
                              ),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                color: color.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No operation areas specified'.tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    ).wFull(context);
  }

  bool _isEmpty() {
    return (countries?.isEmpty ?? true) &&
        (states?.isEmpty ?? true) &&
        (cities?.isEmpty ?? true);
  }
}
