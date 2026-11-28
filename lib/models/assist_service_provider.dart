/// ASSIST multi-service (customer app) — a provider that offers a given canonical
/// service (approved + active), with their own price. Returned by
/// GET /assist/services/{id}/providers. Null-safe parsing throughout.
class AssistServiceProvider {
  final int vendorId;
  final String vendorName;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int offeringId;
  final String priceType; // fixed | range | quote
  final double price;
  final double? minPrice;
  final double? maxPrice;
  final double? inspectionFee;
  final bool isAvailable;
  final double? rating;
  final double? distanceKm;

  AssistServiceProvider({
    required this.vendorId,
    required this.vendorName,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.offeringId = 0,
    this.priceType = "fixed",
    this.price = 0,
    this.minPrice,
    this.maxPrice,
    this.inspectionFee,
    this.isAvailable = true,
    this.rating,
    this.distanceKm,
  });

  static int _i(dynamic v, [int d = 0]) =>
      v is num ? v.toInt() : (int.tryParse("$v") ?? d);
  static double? _dn(dynamic v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse("$v"));
  static bool _b(dynamic v) => v == true || v == 1 || v == "1";

  factory AssistServiceProvider.fromJson(Map<String, dynamic> json) {
    return AssistServiceProvider(
      vendorId: _i(json["vendor_id"]),
      vendorName: (json["vendor_name"] ?? "Provider").toString(),
      phone: json["phone"]?.toString(),
      address: json["address"]?.toString(),
      latitude: _dn(json["latitude"]),
      longitude: _dn(json["longitude"]),
      offeringId: _i(json["offering_id"]),
      priceType: (json["price_type"] ?? "fixed").toString(),
      price: _dn(json["price"]) ?? 0,
      minPrice: _dn(json["min_price"]),
      maxPrice: _dn(json["max_price"]),
      inspectionFee: _dn(json["inspection_fee"]),
      isAvailable: _b(json["is_available"]),
      rating: _dn(json["avg_rating"]),
      distanceKm: _dn(json["distance"]),
    );
  }
}
