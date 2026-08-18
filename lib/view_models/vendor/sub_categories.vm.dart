import 'package:flutter/material.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/requests/category.request.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';

class SubcategoriesViewModel extends MyBaseViewModel {
  SubcategoriesViewModel(BuildContext context, this.category) {
    this.viewContext = context;
  }

  //
  CategoryRequest _categoryRequest = CategoryRequest();
  RefreshController refreshController = RefreshController();
  TextEditingController searchTEC = TextEditingController();
  bool showSearch = false;
  final searchKeywordStream = BehaviorSubject<String>();

  void toggleSearch() {
    showSearch = !showSearch;
    if (!showSearch) {
      searchTEC.clear();
      searchKeywordStream.add("");
    }
    notifyListeners();
  }

  //
  List<Category> subcategories = [];
  final Category category;

  //
  initialise() async {
    loadSubcategories();
  }

  //
  loadSubcategories() async {
    setBusy(true);
    try {
      subcategories = await _categoryRequest.subcategories(
        categoryId: category.id,
      );

      //if there is no subcategory, add "All" category
      if (subcategories.isEmpty) {
        subcategories.add(
          Category(
            id: category.id,
            name: "All".tr(),
            imageUrl: category.imageUrl,
            photo: category.photo,
            vendorType: category.vendorType,
          ),
        );
      } else {
        //if there are subcategories, add "Others" category
        subcategories.add(
          Category(
            id: category.id,
            name: "Others".tr(),
            imageUrl: category.imageUrl,
            photo: category.photo,
            vendorType: category.vendorType,
          ),
        );
      }
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  categorySelected(Category subcategory) async {
    bool isAllOrOthers =
        subcategory.name == "All".tr() || subcategory.name == "Others".tr();
    final search = Search(
      vendorType: category.vendorType,
      category: isAllOrOthers ? category : null,
      subcategory: isAllOrOthers ? null : subcategory,
      showProductsTag: !(category.vendorType?.isService ?? false),
      showVendorsTag: !(category.vendorType?.isService ?? false),
      showServicesTag: (category.vendorType?.isService ?? false),
      showProvidesTag: (category.vendorType?.isService ?? false),
    );
    final page = NavigationService().searchPageWidget(search);

    viewContext.nextPage(page);
  }

  void onKeywordChanged(String keyword) {
    searchKeywordStream.add(keyword);
    notifyListeners();
  }
}
