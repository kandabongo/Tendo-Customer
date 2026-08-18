import 'package:flutter/src/material/date.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_review.dart';
import 'package:fuodz/models/property_type.dart';
import 'package:fuodz/models/property_amenity.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/services/location.service.dart';

class PropertyRequest extends HttpService {
  //
  Future<List<PropertyType>> getPropertyTypes() async {
    final apiResult = await get(Api.propertyTypes);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body is List
              ? apiResponse.body as List
              : apiResponse.data)
          .map((jsonObject) => PropertyType.fromJson(jsonObject))
          .toList();
    }
    throw apiResponse.message!;
  }

  //
  Future<List<Property>> getProperties({
    Map<String, dynamic>? queryParams,
    int page = 1,
  }) async {
    Map<String, dynamic> params = {...(queryParams ?? {}), "page": "$page"};
    //add location data if not provided
    if (AppStrings.enableFatchByLocation &&
        !params.containsKey("latitude") &&
        !params.containsKey("longitude")) {
      params.addAll({
        "latitude": LocationService.currenctAddress?.coordinates?.latitude,
        "longitude": LocationService.currenctAddress?.coordinates?.longitude,
      });
    }

    final apiResult = await get(Api.properties, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Property.fromJson(jsonObject))
          .toList();
    }
    throw apiResponse.message!;
  }

  //
  Future<Property> getPropertyDetails(int id) async {
    final apiResult = await get(
      Api.property.replaceFirst("{id}", id.toString()),
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Property.fromJson(apiResponse.body);
    }
    throw apiResponse.message!;
  }

  //
  Future<List<PropertyReview>> getPropertyReviews(
    int id, {
    int page = 1,
  }) async {
    final apiResult = await get(
      Api.propertyReviews.replaceFirst("{id}", id.toString()),
      queryParameters: {"page": "$page"},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return ((apiResponse.body is List)
              ? apiResponse.body as List
              : apiResponse.data)
          .map((jsonObject) => PropertyReview.fromJson(jsonObject))
          .toList();
    }
    throw apiResponse.message!;
  }

  //
  Future<List<Property>> getSimilarProperties(int id) async {
    final apiResult = await get(
      Api.propertySimilar.replaceFirst("{id}", id.toString()),
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Property.fromJson(jsonObject))
          .toList();
    }
    throw apiResponse.message!;
  }

  //
  Future<List<PropertyAmenity>> getPropertyAmenities() async {
    final apiResult = await get(Api.propertyAmenities);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body is List
              ? apiResponse.body as List
              : apiResponse.data)
          .map((jsonObject) => PropertyAmenity.fromJson(jsonObject))
          .toList();
    }
    throw apiResponse.message!;
  }

  Future<ApiResponse> bookProperty({
    required int propertyId,
    DateTimeRange<DateTime>? selectedDateRange,
    required double totalPrice,
    required int paymentMethodId,
    required int adults,
    required int children,
    required int infants,
    required int pets,
  }) async {
    final apiResult = await post(Api.propertyBookings, {
      "property_id": propertyId,
      "check_in_date": selectedDateRange?.start.toIso8601String(),
      "check_out_date": selectedDateRange?.end.toIso8601String(),
      "total_price": totalPrice,
      "payment_method_id": paymentMethodId,
      "number_of_guests": adults + children + infants,
      "number_of_adults": adults,
      "number_of_children": children,
      "number_of_infants": infants,
      "number_of_pets": pets,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return apiResponse;
  }

  Future<ApiResponse> cancelBooking({required int id, String? reason}) async {
    final apiResult = await post(
      Api.propertyBookingCancel.replaceFirst("{id}", id.toString()),
      {"reason": reason},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return apiResponse;
  }
}
