import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/view_models/property_search.vm.dart';
import 'package:fuodz/widgets/custom_list_view.dart';

import 'package:fuodz/widgets/list_items/property.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:jiffy/jiffy.dart';
import 'package:fuodz/constants/app_images.dart';

class PropertySearchPage extends StatelessWidget {
  const PropertySearchPage({required this.vendorType, Key? key})
    : super(key: key);

  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertySearchViewModel>.reactive(
      viewModelBuilder: () => PropertySearchViewModel(context, vendorType),

      onViewModelReady: (model) {
        model.initialise();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          model.openFilter();
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: context.theme.colorScheme.surface,
            surfaceTintColor: context.backgroundColor,
            elevation: 0,
            // Search Info Header
            title:
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  color: context.backgroundColor,
                  child: VStack([
                    // Location
                    if (model.searchTEC.text.isNotEmpty) ...[
                      HStack([
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        5.widthBox,
                        model.searchTEC.text.text.sm.semiBold
                            .maxLines(1)
                            .ellipsis
                            .make()
                            .expand(),
                      ]),
                      5.heightBox,
                    ],

                    HStack([
                      // Date
                      if (model.checkInDate != null &&
                          model.checkOutDate != null)
                        HStack([
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          5.widthBox,
                          "${Jiffy.parseFromDateTime(model.checkInDate!).format(pattern: "MMM do")} - ${Jiffy.parseFromDateTime(model.checkOutDate!).format(pattern: "MMM do")}"
                              .text
                              .xs
                              .medium
                              .make(),
                        ]).expand(),

                      // Guests
                      if (model.minGuests != null && model.minGuests! > 0)
                        HStack([
                          Icon(Icons.person, size: 14, color: Colors.grey),
                          5.widthBox,
                          "${model.minGuests} ${"Guests".tr()}".text.xs.medium
                              .make(),
                        ]),
                    ]),
                  ]),
                ).box.green100.make(),

            iconTheme: IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: Icon(Feather.sliders),
                onPressed: model.openFilter,
              ),
            ],
          ),
          body:
              !model.hasStartedSearch
                  ? VStack([
                    // Clean State Before Search
                    Image.asset(AppImages.locationGif).h(200).centered(),
                    "Let's find your perfect stay"
                        .tr()
                        .text
                        .xl2
                        .semiBold
                        .make()
                        .centered(),
                    5.heightBox,
                    "Start by setting your preferences in the filter"
                        .tr()
                        .text
                        .gray500
                        .center
                        .make()
                        .centered()
                        .px16(),

                    20.heightBox,
                    OutlinedButton(
                      onPressed: model.openFilter,
                      child: "Open Search Filters".tr().text.make(),
                    ).centered(),
                  ]).p20().centered()
                  : CustomListView(
                    refreshController: model.refreshController,
                    canPullUp: true,
                    canRefresh: true,
                    onRefresh: model.startSearch,
                    onLoading: () => model.startSearch(initial: false),
                    isLoading: model.isBusy,
                    dataSet: model.properties,
                    padding: const EdgeInsets.all(Sizes.paddingSizeDefault),
                    separatorBuilder:
                        (_, __) => Sizes.paddingSizeSmall.heightBox,
                    itemBuilder: (context, index) {
                      return PropertyListItem(
                        property: model.properties[index],
                        onPressed: (p) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.propertyDetailsRoute,
                            arguments: p,
                          );
                        },
                      );
                    },
                    emptyWidget:
                        model.anyObjectsBusy || model.isBusy
                            ? 0.squareBox
                            : EmptyState(
                              title: "No Property Found".tr(),
                              description:
                                  "Please adjust your filter options to see property"
                                      .tr(),
                              showImage: true,
                            ).p20().centered(),
                  ),
        );
      },
    );
  }
}
