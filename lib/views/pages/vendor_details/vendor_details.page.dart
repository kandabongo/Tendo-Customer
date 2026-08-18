import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/view_models/vendor_details.vm.dart';
import 'package:fuodz/views/pages/parcel/parcel_vendor_details.page.dart';
import 'package:fuodz/views/pages/vendor_details/widgets/property_vendor_details.view.dart';
import 'package:fuodz/views/pages/vendor_details/widgets/vendor_with_menu.view.dart';
import 'package:stacked/stacked.dart';

import 'package:fuodz/views/pages/vendor_details/widgets/vendor_plain_details.view.dart';

class VendorDetailsPage extends StatelessWidget {
  const VendorDetailsPage({required this.vendor, Key? key}) : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    // Check if vendor is parcel type and return directly to avoid screen flash
    if (vendor.isParcelType) {
      return ParcelVendorDetailsPage(vendor: vendor);
    }

    // Determine the right view directly for basic types
    // Standard menu vendors (Food, Grocery, etc)
    if (!vendor.hasSubcategories &&
        !vendor.isServiceType &&
        !vendor.isBookingType) {
      return VendorDetailsWithMenuPage(vendor: vendor);
    }

    //property vendor
    if (vendor.isBookingType) {
      return PropertyVendorDetailsView(vendor: vendor);
    }

    // For more complex types (Service, Subcategories), we use VendorDetailsViewModel
    // which handles the layout differences via VendorPlainDetailsView
    return ViewModelBuilder<VendorDetailsViewModel>.reactive(
      viewModelBuilder: () => VendorDetailsViewModel(context, vendor),
      onViewModelReady: (model) => model.getVendorDetails(),
      builder: (context, model, child) {
        return VendorPlainDetailsView(model);
      },
    );
  }
}
