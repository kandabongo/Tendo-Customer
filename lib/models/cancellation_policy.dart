// To parse this JSON data, do
//
//     final cancellationPolicy = cancellationPolicyFromJson(jsonString);

import 'dart:convert';

CancellationPolicy cancellationPolicyFromJson(String str) =>
    CancellationPolicy.fromJson(json.decode(str));

String cancellationPolicyToJson(CancellationPolicy data) =>
    json.encode(data.toJson());

class CancellationPolicy {
  CancellationPolicy({
    required this.id,
    required this.name,
    required this.description,
    this.refundPercentageRules = const [],
    required this.isActive,
    required this.photo,
  });

  int id;
  String name;
  String description;
  List<RefundPercentageRule> refundPercentageRules;
  bool isActive;
  String photo;

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) =>
      CancellationPolicy(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        refundPercentageRules:
            json["refund_percentage_rules"] == null
                ? []
                : List<RefundPercentageRule>.from(
                  json["refund_percentage_rules"].map(
                    (x) => RefundPercentageRule.fromJson(x),
                  ),
                ),
        isActive:
            json["is_active"] is bool
                ? json["is_active"]
                : (int.parse(json["is_active"].toString()) == 1),
        photo: json["photo"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "refund_percentage_rules": List<dynamic>.from(
      refundPercentageRules.map((x) => x.toJson()),
    ),
    "is_active": isActive,
    "photo": photo,
  };
}

class RefundPercentageRule {
  RefundPercentageRule({
    required this.daysBefore,
    required this.refundPercentage,
  });

  int daysBefore;
  int refundPercentage;

  factory RefundPercentageRule.fromJson(Map<String, dynamic> json) =>
      RefundPercentageRule(
        daysBefore: json["days_before"],
        refundPercentage: json["refund_percentage"],
      );

  Map<String, dynamic> toJson() => {
    "days_before": daysBefore,
    "refund_percentage": refundPercentage,
  };
}
