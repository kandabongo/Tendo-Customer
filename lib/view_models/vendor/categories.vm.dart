import 'package:flutter/material.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/category.request.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class CategoriesViewModel extends MyBaseViewModel {
  CategoriesViewModel(BuildContext context, {this.vendorType, this.page}) {
    this.viewContext = context;
  }

  int? page;

  //
  CategoryRequest _categoryRequest = CategoryRequest();
  // RefreshController refreshController = RefreshController();

  //
  List<Category> categories = [];
  VendorType? vendorType;

  //
  initialise() {
    loadCategories();
  }

  //
  loadCategories() async {
    categories = [];
    setBusy(true);

    try {
      categories = await _categoryRequest.categories(
        vendorTypeId: vendorType?.id,
        page: page,
      );
      // the API omits vendor_type on category payloads; without it the
      // subcategory search can't tell this is a service vertical
      for (final category in categories) {
        category.vendorType ??= vendorType;
      }
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  categorySelected(Category category) async {
    NavigationService.categorySelected(category);
  }
}
