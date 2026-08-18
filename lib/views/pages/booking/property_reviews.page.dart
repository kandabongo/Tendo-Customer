import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/widgets/list_items/property_review.list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/view_models/property_reviews.vm.dart';
import 'package:fuodz/constants/sizes.dart';

class PropertyReviewsPage extends StatelessWidget {
  const PropertyReviewsPage({required this.property, Key? key})
    : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyReviewsViewModel>.reactive(
      viewModelBuilder: () => PropertyReviewsViewModel(context, property),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          title: "Reviews".tr(),
          showAppBar: true,
          showLeadingAction: true,
          body: LoadingShimmer(
            loading: model.isBusy,
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: model.refreshController,
              onRefresh: model.refreshReviews,
              onLoading: model.loadMoreReviews,
              child:
                  model.reviews.isEmpty
                      ? "No reviews found".tr().text.makeCentered()
                      : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(Sizes.paddingSizeDefault),
                        itemBuilder: (context, index) {
                          final review = model.reviews[index];
                          return PropertyReviewListItem(
                            review: review,
                            height: null,
                            width: null,
                          ).wFull(context);
                        },
                        separatorBuilder: (context, index) => 10.heightBox,
                        itemCount: model.reviews.length,
                      ),
            ),
          ),
        );
      },
    );
  }
}
