import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_cache_settings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/cache.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/services/location.service.dart';

class VendorTypeRequest extends HttpService {
  //
  Future<List<VendorType>> _fetchIndex(Map<String, dynamic>? params) async {
    final apiResult = await get(Api.vendorTypes, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List)
          .map((e) => VendorType.fromJson(e))
          .toList();
    }

    throw apiResponse.message!;
  }

  /// Stale-while-revalidate: returns cached vendor types instantly (cache is
  /// good for 24h) while refreshing from the network in the background.
  /// [onBackgroundUpdate] fires if a background refresh returns newer data.
  ///
  /// The cache is keyed by location (including when it's unresolved, i.e.
  /// both null) because results are location-specific and it's the server,
  /// not this client, that decides what to return for a given (or missing)
  /// location. Callers (e.g. WelcomeViewModel.handleLocationStream) retry
  /// once LocationService resolves a delivery address, which naturally
  /// lands on the location-specific cache key instead.
  Future<List<VendorType>> index({
    void Function(List<VendorType> vendorTypes)? onBackgroundUpdate,
  }) async {
    final params = {
      "latitude": await LocationService.getFetchByLocationLat(),
      "longitude": await LocationService.getFetchByLocationLng(),
    };
    return CacheService.staleWhileRevalidate<List<VendorType>>(
      key: 'vendor_types_${params}',
      ttl: AppCacheSettings.vendorTypesTtl,
      fetch: () => _fetchIndex(params),
      toJson: (list) => list.map((e) => e.toJson()).toList(),
      fromJson:
          (json) =>
              (json as List)
                  .map((e) => VendorType.fromJson(e as Map<String, dynamic>))
                  .toList(),
      onBackgroundUpdate: onBackgroundUpdate,
      //an empty response is never trusted for the full TTL - it's more
      //likely a transient/location-not-ready hiccup than a genuine
      //"no services here", so the next call always retries the network
      //instead of re-serving a cached empty list for 24h.
      isEmptyResult: (list) => list.isEmpty,
    );
  }
}
