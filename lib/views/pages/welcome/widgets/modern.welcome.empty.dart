import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/pages/welcome/widgets/welcome_header.section.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/list_items/modern_vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:fuodz/widgets/states/vendor_type.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernEmptyWelcome extends StatelessWidget {
  const ModernEmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack([
      //
      WelcomeHeaderSection(vm),
      VStack([
            //finance section
            if (HomeScreenConfig.showWalletOnHomeScreen && vm.isAuthenticated())
              WalletManagementView(),

            //top banner
            if ((HomeScreenConfig.showBannerOnHomeScreen &&
                HomeScreenConfig.isBannerPositionTop))
              Banners(null, featured: true, padding: 0),
            //
            VStack([
              //gridview
              if (HomeScreenConfig.isVendorTypeListingGridView &&
                  vm.showGrid &&
                  vm.shouldShowVendorTypesLoading)
                LoadingShimmer().px20().centered(),

              CustomVisibilty(
                visible:
                    HomeScreenConfig.isVendorTypeListingGridView &&
                    vm.showGrid &&
                    vm.shouldShowEmptyVendorTypes,
                child:
                    EmptyVendorTypes(
                      onRetry: () => vm.initialise(initial: false),
                    ).py20(),
              ),

              CustomVisibilty(
                visible:
                    HomeScreenConfig.isVendorTypeListingGridView &&
                    vm.showGrid &&
                    !vm.isBusy &&
                    vm.vendorTypes.isNotEmpty,
                child: AnimationLimiter(
                  child: MasonryGrid(
                    column: HomeScreenConfig.vendorTypePerRow,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: List.generate(vm.vendorTypes.length, (index) {
                      final vendorType = vm.vendorTypes[index];
                      return ModernVendorTypeVerticalListItem(
                        vendorType,
                        onPressed: () {
                          NavigationService.pageSelected(
                            vendorType,
                            context: context,
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ]).px20(),

            //botton banner
            if (HomeScreenConfig.showBannerOnHomeScreen &&
                !HomeScreenConfig.isBannerPositionTop)
              Banners(null, featured: true),

            //featured vendors
            // FeaturedVendorsView(
            //   title: "Featured Vendors".tr(),
            //   scrollDirection: Axis.horizontal,
            //   itemWidth: context.percentWidth * 48,
            //   listViewPadding: Vx.mSymmetric(h: 20),
            //   titlePadding: Vx.(h: 20, v: 6),
            //   onSeeAllPressed: () {
            //     vm.openFeaturedVendors();
            //   },
            //   onVendorSelected: (vendor) {
            //     NavigationService.openVendorDetailsPage(
            //       vendor,
            //       context: context,
            //     );
            //   },
            // ),
            SectionVendorsView(
              null,
              title: "Featured Vendors".tr(),
              scrollDirection: Axis.horizontal,
              type: SearchFilterType.featured,
              itemWidth: context.percentWidth * 48,
              byLocation: AppStrings.enableFatchByLocation,
              hideEmpty: true,
              titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemsPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
            //featured products
            SectionProductsView(
              null,
              title: "Featured Products".tr(),
              scrollDirection: Axis.horizontal,
              type: ProductFetchDataType.featured,
              itemWidth: context.percentWidth * 42,
              byLocation: AppStrings.enableFatchByLocation,
              hideEmpty: true,
              itemsPadding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              listHeight: context.percentHeight * 20,
            ),
            //spacing
            100.heightBox,
          ], spacing: 16)
          .scrollVertical()
          .box
          .color(context.theme.colorScheme.surface)
          .make()
          .expand(),
    ]);
  }
}
