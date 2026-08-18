import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/main_search.vm.dart';
import 'package:fuodz/views/pages/search/widget/property_search_result.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'widget/product_search_result.view.dart';
import 'widget/search.header.dart';
import 'widget/service_search_result.view.dart';
import 'widget/vendor_search_result.view.dart';

class MainSearchPage extends StatelessWidget {
  const MainSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainSearchViewModel>.reactive(
      viewModelBuilder: () => MainSearchViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          allowTopSafeArea: true,
          body: VStack([
            //header
            UiSpacer.verticalSpace(),
            SearchHeader(vm, showCancel: false),
            //if by location is enabled and results are empty, show a disclaimer
            Visibility(
              visible:
                  (vm.search?.byLocation ?? true) &&
                  vm.searchResults.isEmpty &&
                  !vm.isBusy,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: HStack([
                  Icon(
                    Icons.info_outline,
                    color: AppColor.primaryColor,
                    size: 20,
                  ),
                  10.widthBox,
                  "Results are currently based on your location. You can disable this in the filter section."
                      .tr()
                      .text
                      .color(AppColor.primaryColor)
                      .make()
                      .expand(),
                ], crossAlignment: CrossAxisAlignment.start),
              ).py(10),
            ),
            //tab-
            LoadingIndicator(
              loading: vm.isBusy,
              child:
                  ContainedTabBarView(
                    callOnChangeWhileIndexIsChanging: true,
                    tabBarProperties: TabBarProperties(
                      alignment: TabBarAlignment.start,
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),

                      //
                      // padding: EdgeInsets.all(0),
                      labelColor: AppColor.primaryColor,
                      unselectedLabelColor: Utils.textColorByTheme(true),
                      labelStyle: context.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      // unselectedLabelStyle:
                      //     context.textTheme.bodyLarge!.copyWith(),
                      indicatorWeight: 4,
                      indicator: BoxDecoration(
                        // color: Colors.red,
                        border: Border(
                          bottom: BorderSide(
                            color: context.theme.primaryColor,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    tabs: [
                      //
                      if (vm.showVendors)
                        Tab(child: "Vendors".tr().text.make()),
                      //
                      if (vm.showProducts)
                        Tab(child: "Products".tr().text.make()),
                      //
                      if (vm.showServices)
                        Tab(child: "Services".tr().text.make()),
                      if (vm.showProperties)
                        Tab(child: "Properties".tr().text.make()),
                    ],
                    views: [
                      if (vm.showVendors) VendorSearchResultView(vm),
                      //
                      if (vm.showProducts) ProductSearchResultView(vm),
                      //
                      if (vm.showServices) ServiceSearchResultView(vm),
                      //
                      if (vm.showProperties) PropertySearchResultView(vm),
                    ],
                    // onChange: vm.onTabChange,
                  ).expand(),
            ),
          ]).px(16),
        );
      },
    );
  }
}
