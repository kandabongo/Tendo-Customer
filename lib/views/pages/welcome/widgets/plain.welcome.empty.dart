import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/shared/widgets/section_coupons.view.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/list_items/plain_vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:fuodz/widgets/states/vendor_type.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'plain_welcome_header.section.dart';

class PlainEmptyWelcome extends StatefulWidget {
  const PlainEmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;

  @override
  State<PlainEmptyWelcome> createState() => _PlainEmptyWelcomeState();
}

class _PlainEmptyWelcomeState extends State<PlainEmptyWelcome> {
  double headerHeight = 200;
  //
  @override
  Widget build(BuildContext context) {
    //
    return Stack(
      children: [
        //
        MeasureSize(
          onChange: (size) {
            setState(() {
              headerHeight = size.height;
              if (headerHeight > 100) {
                headerHeight -= 130;
              }
            });
          },
          child: PlainWelcomeHeaderSection(widget.vm),
        ),
        UiSpacer.vSpace(),
        VStack([
          //
          VStack([
            UiSpacer.vSpace(),
            "Our services"
                .tr()
                .text
                .bold
                .xl2
                .color(Utils.textColorByTheme())
                .make(),
            UiSpacer.vSpace(),
            //gridview
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView &&
                  widget.vm.showGrid &&
                  widget.vm.shouldShowVendorTypesLoading,
              child: LoadingShimmer().px20().centered(),
            ),
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView &&
                  widget.vm.showGrid &&
                  widget.vm.shouldShowEmptyVendorTypes,
              child:
                  EmptyVendorTypes(
                    onRetry: () => widget.vm.initialise(initial: false),
                  ).py20(),
            ),
            CustomVisibilty(
              visible:
                  HomeScreenConfig.isVendorTypeListingGridView &&
                  widget.vm.showGrid &&
                  !widget.vm.isBusy &&
                  widget.vm.vendorTypes.isNotEmpty,
              child: AnimationLimiter(
                child: MasonryGrid(
                  column: HomeScreenConfig.vendorTypePerRow,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: List.generate(widget.vm.vendorTypes.length, (
                    index,
                  ) {
                    final vendorType = widget.vm.vendorTypes[index];
                    return PlainVendorTypeVerticalListItem(
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

          //coupons
          SectionCouponsView(
            null,
            title: "Promo".tr(),
            scrollDirection: Axis.horizontal,
            itemWidth: context.percentWidth * 70,
            height: 100,
            itemsPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            bPadding: 10,
          ),
          //featured vendors
          SectionVendorsView(
            null,
            title: "Featured Vendors".tr(),
            scrollDirection: Axis.horizontal,
            type: SearchFilterType.featured,
            itemWidth: context.percentWidth * 48,
            byLocation: AppStrings.enableFatchByLocation,
            hideEmpty: true,
            titlePadding: EdgeInsets.all(12),
            itemsPadding: EdgeInsets.symmetric(horizontal: 12),
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
            itemsPadding: EdgeInsets.fromLTRB(12, 0, 12, 5),
            listHeight: context.percentHeight * 20,
          ),
          //spacing
          UiSpacer.vSpace(100),
        ], spacing: 10).pOnly(top: headerHeight),
      ],
    ).scrollVertical();
  }
}
