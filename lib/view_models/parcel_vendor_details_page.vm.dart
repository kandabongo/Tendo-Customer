import 'package:fuodz/models/package_type_pricing.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/package.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/view_models/vendor_details.vm.dart';

class ParcelVendorDetailsPageViewModel extends VendorDetailsViewModel {
  final Vendor vendor;
  List<PackageTypePricing> pricings = [];
  List<String> countries = [];
  List<String> cities = [];
  List<String> states = [];

  ParcelVendorDetailsPageViewModel(this.vendor)
    : super(AppService().navigatorKey.currentContext!, vendor);

  initialise() {
    getVendorDetails();
    getVendorPricings();
    getVendorAreaOfOperations();
  }

  getVendorPricings() async {
    //fetch the pricingins
    setBusyForObject(pricings, true);
    try {
      pricings = await PackageRequest().fetchVendorPackageTypePricings(
        vendor: vendor,
      );
    } catch (erorr) {
      print("Error ==> $error");
    }
    setBusyForObject(pricings, false);
  }

  getVendorAreaOfOperations() async {
    //fetch the pricingins
    setBusyForObject("getVendorAreaOfOperations", true);
    try {
      final areasOfOperation = await PackageRequest()
          .fetchVendorPackageAreaOfOperations(vendor: vendor);
      cities = areasOfOperation[0];
      states = areasOfOperation[1];
      countries = areasOfOperation[2];
    } catch (erorr) {
      print("Error ==> $error");
    }
    setBusyForObject("getVendorAreaOfOperations", false);
  }
}
