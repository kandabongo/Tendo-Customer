import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_cache_settings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/banner.dart';
import 'package:fuodz/services/cache.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/services/location.service.dart';

class BannerRequest extends HttpService {
  //
  Future<List<Banner>> _fetchBanners(Map<String, dynamic> queryParams) async {
    final apiResult = await get(Api.banners, queryParameters: queryParams);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Banner.fromJSON(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  /// Stale-while-revalidate: cache is good for 12h, refreshed in the
  /// background afterwards. [onBackgroundUpdate] fires if a background
  /// refresh returns newer data.
  Future<List<Banner>> banners({
    int? vendorTypeId,
    Map? params,
    void Function(List<Banner> banners)? onBackgroundUpdate,
  }) {
    final queryParams = <String, dynamic>{
      "vendor_type_id": vendorTypeId,
      ...(params != null ? params : {}),
      "latitude": LocationService.cLat,
      "longitude": LocationService.cLng,
    };

    return CacheService.staleWhileRevalidate<List<Banner>>(
      key: 'banners_${vendorTypeId}_$queryParams',
      ttl: AppCacheSettings.bannersTtl,
      fetch: () => _fetchBanners(queryParams),
      toJson: (list) => list.map((e) => e.toJson()).toList(),
      fromJson:
          (json) =>
              (json as List)
                  .map((e) => Banner.fromJSON(e as Map<String, dynamic>))
                  .toList(),
      onBackgroundUpdate: onBackgroundUpdate,
    );
  }
}
