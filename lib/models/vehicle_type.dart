// To parse this JSON data, do
//
//     final vehicleType = vehicleTypeFromJson(jsonString);

import 'dart:convert';
import 'package:dartx/dartx.dart';
import 'package:fuodz/models/currency.dart';

VehicleType vehicleTypeFromJson(String str) =>
    VehicleType.fromJson(json.decode(str));

String vehicleTypeToJson(VehicleType data) => json.encode(data.toJson());

class VehicleType {
  VehicleType({
    required this.id,
    required this.name,
    required this.slug,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.minFare,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.photo,
    required this.total,
    required this.tax,
    required this.encrypted,
    required this.currency,
    //new fields
    this.surgeRate,
    this.icon,
    this.iconBase64,
  });

  int id;
  String name;
  String slug;
  double baseFare;
  double distanceFare;
  double timeFare;
  double total;
  double tax;
  double minFare;
  int isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String photo;
  String? encrypted;
  Currency? currency;
  //new fields
  double? surgeRate;
  String? icon;
  String? iconBase64;

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      baseFare: json["base_fare"].toString().toDoubleOrNull() ?? 0,
      distanceFare: json["distance_fare"].toString().toDoubleOrNull() ?? 0,
      timeFare: json["time_fare"].toString().toDoubleOrNull() ?? 0,
      minFare: json["min_fare"].toString().toDoubleOrNull() ?? 0,
      total: json["total"].toString().toDoubleOrNull() ?? 0,
      tax: json["tax"].toString().toDoubleOrNull() ?? 0,
      isActive: json["is_active"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate: json["formatted_date"],
      photo: json["photo"],
      encrypted: json["encrypted"],
      currency:
          json["currency"] != null ? Currency.fromJSON(json["currency"]) : null,
      //new fields
      surgeRate: json["surge_rate"] != null
          ? (json["surge_rate"].toString().toDouble())
          : null,
      icon: json["icon"],
      iconBase64: json["icon_base64"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "base_fare": baseFare,
        "distance_fare": distanceFare,
        "time_fare": timeFare,
        "min_fare": minFare,
        "total": total,
        "tax": tax,
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "photo": photo,
        "encrypted": encrypted,
        "currency": currency != null ? currency?.toJson() : null,
        //new fields
        "surge_rate": surgeRate,
        "icon": icon,
        "icon_base64": iconBase64,
      };

  //
  bool get hasSurge {
    return surgeRate != null && surgeRate! > 0;
  }
}
