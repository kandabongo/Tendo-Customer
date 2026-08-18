import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/category.request.dart';
import 'package:fuodz/requests/service.request.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/vendor_details/vendor_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:fuodz/extensions/context.dart';

class ServiceViewModel extends MyBaseViewModel {
  //
  ServiceViewModel(BuildContext context, VendorType vendorType) {
    this.viewContext = context;
    this.vendorType = vendorType;
  }

  //
  User? currentUser;
  StreamSubscription? currentLocationChangeStream;

  //
  VendorRequest vendorRequest = VendorRequest();
  ServiceRequest _serviceRequest = ServiceRequest();
  RefreshController refreshController = RefreshController();
  List<Vendor> vendors = [];
  List<Vendor> featuredProviders = [];
  List<Category> categories = [];
  List<Service> trendingServices = [];
  List<Category> serviceByCategories = [];

  void initialise() async {
    preloadDeliveryLocation();
    //
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }
    //handle location stream change
    handleLocationStreamChange();
    //get vendors
    await getServiceCategories();
    await getTrendingServices();
    await getFeaturedProviders();
    await getPoupularServicesByCategories();
    // getVendors();
  }

  //
  dispose() {
    super.dispose();
    currentLocationChangeStream?.cancel();
  }

  handleLocationStreamChange() {
    currentLocationChangeStream?.cancel();
    currentLocationChangeStream = LocationService.currenctDeliveryAddressSubject
        .listen((data) {
          initialise();
        });
  }

  //
  getVendors() async {
    vendors.clear();
    //
    setBusyForObject(vendors, true);
    try {
      vendors = await vendorRequest.nearbyVendorsRequest(
        params: {"vendor_type_id": vendorType?.id},
      );
    } catch (error) {
      print("Error getting vendors ==> $error");
    }
    setBusyForObject(vendors, false);
  }

  getFeaturedProviders() async {
    //
    featuredProviders.clear();
    setBusyForObject(featuredProviders, true);
    try {
      featuredProviders = await vendorRequest.vendorsRequest(
        byLocation: false,
        params: {"vendor_type_id": vendorType?.id, "featured": 1},
      );
    } catch (error) {
      print("Error getting vendors ==> $error");
    }
    setBusyForObject(featuredProviders, false);
  }

  //
  getServiceCategories() async {
    //
    categories.clear();
    setBusyForObject(categories, true);
    try {
      categories = await CategoryRequest().categories(
        vendorTypeId: vendorType?.id,
        page: 1,
        perPage: 10,
        customParams: {"order_by": "services"},
      );
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(categories, false);
  }

  getTrendingServices() async {
    //
    trendingServices.clear();
    setBusyForObject(trendingServices, true);
    try {
      trendingServices = await ServiceRequest().getServices(
        page: 1,
        queryParams: {
          "type": "best",
          "vendor_type_id": vendorType?.id,
          "direction": "desc",
        },
      );
    } catch (error) {
      print("Error getTrendingServices ==> $error");
    }
    setBusyForObject(trendingServices, false);
  }

  getPoupularServicesByCategories() async {
    serviceByCategories.clear();
    notifyListeners();
    if (categories.isEmpty) {
      return;
    }
    //take max of 4
    serviceByCategories = categories.sublist(
      0,
      categories.length > 4 ? 4 : categories.length,
    );
    setBusyForObject(serviceByCategories, true);
    //for each serviceByCategories
    for (var i = 0; i < serviceByCategories.length; i++) {
      final serviceByCategory = serviceByCategories[i];
      setBusyForObject(serviceByCategory.id, true);
      try {
        List<Service> mServices = await _serviceRequest.getServices(
          queryParams: {"category_id": serviceByCategory.id},
        );
        //reduce to like 5
        if (mServices.length > 5) {
          mServices = mServices.sublist(0, 4);
        }
        serviceByCategories[i].services = mServices;
      } catch (error) {
        print(
          "Error getting the services under this category ${serviceByCategory.name}: $error",
        );
      }
      setBusyForObject(serviceByCategory.id, false);
    }
    setBusyForObject(serviceByCategories, false);
  }

  //
  openVendorDetails(Vendor vendor) {
    viewContext.push((context) => VendorDetailsPage(vendor: vendor));
  }

  //
  openSearch({int showType = 4}) async {
    NavigationService.openServiceSearch(viewContext, vendorType: vendorType);
  }

  categorySelected(Category category) async {
    NavigationService.categorySelected(category);
  }
}
