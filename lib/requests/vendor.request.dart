import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_cache_settings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/order_stop.dart';
import 'package:fuodz/models/review.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/cache.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/services/location.service.dart';

class VendorRequest extends HttpService {
  //
  Future<List<Vendor>> vendorsRequest({
    int page = 1,
    bool byLocation = true,
    Map? params,
  }) async {
    Map<String, dynamic> queryParameters = {
      ...(params != null ? params : {}),
      "page": "$page",
    };
    //
    if (byLocation && LocationService.cLat != null) {
      queryParameters["latitude"] =
          LocationService.currenctAddress?.coordinates?.latitude;
      queryParameters["longitude"] =
          LocationService.currenctAddress?.coordinates?.longitude;
    }
    //
    final apiResult = await get(Api.vendors, queryParameters: queryParameters);

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          vendors.add(Vendor.fromJson(jsonObject));
        } catch (error) {
          print("===============================");
          print("Fetching Vendor error ==> $error");
          print("Vendor Id ==> ${jsonObject['id']}");
          print("===============================");
        }
      });
      return vendors;
    }

    throw apiResponse.message!;
  }

  //
  Future<List<Vendor>> topVendorsRequest({
    int page = 1,
    bool byLocation = false,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.vendors,
      queryParameters: {
        ...(params != null ? params : {}),
        "page": "$page",
        "latitude":
            byLocation ? await LocationService.getFetchByLocationLat() : null,
        "longitude":
            byLocation ? await LocationService.getFetchByLocationLng() : null,
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors = [];
      vendors =
          apiResponse.data
              .map((jsonObject) => Vendor.fromJson(jsonObject))
              .toList();
      return vendors;
    }

    throw apiResponse.message!;
  }

  Future<List<Vendor>> nearbyVendorsRequest({
    int page = 1,
    bool byLocation = false,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.vendors,
      queryParameters: {
        ...(params != null ? params : {}),
        "page": "$page",
        "latitude":
            byLocation ? await LocationService.getFetchByLocationLat() : null,
        "longitude":
            byLocation ? await LocationService.getFetchByLocationLng() : null,
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Vendor.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<Vendor> _fetchVendorDetails(
    int id,
    Map<String, String>? params,
  ) async {
    final apiResult = await get("${Api.vendors}/$id", queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Vendor.fromJson(apiResponse.body, rawDescription: false);
    }

    throw apiResponse.message!;
  }

  /// Stale-while-revalidate: cache is good for 15min, refreshed in the
  /// background afterwards. [onBackgroundUpdate] fires if a background
  /// refresh returns newer data.
  Future<Vendor> vendorDetails(
    int id, {
    Map<String, String>? params,
    void Function(Vendor vendor)? onBackgroundUpdate,
  }) {
    return CacheService.staleWhileRevalidate<Vendor>(
      key: 'vendor_details_${id}_$params',
      ttl: AppCacheSettings.vendorDetailsTtl,
      fetch: () => _fetchVendorDetails(id, params),
      toJson: (vendor) => vendor.toJson(),
      fromJson:
          (json) => Vendor.fromJson(
            json as Map<String, dynamic>,
            rawDescription: false,
          ),
      onBackgroundUpdate: onBackgroundUpdate,
    );
  }

  Future<List<Vendor>> fetchParcelVendors({
    required int packageTypeId,
    int? vendorTypeId,
    required List<OrderStop> stops,
    bool correctOnly = true,
  }) async {
    final apiResult = await post(Api.packageVendors, {
      "vendor_type_id": vendorTypeId,
      "package_type_id": "$packageTypeId",
      "correct_only": correctOnly ? 1 : 0,
      "locations":
          stops.map((stop) {
            return {
              "lat": stop.deliveryAddress?.latitude,
              "long": stop.deliveryAddress?.longitude,
              "lng": stop.deliveryAddress?.longitude,
              "city": stop.deliveryAddress?.city,
              "state": stop.deliveryAddress?.state,
              "country": stop.deliveryAddress?.country,
            };
          }).toList(),
    });

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors =
          (apiResponse.body['vendors'] as List)
              .map((jsonObject) => Vendor.fromJson(jsonObject))
              .toList();
      return vendors;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> rateVendor({
    required int rating,
    required String review,
    required int orderId,
    required int vendorId,
  }) async {
    //
    final apiResult = await post(Api.rating, {
      "order_id": orderId,
      "vendor_id": vendorId,
      "rating": rating,
      "review": review,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rateDriver({
    required int rating,
    required String review,
    required int orderId,
    required int driverId,
  }) async {
    //
    final apiResult = await post(Api.rating, {
      "order_id": orderId,
      "driver_id": driverId,
      "rating": rating,
      "review": review,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<Review>> getReviews({int? page, int? vendorId}) async {
    final apiResult = await get(
      Api.vendorReviews,
      queryParameters: {"vendor_id": vendorId, "page": "$page"},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Review> reviews =
          apiResponse.data.map((jsonObject) {
            return Review.fromJson(jsonObject);
          }).toList();

      return reviews;
    }

    throw apiResponse.message!;
  }
}
