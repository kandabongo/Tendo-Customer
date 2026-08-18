import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_review.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PropertyReviewsViewModel extends MyBaseViewModel {
  PropertyReviewsViewModel(BuildContext context, this.property) {
    this.viewContext = context;
  }

  final Property property;
  List<PropertyReview> reviews = [];
  RefreshController refreshController = RefreshController();
  int page = 1;

  void initialise() {
    fetchReviews();
  }

  void fetchReviews({bool initialLoading = true}) async {
    if (initialLoading) {
      reviews.clear();
      page = 1;
      refreshController.loadComplete();
      setBusy(true);
    } else {
      page++;
    }

    try {
      final newReviews = await PropertyRequest().getPropertyReviews(
        property.id,
        page: page,
      );

      reviews.addAll(newReviews);
      if (newReviews.isEmpty) {
        refreshController.loadNoData();
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      refreshController.loadFailed();
      setError(e);
    }
    setBusy(false);
  }

  void refreshReviews() {
    fetchReviews(initialLoading: true);
  }

  void loadMoreReviews() {
    fetchReviews(initialLoading: false);
  }
}
