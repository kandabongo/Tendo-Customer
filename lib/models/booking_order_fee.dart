import 'package:fuodz/extensions/dynamic.dart';

class BookingOrderFee {
  int id;
  int bookingOrderId;
  int bookingFeeTypeId;
  String name;
  String calculationType;
  double baseAmount;
  double calculatedAmount;
  bool isTaxable;

  BookingOrderFee({
    required this.id,
    required this.bookingOrderId,
    required this.bookingFeeTypeId,
    required this.name,
    required this.calculationType,
    required this.baseAmount,
    required this.calculatedAmount,
    required this.isTaxable,
  });

  factory BookingOrderFee.fromJson(Map<String, dynamic> json) =>
      BookingOrderFee(
        id: json["id"],
        bookingOrderId: json["booking_order_id"],
        bookingFeeTypeId: json["booking_fee_type_id"],
        name: json["name"],
        calculationType: json["calculation_type"],
        baseAmount: json["base_amount"].toString().toDouble(),
        calculatedAmount: json["calculated_amount"].toString().toDouble(),
        isTaxable: json["is_taxable"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_order_id": bookingOrderId,
    "booking_fee_type_id": bookingFeeTypeId,
    "name": name,
    "calculation_type": calculationType,
    "base_amount": baseAmount,
    "calculated_amount": calculatedAmount,
    "is_taxable": isTaxable,
  };
}
