import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/service.vm.dart';
import 'package:fuodz/views/pages/service/widgets/modern_category_gridview.list_item.dart';
import 'package:fuodz/views/pages/service/widgets/modern_service_gridview.list_item.dart';
import 'package:fuodz/views/pages/vendor/widgets/simple_styled_banners.view.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ServicesPage extends StatefulWidget {
  ServicesPage(this.vendorType);

  final VendorType vendorType;

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ServiceViewModel>.reactive(
      viewModelBuilder: () => ServiceViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: context.backgroundColor.withOpacity(0.97),
          body: CustomScrollView(
            slivers: [
              // Custom App Bar with Search and Location
              SliverAppBar(
                expandedHeight: 160 + Sizes.paddingSizeDefault,
                floating: false,
                pinned: true,
                backgroundColor: context.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: context.textTheme.bodyLarge!.color!,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.fromLTRB(60, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            'Find %s'
                                .tr()
                                .fill([widget.vendorType.name])
                                .text
                                .bold
                                .size(AppTextSizes.xl)
                                .make(),
                            Spacer(),
                          ],
                        ),
                        Sizes.paddingSizeDefault.heightBox,
                        _buildLocationInAppBar(vm),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Container(
                    padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                    child: _buildSearchBar(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SimpleStyledBanners(
                  widget.vendorType,
                  height: AppStrings.bannerHeight,
                  withPadding: false,
                  viewportFraction: 0.92,
                  hideEmpty: true,
                ),
              ),

              SliverToBoxAdapter(child: Sizes.paddingSizeDefault.heightBox),

              // Categories Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  child: _buildCategoriesGrid(vm),
                ),
              ),

              // Trending Services
              if (vm.busy(vm.trendingServices) ||
                  (!vm.busy(vm.trendingServices) &&
                      vm.trendingServices.isNotEmpty)) ...[
                SliverToBoxAdapter(child: Sizes.paddingSizeDefault.heightBox),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                    child: _buildTrendingServices(vm),
                  ),
                ),
              ],

              // Featured Providers
              if (vm.busy(vm.featuredProviders) ||
                  (!vm.busy(vm.featuredProviders) &&
                      vm.featuredProviders.isNotEmpty)) ...[
                SliverToBoxAdapter(child: Sizes.paddingSizeDefault.heightBox),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.paddingSizeDefault,
                    ),
                    child: _buildFeaturedProviders(vm),
                  ),
                ),
              ],

              // Services by Category
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  child: _buildServicesByCategory(vm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          NavigationService.openServiceSearch(
            context,
            vendorType: widget.vendorType,
            showVendors: true,
            showServices: true,
          );
        },
        decoration: InputDecoration(
          hintText: 'Search for services...'.tr(),
          hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.black45, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLocationInAppBar(ServiceViewModel vm) {
    return StreamBuilder<DeliveryAddress?>(
      stream: LocationService.currenctDeliveryAddressSubject,
      initialData: LocationService.deliveryaddress,
      builder: (context, snapshot) {
        return HStack([
          Icon(
            Icons.location_on,
            color: context.primaryColor,
            size: AppIconSizes.sm,
          ),

          "${snapshot.data?.address}".text.medium
              .size(AppTextSizes.md)
              .maxLines(1)
              .ellipsis
              .make()
              .expand(),
          TextButton(
            onPressed: () {
              vm.pickDeliveryAddress(
                vendorCheckRequired: false,
                onselected: vm.initialise,
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child:
                'Change'
                    .tr()
                    .text
                    .color(context.primaryColor)
                    .semiBold
                    .size(AppTextSizes.sm)
                    .make(),
          ),
        ], spacing: Sizes.paddingSizeSmall);
      },
    );
  }

  Widget _buildCategoriesGrid(ServiceViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HStack([
          'Browse Categories'.tr().text.bold.size(AppTextSizes.lg).make(),
          Spacer(),
          TextButton(
            onPressed: () {
              NavigationService.openCategoriesPage(vendorType: vm.vendorType);
            },
            child: Text(
              'View All'.tr(),
              style: TextStyle(color: context.primaryColor),
            ),
          ),
        ]),
        // SizedBox(height: 16),
        LoadingShimmer(
          loading: vm.busy(vm.categories),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: vm.categories.length,
            itemBuilder: (context, index) {
              final category = vm.categories[index];
              return ModernCategoryGridviewListItem(
                category: category,
                onPressed: vm.categorySelected,
              );
            },
          ),
        ),
      ],
      spacing: Sizes.paddingSizeSmall,
    );
  }

  Widget _buildTrendingServices(ServiceViewModel vm) {
    return VStack(
      [
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            'Trending This Week'.tr().text.bold.size(AppTextSizes.lg).make(),
          ],
        ),

        LoadingShimmer(
          loading: vm.busy(vm.trendingServices),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: vm.trendingServices.length,
            itemBuilder: (context, index) {
              final service = vm.trendingServices[index];
              return ModernServiceGridviewListItem(service: service);
            },
          ),
        ),
      ],
      spacing: Sizes.paddingSizeSmall,
      crossAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _buildFeaturedProviders(ServiceViewModel vm) {
    return VStack(
      [
        'Featured Service Providers'
            .tr()
            .text
            .size(AppTextSizes.md)
            .bold
            .make(),
        VStack(
          vm.featuredProviders.map((provider) {
            return GestureDetector(
              onTap: () {
                //
                NavigationService.openVendorDetailsPage(
                  provider,
                  context: context,
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.primaryColor.swatch.shade400,
                            context.primaryColor.swatch.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          provider.name
                              .substring(0, 2)
                              .toUpperCase()
                              .text
                              .bold
                              .color(Utils.textColorByPrimaryColor())
                              .size(AppTextSizes.md)
                              .makeCentered(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          provider.name.text.semiBold
                              .size(AppTextSizes.md)
                              .make(),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              '${provider.rating} (${provider.reviews_count} %s)'
                                  .fill(["reviews".tr()])
                                  .text
                                  .color(Vx.zinc400)
                                  .size(AppTextSizes.sm)
                                  .make(),
                            ],
                          ),
                          SizedBox(height: 6),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black26,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
      crossAlignment: CrossAxisAlignment.start,
      spacing: Sizes.paddingSizeSmall,
    );
  }

  Widget _buildServicesByCategory(ServiceViewModel vm) {
    return VStack(
      [
        'Popular Services'.tr().text.bold.size(AppTextSizes.lg).make(),
        Column(
          children:
              vm.serviceByCategories.map((category) {
                return LoadingShimmer(
                  loading: vm.busy(category.id),
                  child:
                      category.services.isEmpty
                          ? 0.squareBox
                          : Container(
                            margin: EdgeInsets.only(
                              bottom: Sizes.paddingSizeDefault,
                            ),
                            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                Sizes.radiusLarge,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Vx.hexToColor(
                                          category.color,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SizedBox(
                                        width: AppIconSizes.lg,
                                        height: AppIconSizes.lg,
                                        child: CustomImage(
                                          imageUrl: category.imageUrl,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    category.name.text
                                        .size(AppTextSizes.sm)
                                        .semiBold
                                        .make(),

                                    Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        NavigationService.openServiceSearch(
                                          context,
                                          category: category,
                                          vendorType: vm.vendorType,
                                          showVendors: false,
                                          showServices: true,
                                        );
                                      },
                                      child: Text(
                                        'View All'.tr(),
                                        style: TextStyle(
                                          color: Vx.hexToColor(category.color),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Sizes.paddingSizeDefault),
                                Column(
                                  children:
                                      category.services.map((service) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(
                                            Sizes.paddingSizeDefault,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              Sizes.radiusDefault,
                                            ),
                                          ),
                                          child: HStack([
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  service.name.text
                                                      .size(AppTextSizes.sm)
                                                      .make(),

                                                  SizedBox(height: 4),
                                                  HStack(
                                                    [
                                                      if (service
                                                          .durationText
                                                          .isNotEmpty)
                                                        ('${service.durationText} • ' +
                                                                '${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}'
                                                                    .currencyFormat())
                                                            .text
                                                            .size(
                                                              AppTextSizes.sm,
                                                            )
                                                            .make(),
                                                      '${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}'
                                                          .currencyFormat()
                                                          .text
                                                          .semiBold
                                                          .size(AppTextSizes.sm)
                                                          .make(),
                                                    ],
                                                    spacing:
                                                        Sizes.paddingSizeSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                NavigationService.openServiceDetails(
                                                  service,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      Sizes.paddingSizeDefault,
                                                  vertical:
                                                      Sizes.paddingSizeSmall,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Vx.hexToColor(
                                                    category.color,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Sizes.radiusLarge,
                                                      ),
                                                ),
                                                child: Text(
                                                  'View Now'.tr(),
                                                  style: TextStyle(
                                                    color:
                                                        Utils.textColorByColor(
                                                          Vx.hexToColor(
                                                            category.color,
                                                          ),
                                                        ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ], spacing: Sizes.paddingSizeDefault),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                );
              }).toList(),
        ),
      ],
      crossAlignment: CrossAxisAlignment.start,
      spacing: Sizes.paddingSizeSmall,
    );
  }
}
