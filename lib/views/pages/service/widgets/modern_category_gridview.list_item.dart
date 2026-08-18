import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernCategoryGridviewListItem extends StatelessWidget {
  const ModernCategoryGridviewListItem({
    required this.category,
    this.onPressed,
    super.key,
  });
  final Category category;
  final Function(Category)? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call(category);
      },
      child: Container(
        padding: EdgeInsets.all(Sizes.paddingSizeDefault),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(Sizes.radiusLarge),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Vx.hexToColor(category.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                child: CustomImage(imageUrl: category.imageUrl),
                width: AppIconSizes.lg,
              ),
            ),
            SizedBox(height: 12),
            category.name.text.semiBold
                .size(AppTextSizes.sm)
                .maxLines(2)
                .ellipsis
                .make(),

            SizedBox(height: 4),
            Text(
              '%s services'.tr().fill([category.services_count]),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
