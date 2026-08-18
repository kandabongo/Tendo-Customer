// To parse this JSON data, do
//
//     final propertyAmenity = propertyAmenityFromJson(jsonString);

import 'dart:convert';

PropertyAmenity propertyAmenityFromJson(String str) =>
    PropertyAmenity.fromJson(json.decode(str));

String propertyAmenityToJson(PropertyAmenity data) =>
    json.encode(data.toJson());

class PropertyAmenity {
  PropertyAmenity({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.photo,
  });

  int id;
  String name;
  String slug;
  bool isActive;
  String photo;

  factory PropertyAmenity.fromJson(Map<String, dynamic> json) =>
      PropertyAmenity(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        isActive:
            json["is_active"] is bool
                ? json["is_active"]
                : (int.parse(json["is_active"].toString()) == 1),
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "is_active": isActive,
    "photo": photo,
  };
}
