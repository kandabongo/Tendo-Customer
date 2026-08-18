import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/parcel_vendor_details_page.vm.dart';
import 'package:fuodz/views/pages/parcel/new_parcel.page.dart';
import 'package:fuodz/views/pages/parcel/widgets/parcel_Vendor_areas_of_operation.dart';
import 'package:fuodz/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:fuodz/widgets/buttons/custom_leading.dart';
import 'package:fuodz/widgets/cards/package_type_pricing.card.dart';
import 'package:fuodz/widgets/collapsing_sliver_appbar.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ParcelVendorDetailsPage extends StatefulWidget {
  const ParcelVendorDetailsPage({required this.vendor, Key? key})
    : super(key: key);
  final Vendor vendor;

  @override
  State<ParcelVendorDetailsPage> createState() =>
      _ParcelVendorDetailsPageState();
}

class _ParcelVendorDetailsPageState extends State<ParcelVendorDetailsPage> {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ViewModelBuilder<ParcelVendorDetailsPageViewModel>.reactive(
        viewModelBuilder:
            () => ParcelVendorDetailsPageViewModel(this.widget.vendor),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _newParcelBookingPressed,
              label: "New Order".text.make(),
              icon: Icon(FlutterIcons.package_fea),
            ),
            body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (
                BuildContext context,
                bool innerBoxIsScrolled,
              ) {
                return <Widget>[
                  // SliverToBoxAdapter(
                  //   child: VendorDetailsHeader(vm, showSearch: false),
                  // ),
                  // Transparent AppBar with only leading
                  CollapsingSliverAppBar(
                    scrollController: _scrollController,
                    expandedBgColor: Colors.transparent,
                    collapsedBgColor: AppColor.primaryColor,
                    leading: CustomLeading(),
                    expandedHeight: 360,
                    collapseThreshold: 240,
                    flexibleChild: VendorDetailsHeader(vm, showSearch: false),
                  ),

                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        tabAlignment: TabAlignment.fill,
                        labelColor: Utils.textColorByPrimaryColor(),
                        // unselectedLabelColor: context.colors.onSurface,
                        indicatorColor: AppColor.primaryColorDark,
                        indicatorWeight: 5,
                        tabs: [
                          Tab(text: "Package Types Pricing".tr()),
                          Tab(text: 'Areas of Operation'.tr()),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  // Package Pricing Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(Sizes.paddingSizeDefault),
                    child: CustomListView(
                      isLoading: vm.isBusy || vm.busy(vm.pricings),
                      dataSet: vm.pricings,
                      padding: EdgeInsets.all(0),
                      noScrollPhysics: true,
                      itemBuilder: (context, index) {
                        final pricing = vm.pricings[index];
                        final imgSize = context.percentWidth * 15;
                        final imgHeight = context.percentHeight * 5;
                        return Container(
                          padding: const EdgeInsets.all(
                            Sizes.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(
                              Sizes.radiusSmall,
                            ),
                            border: Border.all(color: Colors.grey.shade300),
                          ),

                          child: VStack([
                            HStack(
                              [
                                CustomImage(
                                  imageUrl: pricing.package_type?.photo,
                                  boxFit: BoxFit.contain,
                                  width: imgSize,
                                  height: imgHeight,
                                ),
                                //
                                VStack([
                                  "${pricing.package_type?.name}"
                                      .text
                                      .xl
                                      .semiBold
                                      .make(),
                                  "${pricing.package_type?.description}".text
                                      .make(),
                                ]).expand(),
                              ],
                              spacing: 20,
                              crossAlignment: CrossAxisAlignment.start,
                              alignment: MainAxisAlignment.start,
                            ),
                            PackageTypePricingCardInfo(pricing: pricing),
                          ], spacing: Sizes.paddingSizeSmall),
                        );
                      },
                    ),
                  ),

                  // Areas of Operation Tab
                  SingleChildScrollView(
                    child: LoadingIndicator(
                      loading: vm.busy("getVendorAreaOfOperations"),
                      child: AreasOfOperationWidget(
                        countries: vm.countries,
                        states: vm.states,
                        cities: vm.cities,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _newParcelBookingPressed() async {
    await AlertService.warning(
      title: "Vendor availability notice".tr(),
      text:
          "You're being redirected to the booking page.".tr() +
          "\n" +
          "\n" +
          "Available vendors will be shown based on your selected package type and delivery locations."
              .tr()
              .tr() +
          "\n" +
          "\n" +
          "If the vendor you came from supports your route, they’ll appear in the list."
              .tr(),
    );

    //
    AppService().navigatorKey.currentContext!.push((context) {
      return NewParcelPage(widget.vendor.vendorType);
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColor.primaryColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
