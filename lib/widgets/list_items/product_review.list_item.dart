import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/product_review.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductReviewListItem extends StatelessWidget {
  const ProductReviewListItem(this.productReview, {Key? key}) : super(key: key);

  final ProductReview productReview;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        CustomImage(
          imageUrl: productReview.user.photo,
          width: 35,
          height: 35,
        ),
        UiSpacer.hSpace(10),
        VStack(
          [
            VStack(
              [
                productReview.user.name.text.make(),

                ///rating
                HStack(
                  [
                    VxRating(
                      size: 16,
                      maxRating: 5.0,
                      value: productReview.rating.toDouble(),
                      isSelectable: false,
                      onRatingUpdate: (value) {},
                      selectionColor: AppColor.ratingColor,
                    ),
                    //
                    Spacer(),
                    //date
                    "Reviewed on %s"
                        .tr()
                        .fill([
                          DateFormat("MMM d, yyyy")
                              .format(productReview.createdAt)
                        ])
                        .text
                        .sm
                        .gray500
                        .make(),
                  ],
                ),
              ],
            ),

            //review
            if (productReview.review.isNotBlank)
              productReview.review.text.make(),
          ],
          spacing: 5,
        ).expand(),
      ],
      crossAlignment: CrossAxisAlignment.start,
      alignment: MainAxisAlignment.start,
    );
  }
}
