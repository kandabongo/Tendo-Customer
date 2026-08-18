class Currency {
  int? id;
  String code = "USD";
  String symbol = "\$";
  String name = "USD";

  Currency({
    this.id,
    required this.code,
    required this.symbol,
    required this.name,
  });

  factory Currency.fromJSON(dynamic json) => Currency(
    id: json["id"],
    code: json["code"],
    symbol: json["symbol"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'symbol': symbol,
    "name": name,
  };
}
