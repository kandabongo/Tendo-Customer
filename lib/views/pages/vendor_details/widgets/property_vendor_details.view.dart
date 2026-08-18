import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/view_models/property_vendor_details.vm.dart';
import 'package:fuodz/views/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/property.list_item.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_rounded_leading.dart';
import 'package:fuodz/widgets/buttons/share.btn.dart';

class PropertyVendorDetailsView extends StatelessWidget {
  const PropertyVendorDetailsView({required this.vendor, Key? key})
    : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyVendorDetailsViewModel>.reactive(
      viewModelBuilder: () => PropertyVendorDetailsViewModel(context, vendor),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          extendBodyBehindAppBar: true,
          appBarColor: Colors.transparent,
          backgroundColor: context.backgroundColor,
          leading: CustomRoundedLeading(),
          actions: [
            SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(child: ShareButton(model: model)),
            ),
          ],
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: model.refreshController,
            onRefresh: () => model.fetchVendorProperties(true),
            onLoading: () => model.fetchVendorProperties(false),
            child:
                VStack([
                  // Header
                  VendorDetailsHeader(model, showSearch: false),
                  //List of properties
                  CustomListView(
                    noScrollPhysics: true,
                    isLoading: model.isBusy,
                    dataSet: model.properties,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    separatorBuilder:
                        (_, __) => Sizes.paddingSizeDefault.heightBox,
                    itemBuilder: (context, index) {
                      final property = model.properties[index];
                      return PropertyListItem(property: property);
                    },
                  ),
                ]).scrollVertical(),
          ),
        );
      },
    );
  }
}
