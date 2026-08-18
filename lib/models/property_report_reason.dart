class PropertyReportReason {
  int id;
  String reason;

  PropertyReportReason({required this.id, required this.reason});

  factory PropertyReportReason.fromJson(Map<String, dynamic> json) =>
      PropertyReportReason(id: json["id"], reason: json["reason"]);

  Map<String, dynamic> toJson() => {"id": id, "reason": reason};
}
