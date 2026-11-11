/// Breakdown of an Assist job as the server reports it. The app never calculates these figures.
double _toDouble(dynamic value) => double.tryParse("${value ?? 0}") ?? 0.0;

class AssistExtraWork {
  AssistExtraWork({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
  });

  final int id;
  final String description;
  final double amount;

  /// pending | approved | rejected
  final String status;

  bool get isPending => status == "pending";

  factory AssistExtraWork.fromJson(dynamic json) => AssistExtraWork(
    id: int.tryParse("${json["id"]}") ?? 0,
    description: "${json["description"] ?? ""}",
    amount: _toDouble(json["amount"]),
    status: "${json["status"] ?? "pending"}",
  );
}

class AssistMaterialItem {
  AssistMaterialItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.total,
  });

  final int id;
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double total;

  factory AssistMaterialItem.fromJson(dynamic json) => AssistMaterialItem(
    id: int.tryParse("${json["id"]}") ?? 0,
    name: "${json["name"] ?? ""}",
    quantity: _toDouble(json["quantity"]),
    unit: "${json["unit"] ?? ""}",
    unitPrice: _toDouble(json["unit_price"]),
    total: _toDouble(json["total"]),
  );
}

class AssistInvoice {
  AssistInvoice({
    required this.locked,
    required this.service,
    required this.additionalWork,
    required this.additionalWorkPending,
    required this.materials,
    required this.transport,
    required this.total,
    required this.commission,
    required this.extraWorkItems,
    required this.materialItems,
    this.transportMode,
    this.travelAllowance = 0,
    this.taxiFare = 0,
    this.linkedTaxiOrderId,
    double? totalPayable,
  }) : totalPayable = totalPayable ?? total;

  /// True once the job is closed: nothing can be added or changed.
  final bool locked;
  final double service;
  final double additionalWork;
  final double additionalWorkPending;
  final double materials;
  final double transport;
  final double total;

  /// Tendo's commission on this job (shown to the provider only).
  final double? commission;
  final List<AssistExtraWork> extraWorkItems;
  final List<AssistMaterialItem> materialItems;

  // Provider Mobility (Assist): transport breakdown the customer sees.
  /// own | taxi | null
  final String? transportMode;

  /// Own-vehicle travel allowance the customer pays on top of the service (0 for taxi).
  final double travelAllowance;

  /// Tendo Taxi fare (paid separately through the taxi booking; shown for transparency).
  final double taxiFare;

  final int? linkedTaxiOrderId;

  /// Total Assist cash payable: service total + own-vehicle travel allowance.
  /// The taxi fare is NOT included here — it is paid through the taxi booking.
  final double totalPayable;

  factory AssistInvoice.fromJson(dynamic json) => AssistInvoice(
    locked: json["locked"] == true,
    service: _toDouble(json["service"]),
    additionalWork: _toDouble(json["additional_work"]),
    additionalWorkPending: _toDouble(json["additional_work_pending"]),
    materials: _toDouble(json["materials"]),
    transport: _toDouble(json["transport"]),
    total: _toDouble(json["total"]),
    commission: json["commission"] == null ? null : _toDouble(json["commission"]),
    extraWorkItems:
        json["additional_work_items"] == null
            ? []
            : List<AssistExtraWork>.from(
              (json["additional_work_items"] as List).map(
                (x) => AssistExtraWork.fromJson(x),
              ),
            ),
    materialItems:
        json["material_items"] == null
            ? []
            : List<AssistMaterialItem>.from(
              (json["material_items"] as List).map(
                (x) => AssistMaterialItem.fromJson(x),
              ),
            ),
    transportMode: json["transport_mode"]?.toString(),
    travelAllowance: _toDouble(json["travel_allowance"]),
    taxiFare: _toDouble(json["taxi_fare"]),
    linkedTaxiOrderId: json["linked_taxi_order_id"] == null
        ? null
        : int.tryParse("${json["linked_taxi_order_id"]}"),
    totalPayable: json["total_payable"] == null
        ? _toDouble(json["total"])
        : _toDouble(json["total_payable"]),
  );
}
