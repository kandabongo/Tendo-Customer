// To parse this JSON data, do
//
//     final bookingFeeType = bookingFeeTypeFromJson(jsonString);

import 'dart:convert';

BookingFeeType bookingFeeTypeFromJson(String str) =>
    BookingFeeType.fromJson(json.decode(str));

String bookingFeeTypeToJson(BookingFeeType data) => json.encode(data.toJson());

class BookingFeeType {
  BookingFeeType({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.calculationType,
    required this.isMandatory,
    required this.isTaxable,
    required this.displayOrder,
    required this.isActive,
    required this.photo,
  });

  int id;
  String name;
  String slug;
  String description;
  String calculationType;
  bool isMandatory;
  bool isTaxable;
  int displayOrder;
  bool isActive;
  String photo;

  factory BookingFeeType.fromJson(Map<String, dynamic> json) => BookingFeeType(
    id: json["id"],
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    description: json["description"] ?? "",
    calculationType: json["calculation_type"] ?? "flat",
    isMandatory:
        json["is_mandatory"] is bool
            ? json["is_mandatory"]
            : (int.parse(json["is_mandatory"].toString()) == 1),
    isTaxable:
        json["is_taxable"] is bool
            ? json["is_taxable"]
            : (int.parse(json["is_taxable"].toString()) == 1),
    displayOrder: json["display_order"] ?? 0,
    isActive:
        json["is_active"] is bool
            ? json["is_active"]
            : (int.parse(json["is_active"].toString()) == 1),
    photo: json["photo"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "calculation_type": calculationType,
    "is_mandatory": isMandatory,
    "is_taxable": isTaxable,
    "display_order": displayOrder,
    "is_active": isActive,
    "photo": photo,
  };

  bool get isPercentage => calculationType == "percentage";
}
