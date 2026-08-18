import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/booking.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/featured_property.list_item.dart';
import 'package:fuodz/widgets/list_items/property.list_item.dart';
import 'package:fuodz/widgets/list_items/property_type.list_item.dart';
import 'package:fuodz/widgets/states/alternative.view.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BookingPage extends StatefulWidget {
  const BookingPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with AutomaticKeepAliveClientMixin<BookingPage> {
  GlobalKey pageKey = GlobalKey<State>();
  bool showBannersView = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryThemeColor = Utils.textColorByPrimaryColor();
    return ViewModelBuilder<BookingViewModel>.reactive(
      viewModelBuilder: () => BookingViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          key: pageKey,
          backgroundColor: context.theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: context.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: !AppStrings.isSingleVendorMode,
            leading:
                !AppStrings.isSingleVendorMode
                    ? IconButton(
                      icon: Icon(
                        !Utils.isArabic
                            ? FlutterIcons.arrow_left_fea
                            : FlutterIcons.arrow_right_fea,
                        color: primaryThemeColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                    : null,
            title:
                widget.vendorType.name.text
                    .color(primaryThemeColor)
                    .semiBold
                    .make(),
            centerTitle: true,
          ),
          body: SmartRefresher(
            controller: model.refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: model.onRefresh,
            onLoading: model.onLoadMore,
            child: VStack([
              // Intro & Search section
              VStack([
                "Discover your next stay"
                    .tr()
                    .text
                    .xl3
                    .bold
                    .color(primaryThemeColor)
                    .make()
                    .px16(),
                20.heightBox,
                HStack([
                  HStack([
                        Icon(Icons.search, size: 20, color: Colors.grey),
                        10.widthBox,
                        VStack([
                          "Where to?".tr().text.semiBold.size(14).make(),
                          "Anywhere • Any week • Add guests"
                              .tr()
                              .text
                              .gray500
                              .size(12)
                              .make(),
                        ]),
                      ])
                      .p(12)
                      .box
                      .color(context.backgroundColor)
                      .withRounded(value: 30)
                      .shadowSm
                      .make()
                      .onTap(() {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.propertySearchRoute,
                          arguments: widget.vendorType,
                        );
                      })
                      .expand(),
                ]).px16(),
                20.heightBox,
              ]).box.color(context.primaryColor).make(),

              // Banners
              if (showBannersView)
                Banners(
                  model.vendorType,
                  onEmpty: () {
                    if (mounted) {
                      setState(() {
                        showBannersView = false;
                      });
                    }
                  },
                ).py(10),

              // Featured properties
              if (!model.busy(model.featuredProperties) &&
                  model.featuredProperties.isNotEmpty)
                LoadingShimmer(
                  loading: model.busy(model.featuredProperties),
                  child: VStack([
                    "Featured".tr().text.xl.bold.make().px16(),
                    10.heightBox,
                    HStack(
                      [
                        ...model.featuredProperties.map((property) {
                          return FeaturedPropertyListItem(property: property);
                        }).toList(),
                      ],
                      spacing: Sizes.paddingSizeDefault,
                      alignment: MainAxisAlignment.start,
                      crossAlignment: CrossAxisAlignment.start,
                    ).px(Sizes.paddingSizeDefault).scrollHorizontal(),
                  ]),
                ).py(10),

              // Property Types (Categories)
              LoadingShimmer(
                loading: model.busy(model.propertyTypes),
                child: AlternativeView(
                  ismain: model.propertyTypes.isNotEmpty,
                  main: HStack(
                        model.propertyTypes.map((type) {
                          return PropertyTypeListItem(
                            propertyType: type,
                            isSelected:
                                model.selectedPropertyType?.id == type.id,
                            onPressed: model.onPropertyTypeSelected,
                          );
                        }).toList(),
                        spacing: Sizes.paddingSizeDefault,
                      )
                      .px(Sizes.paddingSizeDefault)
                      .scrollHorizontal(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.paddingSizeDefault,
                          vertical: 12,
                        ),
                      ),
                  alt: VStack([
                    Icon(Icons.error, color: Colors.red, size: 50),
                    "No Property Type Found".tr().text.makeCentered(),
                  ], crossAlignment: CrossAxisAlignment.center).p(20),
                ),
              ),

              // Properties List
              LoadingShimmer(
                loading: model.busy(model.properties),
                child: CustomListView(
                  dataSet: model.properties,
                  noScrollPhysics: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  itemBuilder: (context, index) {
                    return PropertyListItem(property: model.properties[index]);
                  },
                  emptyWidget:
                      (!model.isBusy &&
                              !model.busy(model.propertyTypes) &&
                              !model.busy(model.properties) &&
                              model.properties.isEmpty)
                          ? Padding(
                            padding: const EdgeInsets.all(
                              Sizes.paddingSizeDefault,
                            ),
                            child: VStack(
                              [
                                //img,title,description
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedHouse01,
                                  size: 50,
                                  color: context.primaryColor,
                                ),
                                10.heightBox,
                                "No Properties Found"
                                    .tr()
                                    .text
                                    .center
                                    .xl
                                    .semiBold
                                    .makeCentered(),
                                "No properties found for this property type. Please try another property type."
                                    .tr()
                                    .text
                                    .center
                                    .makeCentered(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                              alignment: MainAxisAlignment.center,
                            ),
                          )
                          : 0.heightBox,
                ),
              ),
            ], spacing: Sizes.paddingSizeDefault),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
