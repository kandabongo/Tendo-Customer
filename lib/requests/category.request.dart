import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_cache_settings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/services/cache.service.dart';
import 'package:fuodz/services/http.service.dart';

class CategoryRequest extends HttpService {
  //
  Future<List<Category>> _fetchCategories(Map<String, dynamic> params) async {
    final apiResult = await get(Api.categories, queryParameters: params);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  /// Stale-while-revalidate: cache is good for 24h, refreshed in the
  /// background afterwards. [onBackgroundUpdate] fires if a background
  /// refresh returns newer data.
  Future<List<Category>> categories({
    int? vendorTypeId,
    int? page,
    int? perPage,
    Map<String, dynamic>? customParams,
    void Function(List<Category> categories)? onBackgroundUpdate,
  }) {
    Map<String, dynamic> params = {
      "vendor_type_id": vendorTypeId,
      "page": page,
      "per_page": perPage,
      "full": page == null ? 1 : 0,
    };

    if (customParams != null) {
      params.addAll(customParams);
    }

    return CacheService.staleWhileRevalidate<List<Category>>(
      key: 'categories_${vendorTypeId}_${page}_${perPage}_$customParams',
      ttl: AppCacheSettings.categoriesTtl,
      fetch: () => _fetchCategories(params),
      toJson: (list) => list.map((e) => e.toJson()).toList(),
      fromJson:
          (json) =>
              (json as List)
                  .map((e) => Category.fromJson(e as Map<String, dynamic>))
                  .toList(),
      onBackgroundUpdate: onBackgroundUpdate,
    );
  }

  Future<List<Category>> subcategories({
    int? categoryId,
    int? page,
    bool mini = false,
  }) async {
    Map<String, dynamic> params = {
      "category_id": categoryId,
      "page": page,
      "type": "sub",
    };
    if (mini) {
      params["mini"] = 1;
    }

    final apiResult = await get(Api.categories, queryParameters: params);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
