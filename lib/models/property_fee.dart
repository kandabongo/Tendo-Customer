// To parse this JSON data, do
//
//     final propertyFee = propertyFeeFromJson(jsonString);

import 'dart:convert';
import 'booking_fee_type.dart';

PropertyFee propertyFeeFromJson(String str) =>
    PropertyFee.fromJson(json.decode(str));

String propertyFeeToJson(PropertyFee data) => json.encode(data.toJson());

class PropertyFee {
  PropertyFee({
    required this.id,
    required this.propertyId,
    required this.bookingFeeTypeId,
    required this.amount,
    this.minAmount,
    this.maxAmount,
    required this.isActive,
    this.bookingFeeType,
  });

  int id;
  int propertyId;
  int bookingFeeTypeId;
  double amount;
  double? minAmount;
  double? maxAmount;
  bool isActive;
  BookingFeeType? bookingFeeType;

  factory PropertyFee.fromJson(Map<String, dynamic> json) => PropertyFee(
    id: json["id"],
    propertyId: json["property_id"],
    bookingFeeTypeId: json["booking_fee_type_id"],
    amount: double.parse(json["amount"].toString()),
    minAmount:
        json["min_amount"] == null
            ? null
            : double.parse(json["min_amount"].toString()),
    maxAmount:
        json["max_amount"] == null
            ? null
            : double.parse(json["max_amount"].toString()),
    isActive:
        json["is_active"] is bool
            ? json["is_active"]
            : (int.parse(json["is_active"].toString()) == 1),
    bookingFeeType:
        json["booking_fee_type"] == null
            ? null
            : BookingFeeType.fromJson(json["booking_fee_type"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "property_id": propertyId,
    "booking_fee_type_id": bookingFeeTypeId,
    "amount": amount,
    "min_amount": minAmount,
    "max_amount": maxAmount,
    "is_active": isActive,
    "booking_fee_type": bookingFeeType?.toJson(),
  };
}
