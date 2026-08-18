import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/review.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:velocity_x/velocity_x.dart';

class ReviewListItem extends StatelessWidget {
  const ReviewListItem(this.review, {Key? key}) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(Sizes.paddingSizeSmall),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(Sizes.radiusDefault),
        border: Border.all(
          color: context.theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User info and rating
          Row(
            children: [
              // User avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.ratingColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImage(
                    imageUrl: review.user.photo,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              12.widthBox,
              // User name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    review.user.name.text
                        .fontWeight(FontWeight.w600)
                        .size(Sizes.fontSizeLarge)
                        .color(context.theme.textTheme.bodyLarge?.color)
                        .make(),
                    4.heightBox,
                    review.formattedDate.text.medium
                        .color(
                          context.theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        )
                        .make(),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.ratingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Sizes.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      size: 16,
                      color: AppColor.ratingColor,
                    ),
                    4.widthBox,
                    review.rating
                        .toString()
                        .text
                        .fontWeight(FontWeight.w600)
                        .color(AppColor.ratingColor)
                        .make(),
                  ],
                ),
              ),
            ],
          ),

          // Review text
          if (review.review.isNotEmpty) ...[
            12.heightBox,
            review.review.text
                .color(context.theme.textTheme.bodyMedium?.color)
                .lineHeight(1.5)
                .make(),
          ],
        ],
      ),
    );
  }
}
