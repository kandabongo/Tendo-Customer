import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_type.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BookingViewModel extends MyBaseViewModel {
  //
  BookingViewModel(BuildContext context, VendorType vendorType) {
    this.viewContext = context;
    this.vendorType = vendorType;
  }

  //
  User? currentUser;
  StreamSubscription? currentLocationChangeStream;

  //
  VendorRequest vendorRequest = VendorRequest();
  PropertyRequest _propertyRequest = PropertyRequest();
  RefreshController refreshController = RefreshController();

  List<PropertyType> propertyTypes = [];
  List<Property> properties = [];
  List<Property> featuredProperties = [];
  PropertyType? selectedPropertyType;
  int queryPage = 1;

  void initialise() async {
    preloadDeliveryLocation();
    fetchAllNeededData();
  }

  dispose() {
    super.dispose();
  }

  //
  fetchAllNeededData() async {
    getFeaturedProperties();
    await getPropertyTypes();
    getProperties();
  }

  //
  getPropertyTypes() async {
    setBusyForObject(propertyTypes, true);
    try {
      propertyTypes = await _propertyRequest.getPropertyTypes();
      if (propertyTypes.isNotEmpty) {
        selectedPropertyType = propertyTypes.first;
      }
    } catch (error) {
      print("Error getting property types ==> $error");
    }
    setBusyForObject(propertyTypes, false);
  }

  //
  getFeaturedProperties() async {
    setBusyForObject(featuredProperties, true);
    try {
      featuredProperties = await _propertyRequest.getProperties(
        queryParams: {"vendor_type_id": vendorType?.id, "featured": "1"},
      );
    } catch (error) {
      print("Error getting featured properties ==> $error");
    }
    setBusyForObject(featuredProperties, false);
  }

  //
  getProperties({bool initial = true}) async {
    if (initial) {
      queryPage = 1;
      properties.clear();
      setBusyForObject(properties, true);
      refreshController.resetNoData();
    } else {
      queryPage++;
    }

    List<Property> mProperties = [];

    try {
      final Map<String, dynamic> queryParams = {
        "vendor_type_id": vendorType?.id,
      };

      if (selectedPropertyType != null) {
        queryParams["property_type_id"] = selectedPropertyType?.id;
      }

      mProperties = await _propertyRequest.getProperties(
        queryParams: queryParams,
        page: queryPage,
      );

      if (initial) {
        properties = mProperties;
      } else {
        properties.addAll(mProperties);
      }
    } catch (error) {
      print("Error getting properties ==> $error");
    }

    if (initial) {
      setBusyForObject(properties, false);
    } else {
      refreshController.loadComplete();
      if (mProperties.isEmpty) {
        refreshController.loadNoData();
      }
    }
    notifyListeners();
  }

  //
  onPropertyTypeSelected(PropertyType propertyType) {
    selectedPropertyType = propertyType;
    getProperties();
  }

  //
  void onRefresh() async {
    refreshController.refreshCompleted();
    refreshController.resetNoData();
    fetchAllNeededData();
  }

  void onLoadMore() async {
    await getProperties(initial: false);
  }
}
