import 'package:fuodz/constants/app_colors.dart';

class VendorType {
  VendorType({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.color,
    required this.isActive,
    required this.logo,
    required this.hasBanners,
  });

  int id;
  String name;
  String description;
  String slug;
  String color;
  int isActive;
  String logo;
  bool hasBanners;

  factory VendorType.fromJson(Map<String, dynamic> json) {
    final colorCode =
        json["color"] == null
            ? AppColor.colorEnv("primaryColor")
            : (json["color"].toString().length == 7
                ? json["color"]
                : AppColor.colorEnv("primaryColor"));
    return VendorType(
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"],
      description: json["description"] == null ? null : json["description"],
      slug: json["slug"] == null ? null : json["slug"],
      color: colorCode,
      isActive: json["is_active"] == null ? null : json["is_active"],
      logo: json["logo"] == null ? null : json["logo"],
      hasBanners:
          json["has_banners"] == null
              ? false
              : ((json["has_banners"] is bool)
                  ? json["has_banners"]
                  : int.parse(json["has_banners"].toString()) == 1),
    );
  }

  bool get isProduct {
    return [
      "food",
      "grocery",
      "commerce",
      "e-commerce",
    ].contains(slug.toLowerCase());
  }

  bool get isService => ["service", "services"].contains(slug.toLowerCase());
  bool get isBooking =>
      ["booking", "bookings", "property"].contains(slug.toLowerCase());

  bool get isGrocery => slug == "grocery";

  bool get isFood => slug == "food";

  bool get isCommerce =>
      ["commerce", "e-commerce"].contains(slug.toLowerCase());

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "slug": slug,
    "color": color,
    "is_active": isActive,
    "logo": logo,
    "has_banners": hasBanners ? 1 : 0,
  };

  //
  bool get authRequired {
    return ["taxi", "parcel", "package"].contains(slug);
  }
}
