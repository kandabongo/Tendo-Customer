// To parse this JSON data, do
//
//     final propertyType = propertyTypeFromJson(jsonString);

import 'dart:convert';

PropertyType propertyTypeFromJson(String str) =>
    PropertyType.fromJson(json.decode(str));

String propertyTypeToJson(PropertyType data) => json.encode(data.toJson());

class PropertyType {
  PropertyType({
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

  factory PropertyType.fromJson(Map<String, dynamic> json) => PropertyType(
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
