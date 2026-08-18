import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/search.vm.dart';
import 'package:fuodz/widgets/custom_dynamic_grid_view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/commerce_product.list_item.dart';
import 'package:fuodz/widgets/list_items/grid_view_service.list_item.dart';
import 'package:fuodz/widgets/list_items/grocery_product.list_item.dart';
import 'package:fuodz/widgets/list_items/horizontal_product.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor.list_item.dart';
import 'package:fuodz/widgets/states/search.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SubcategoryItemsView extends StatefulWidget {
  const SubcategoryItemsView({
    required this.category,
    this.subcategory,
    this.searchStream,
    Key? key,
  }) : super(key: key);

  final Category category;
  final Category? subcategory;
  final Stream<String>? searchStream;

  @override
  _SubcategoryItemsViewState createState() => _SubcategoryItemsViewState();
}

class _SubcategoryItemsViewState extends State<SubcategoryItemsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription? searchStreamSubscription;
  SearchViewModel? model;

  @override
  void dispose() {
    super.dispose();
    searchStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //
    final isAllOrOthers =
        widget.subcategory == null ||
        widget.subcategory!.name == "All".tr() ||
        widget.subcategory!.name == "Others".tr();

    final search = Search(
      vendorType: widget.category.vendorType,
      category: isAllOrOthers ? widget.category : null,
      subcategory: isAllOrOthers ? null : widget.subcategory,
      showProductsTag: !(widget.category.vendorType?.isService ?? false),
      showVendorsTag: !(widget.category.vendorType?.isService ?? false),
      showServicesTag: (widget.category.vendorType?.isService ?? false),
      showProvidesTag: (widget.category.vendorType?.isService ?? false),
    );

    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(context, search),
      onViewModelReady: (vm) {
        model = vm;
        vm.startSearch();

        //search stream listener
        searchStreamSubscription = widget.searchStream?.listen((keyword) {
          vm.keyword = keyword;
          vm.startSearch();
        });
      },
      builder: (context, model, child) {
        return VStack([
          //result listview
          if (!model.showGrid)
            CustomListView(
              refreshController: model.refreshController,
              canRefresh: true,
              canPullUp: true,
              onRefresh: model.startSearch,
              onLoading: () => model.startSearch(initialLoaoding: false),
              isLoading: model.isBusy,
              padding: EdgeInsets.all(12),
              dataSet: model.searchResults,
              itemBuilder: (context, index) {
                //
                final searchResult = model.searchResults[index];
                if (searchResult is Product) {
                  //grocery product list item
                  if (searchResult.vendor.vendorType.isGrocery) {
                    return GroceryProductListItem(
                      product: searchResult,
                      onPressed: model.productSelected,
                      qtyUpdated: model.addToCartDirectly,
                    );
                  } else if (searchResult.vendor.vendorType.isCommerce) {
                    return CommerceProductListItem(searchResult, height: 80);
                  } else {
                    //regular views
                    return HorizontalProductListItem(
                      searchResult,
                      onPressed: model.productSelected,
                      qtyUpdated: model.addToCartDirectly,
                      padding: 0,
                    );
                  }
                } else if (searchResult is Service) {
                  return GridViewServiceListItem(
                    service: searchResult,
                    onPressed: model.servicePressed,
                  );
                } else {
                  return VendorListItem(
                    vendor: searchResult,
                    onPressed: model.vendorSelected,
                  );
                }
              },
              separatorBuilder: (context, index) => 10.heightBox,
              emptyWidget: EmptySearch(),
            ).expand(),

          //result gridview
          if (model.showGrid)
            CustomDynamicHeightGridView(
              noScrollPhysics: true,
              refreshController: model.refreshController,
              canRefresh: true,
              canPullUp: true,
              onRefresh: model.startSearch,
              onLoading: () => model.startSearch(initialLoaoding: false),
              isLoading: model.isBusy,
              itemCount: model.searchResults.length,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                //
                final searchResult = model.searchResults[index];
                if (searchResult is Product) {
                  //regular views
                  return CommerceProductListItem(searchResult, height: 80);
                } else if (searchResult is Service) {
                  return GridViewServiceListItem(
                    service: searchResult,
                    onPressed: model.servicePressed,
                  );
                } else {
                  return VendorListItem(
                    vendor: searchResult,
                    onPressed: model.vendorSelected,
                  );
                }
              },
              separatorBuilder:
                  (context, index) => UiSpacer.verticalSpace(space: 10),
              emptyWidget: EmptySearch(),
            ).expand(),
        ]);
      },
    );
  }
}
