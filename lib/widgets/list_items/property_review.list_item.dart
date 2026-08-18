import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property_review.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyReviewListItem extends StatelessWidget {
  const PropertyReviewListItem({
    required this.review,

    this.width = 300,
    this.height = 200,
    Key? key,
  }) : super(key: key);
  final double? width;
  final double? height;

  final PropertyReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(Sizes.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(Sizes.radiusDefault),
      ),
      child: VStack([
        height != null ? _buildRatingSection() : _buildUserInfoSection(),
        //
        if (height == null) _buildRatingSection(),
        // Comment
        if (review.comment != null)
          height == null
              ? review.comment!.text.make()
              : review.comment!.text.maxLines(6).ellipsis.make(),

        if (height != null) Spacer(),

        // Header: User Info & Rating
        if (height != null) _buildUserInfoSection(),
      ], crossAlignment: CrossAxisAlignment.start),
    );
  }

  Widget _buildRatingSection() {
    return HStack([
      VxRating(
        value: review.rating,
        count: 5,
        selectionColor: AppColor.ratingColor,
        normalColor: Colors.grey.shade200,
        size: 14,
        onRatingUpdate: (value) {},
        isSelectable: false,
      ),
      " • ".text.make(),
      Jiffy.parseFromDateTime(
        review.createdAt,
      ).fromNow().text.sm.medium.make().expand(),
    ]);
  }

  Widget _buildUserInfoSection() {
    return HStack([
      CustomImage(
        imageUrl: review.userPhoto,
        width: 40,
        height: 40,
        boxFit: BoxFit.cover,
      ).cornerRadius(50),
      10.widthBox,
      VStack([
        review.userName.text.semiBold.make(),
        Jiffy.parseFromDateTime(
          review.userJoinDate,
        ).fromNow().text.xs.gray500.make(),
      ]).expand(),
    ], crossAlignment: CrossAxisAlignment.start);
  }
}
