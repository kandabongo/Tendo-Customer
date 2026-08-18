import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/favourites.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/dynamic_product.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor.list_item.dart';
import 'package:fuodz/widgets/states/error.state.dart';
import 'package:fuodz/widgets/states/product.empty.dart';
import 'package:fuodz/widgets/states/vendor.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FavouritesViewModel>.reactive(
      viewModelBuilder: () => FavouritesViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        Color themeTextColor = Utils.textColorByPrimaryColor();
        return DefaultTabController(
          length: 2,
          child: BasePage(
            showAppBar: true,
            showLeadingAction: true,
            title: "Favourites".tr(),
            isLoading: vm.isBusy,
            body: ContainedTabBarView(
              tabBarProperties: TabBarProperties(
                isScrollable: true,
                alignment: TabBarAlignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.paddingSizeDefault,
                ),
                labelPadding: EdgeInsets.symmetric(
                  horizontal: Sizes.paddingSizeLarge,
                  vertical: 0,
                ),
                labelColor: themeTextColor,
                unselectedLabelColor: themeTextColor.withOpacity(0.85),
                labelStyle: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                background: Container(
                  color: AppColor.primaryColor,
                ),
                indicatorWeight: 4,
                indicator: BoxDecoration(
                  // color: Colors.red,
                  border: Border(
                    bottom: BorderSide(
                      color: themeTextColor,
                      width: 3,
                    ),
                  ),
                ),
              ),
              tabs: [
                Tab(text: "Proucts".tr()),
                Tab(text: "Vendors".tr()),
              ],
              views: [
                //
                CustomListView(
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  dataSet: vm.products,
                  isLoading: vm.busy(vm.products),
                  emptyWidget: EmptyProduct(
                    description:
                        "Your favorite products/items will appear here. Start exploring and add products/items to your favorites!"
                            .tr(),
                  ).p(Sizes.paddingSizeLarge),
                  errorWidget: LoadingError(
                    onrefresh: vm.fetchProducts,
                  ),
                  itemBuilder: (context, index) {
                    final product = vm.products[index];
                    return DynamicProductListItem(
                      product,
                      padding: EdgeInsets.zero,
                      onPressed: vm.openProductDetails,
                      // qtyUpdated: vm.addToCartDirectly,
                    ).onLongPress(
                      () => vm.removeFavourite(product),
                      GlobalKey(),
                    );
                  },
                  separatorBuilder: (_, __) => 10.heightBox,
                ),
                //
                CustomListView(
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  dataSet: vm.vendors,
                  isLoading: vm.busy(vm.vendors),
                  emptyWidget: EmptyVendor(
                    description:
                        "Your favorite vendors will appear here. Start exploring and add vendors to your favorites!"
                            .tr(),
                  ).p(Sizes.paddingSizeLarge),
                  errorWidget: LoadingError(
                    onrefresh: vm.fetchVendors,
                  ),
                  itemBuilder: (context, index) {
                    final vendor = vm.vendors[index];
                    return VendorListItem(
                      vendor: vendor,
                      onPressed: vm.openVendorDetails,
                    ).onLongPress(
                      () => vm.removeFavouriteVendor(vendor),
                      GlobalKey(),
                    );
                  },
                  separatorBuilder: (_, __) => 10.heightBox,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
