import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/http.service.dart';

class FavouriteRequest extends HttpService {
  //
  Future<List<Product>> favourites() async {
    final apiResult = await get(Api.favourites);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Product> products = [];
      (apiResponse.body as List).forEach((jsonObject) {
        try {
          products.add(Product.fromJson(jsonObject["product"]));
        } catch (error) {
          print("error: $error");
        }
      });
      return products;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavourite(int id) async {
    final apiResult = await post(Api.favourites, {"product_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavourite(int productId) async {
    final apiResult = await delete(Api.favourites + "/$productId");
    return ApiResponse.fromResponse(apiResult);
  }

  //vendor
  Future<List<Vendor>> favouriteVendors() async {
    final apiResult = await get(Api.favouriteVendors);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> dataset = [];
      (apiResponse.body as List).forEach((jsonObject) {
        try {
          dataset.add(Vendor.fromJson(jsonObject["vendor"]));
        } catch (error) {
          print("error: $error");
        }
      });
      return dataset;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavouriteVendor(int id) async {
    final apiResult = await post(Api.favouriteVendors, {"vendor_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavouriteVendor(int vendorId) async {
    final apiResult = await delete("${Api.favouriteVendors}/$vendorId");
    return ApiResponse.fromResponse(apiResult);
  }

  //Property
  Future<List<Property>> favouriteProperties() async {
    final apiResult = await get(Api.favouriteProperties);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Property> dataset = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          dataset.add(Property.fromJson(jsonObject));
        } catch (error) {
          print("error: $error");
        }
      });
      return dataset;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavouriteProperty(int id) async {
    final apiResult = await post(Api.favouriteProperties, {"property_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavouriteProperty(int propertyId) async {
    final apiResult = await delete("${Api.favouriteProperties}/$propertyId");
    return ApiResponse.fromResponse(apiResult);
  }
}
