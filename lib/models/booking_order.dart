import 'dart:convert';
import 'package:fuodz/models/booking_order_fee.dart';
import 'package:fuodz/models/cancellation_policy.dart';
import 'package:fuodz/models/property.dart';

BookingOrder bookingOrderFromJson(String str) =>
    BookingOrder.fromJson(json.decode(str));

String bookingOrderToJson(BookingOrder data) => json.encode(data.toJson());

class BookingOrder {
  BookingOrder({
    required this.id,
    required this.orderId,
    required this.propertyId,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    required this.numberOfGuests,
    required this.numberOfAdults,
    required this.numberOfChildren,
    required this.numberOfPets,
    required this.numberOfInfants,
    required this.numberOfNights,
    required this.basePrice,
    required this.totalNightsCost,
    required this.bookingType,
    this.specialRequests,
    required this.cancellationPolicyId,
    this.canCancel,
    this.refundAmount,
    this.cancellationPolicy,
    this.property,
    this.createdAt,
    this.updatedAt,
    required this.bookingOrderFees,
  });

  int id;
  int orderId;
  int propertyId;
  DateTime checkInDate;
  String checkInTime;
  DateTime checkOutDate;
  String checkOutTime;
  int numberOfGuests;
  int numberOfAdults;
  int numberOfChildren;
  int numberOfPets;
  int numberOfInfants;
  int numberOfNights;
  double basePrice;
  double totalNightsCost;
  String bookingType;
  String? specialRequests;
  int cancellationPolicyId;
  bool? canCancel;
  double? refundAmount;
  CancellationPolicy? cancellationPolicy;
  Property? property;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<BookingOrderFee> bookingOrderFees;

  factory BookingOrder.fromJson(Map<String, dynamic> json) => BookingOrder(
    id: json["id"],
    orderId: json["order_id"],
    propertyId: json["property_id"],
    checkInDate: DateTime.parse(json["check_in_date"]),
    checkInTime: json["check_in_time"],
    checkOutDate: DateTime.parse(json["check_out_date"]),
    checkOutTime: json["check_out_time"],
    numberOfGuests: int.parse(json["number_of_guests"].toString()),
    numberOfAdults: int.parse(json["number_of_adults"].toString()),
    numberOfChildren: int.parse(json["number_of_children"].toString()),
    numberOfPets: int.parse(json["number_of_pets"].toString()),
    numberOfInfants: int.parse(json["number_of_infants"].toString()),
    numberOfNights: int.parse(json["number_of_nights"].toString()),
    basePrice: double.parse(json["base_price"].toString()),
    totalNightsCost: double.parse(json["total_nights_cost"].toString()),
    bookingType: json["booking_type"],
    specialRequests: json["special_requests"],
    cancellationPolicyId: json["cancellation_policy_id"],
    canCancel: json["can_cancel"],
    refundAmount:
        json["refund_amount"] == null
            ? null
            : double.parse(json["refund_amount"].toString()),
    cancellationPolicy:
        json["cancellation_policy"] == null
            ? null
            : CancellationPolicy.fromJson(json["cancellation_policy"]),
    property:
        json["property"] == null ? null : Property.fromJson(json["property"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    bookingOrderFees:
        json["fees"] == null
            ? []
            : List<BookingOrderFee>.from(
              json["fees"].map((x) => BookingOrderFee.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "property_id": propertyId,
    "check_in_date": checkInDate.toIso8601String(),
    "check_in_time": checkInTime,
    "check_out_date": checkOutDate.toIso8601String(),
    "check_out_time": checkOutTime,
    "number_of_guests": numberOfGuests,
    "number_of_adults": numberOfAdults,
    "number_of_children": numberOfChildren,
    "number_of_pets": numberOfPets,
    "number_of_infants": numberOfInfants,
    "number_of_nights": numberOfNights,
    "base_price": basePrice,
    "total_nights_cost": totalNightsCost,
    "booking_type": bookingType,
    "special_requests": specialRequests,
    "cancellation_policy_id": cancellationPolicyId,
    "can_cancel": canCancel,
    "refund_amount": refundAmount,
    "cancellation_policy": cancellationPolicy?.toJson(),
    "property": property?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "fees": bookingOrderFees.map((x) => x.toJson()).toList(),
  };
}
