import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class Category {
  int id;
  String name;
  String imageUrl;
  String photo;
  List<Product> products;
  List<Service> services;
  List<Category> subcategories;
  VendorType? vendorType;
  String color;
  bool hasSubcategories;
  int services_count = 0;
  int products_count = 0;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.photo,
    this.products = const [],
    this.services = const [],
    this.subcategories = const [],
    this.vendorType,
    this.color = "#eeeeee",
    this.hasSubcategories = false,
    this.services_count = 0,
    this.products_count = 0,
  });

  factory Category.fromJson(dynamic jsonObject) {
    return Category(
      id: jsonObject["id"],
      name: jsonObject["name"],
      imageUrl: jsonObject["photo"],
      photo: jsonObject["photo"],
      color:
          jsonObject["color"] != null
              ? jsonObject["color"]
              : AppColor.primaryColor.toHex(),
      hasSubcategories:
          jsonObject["has_subcategories"] != null
              ? (jsonObject["has_subcategories"] as bool)
              : false,
      products: List<Product>.from(
        (jsonObject["products"] ?? []).map((x) => Product.fromJson(x)),
      ),
      services: List<Service>.from(
        (jsonObject["services"] ?? []).map((x) => Service.fromJson(x)),
      ),
      subcategories: List<Category>.from(
        (jsonObject["sub_categories"] ?? []).map((x) => Category.fromJson(x)),
      ),
      vendorType:
          jsonObject["vendor_type"] == null
              ? null
              : VendorType.fromJson(jsonObject["vendor_type"]),
      services_count: jsonObject["services_count"] ?? 0,
      products_count: jsonObject["products_count"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "photo": imageUrl,
    "color": color,
    "products": List<Map<String, dynamic>>.from(
      products.map((x) => x.toJson()),
    ),
    "services": List<Map<String, dynamic>>.from(
      services.map((x) => x.toJson()),
    ),
    "subcategories": List<Map<String, dynamic>>.from(
      subcategories.map((x) => x.toJson()),
    ),
    "has_subcategories": hasSubcategories,
    "services_count": services_count,
    "products_count": products_count,
  };
}
