import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/models/property_amenity.dart';
import 'package:fuodz/models/property_type.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/booking/widgets/property_search_filter.bottomsheet.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PropertySearchViewModel extends MyBaseViewModel {
  PropertySearchViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  final VendorType vendorType;
  PropertyRequest _propertyRequest = PropertyRequest();
  RefreshController refreshController = RefreshController();
  TextEditingController searchTEC = TextEditingController();

  List<Property> properties = [];
  int queryPage = 1;

  String keyword = "";
  Address? selectedLocation;
  bool hasStartedSearch = false;
  double filterMinPrice = 0;
  double filterMaxPrice = 1000000;

  // Filter Data
  List<PropertyType> propertyTypes = [];
  List<PropertyAmenity> propertyAmenities = [];
  List<int> selectedPropertyTypes = [];
  List<int> selectedAmenities = [];
  double? minPrice;
  double? maxPrice;
  int? minBedrooms;
  int? minBeds;
  int? minBathrooms;
  int searchRdius = 50;

  int? minGuests;
  DateTime? checkInDate;
  DateTime? checkOutDate;

  ValueNotifier<List<PropertyType>> propertyTypesNotifier = ValueNotifier([]);
  ValueNotifier<List<PropertyAmenity>> propertyAmenitiesNotifier =
      ValueNotifier([]);

  void initialise() {
    // startSearch();
    fetchFilterData();
  }

  void fetchFilterData() async {
    setBusyForObject(fetchFilterData, true);
    try {
      propertyTypes = await _propertyRequest.getPropertyTypes();
      propertyAmenities = await _propertyRequest.getPropertyAmenities();
      propertyTypesNotifier.value = propertyTypes;
      propertyAmenitiesNotifier.value = propertyAmenities;
      notifyListeners();
    } catch (e) {
      print("Error fetching filter data: $e");
    }
    setBusyForObject(fetchFilterData, false);
  }

  void startSearch({bool initial = true}) async {
    hasStartedSearch = true;
    notifyListeners();
    if (initial) {
      properties.clear();
      queryPage = 1;
      setBusy(true);
    } else {
      queryPage++;
    }

    try {
      Map<String, dynamic> queryParams = {
        "vendor_type_id": vendorType.id,
        "name": keyword,
      };

      if (selectedLocation != null) {
        queryParams["latitude"] = selectedLocation?.coordinates?.latitude;
        queryParams["longitude"] = selectedLocation?.coordinates?.longitude;
      }

      queryParams["radius"] = searchRdius;
      if (minPrice != null) queryParams["min_price"] = minPrice;
      if (maxPrice != null && maxPrice! < filterMaxPrice) {
        queryParams["max_price"] = maxPrice;
      }

      if (selectedPropertyTypes.isNotEmpty) {
        queryParams["property_types_ids"] = selectedPropertyTypes;
      }
      if (selectedAmenities.isNotEmpty) {
        queryParams["amenities_ids"] = selectedAmenities;
      }
      if (minBedrooms != null && minBedrooms! > 0) {
        queryParams["bedrooms"] = minBedrooms;
      }
      if (minBeds != null && minBeds! > 0) {
        queryParams["beds"] = minBeds;
      }
      if (minBathrooms != null && minBathrooms! > 0) {
        queryParams["bathrooms"] = minBathrooms;
      }
      if (minGuests != null && minGuests! > 0) {
        queryParams["guests"] = minGuests;
      }
      if (checkInDate != null) {
        queryParams["check_in_date"] = checkInDate?.toIso8601String();
      }
      if (checkOutDate != null) {
        queryParams["check_out_date"] = checkOutDate?.toIso8601String();
      }

      final mProperties = await _propertyRequest.getProperties(
        page: queryPage,
        queryParams: queryParams,
      );

      if (initial) {
        properties = mProperties;
      } else {
        properties.addAll(mProperties);
      }

      if (mProperties.isEmpty) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }

      clearErrors();
    } catch (error) {
      setError(error);
    }

    if (initial) {
      setBusy(false);
      refreshController.refreshCompleted();
    }
    notifyListeners();
  }

  void onSearchSubmitted(String value) {
    keyword = value;
    selectedLocation = null;
    startSearch();
  }

  void onLocationSelected(Address address) {
    selectedLocation = address;
    keyword = "";
    searchTEC.text = address.addressLine ?? "";
    notifyListeners();
  }

  void openFilter() {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) => PropertySearchFilterBottomSheet(this),
    );
  }

  void applyFilters() {
    startSearch();
  }

  void resetFilters() {
    selectedPropertyTypes.clear();
    selectedAmenities.clear();
    minPrice = null;
    maxPrice = null;
    selectedLocation = null;
    searchTEC.clear();
    minBedrooms = null;
    selectedLocation = null;

    minBeds = null;
    minBathrooms = null;
    minGuests = null;
    checkInDate = null;
    checkOutDate = null;
    properties.clear();
    queryPage = 1;
    hasStartedSearch = false;
    notifyListeners();
  }
}
