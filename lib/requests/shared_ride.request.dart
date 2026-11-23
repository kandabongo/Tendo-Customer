import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/shared_ride.dart';
import 'package:fuodz/services/http.service.dart';

/// SHARED RIDES — customer API. All calls are server-authoritative; the backend
/// returns {enabled:false} when the feature is off, which the UI honours.
class SharedRideRequest extends HttpService {
  /// Transparent per-passenger quote + pooling preview.
  Future<SharedRideQuote> quote({
    required DeliveryAddress pickup,
    required DeliveryAddress dropoff,
    required int vehicleTypeId,
    int seats = 1,
  }) async {
    final apiResult = await post(Api.sharedRideQuote, {
      "pickup": "${pickup.latitude},${pickup.longitude}",
      "dropoff": "${dropoff.latitude},${dropoff.longitude}",
      "vehicle_type_id": vehicleTypeId,
      "seats": seats,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood || apiResponse.body is Map) {
      return SharedRideQuote.fromJson(
        apiResponse.body is Map
            ? Map<String, dynamic>.from(apiResponse.body)
            : null,
      );
    }
    throw apiResponse.message ?? "Unable to get a shared ride quote";
  }

  /// Create a shared booking: the customer's own order + match/create trip.
  Future<SharedRideBooking> book({
    required DeliveryAddress pickup,
    required DeliveryAddress dropoff,
    required int vehicleTypeId,
    required int paymentMethodId,
    int seats = 1,
  }) async {
    final apiResult = await post(Api.sharedRideBook, {
      "pickup": {
        "lat": pickup.latitude,
        "lng": pickup.longitude,
        "address": pickup.address,
      },
      "dropoff": {
        "lat": dropoff.latitude,
        "lng": dropoff.longitude,
        "address": dropoff.address,
      },
      "vehicle_type_id": vehicleTypeId,
      "payment_method_id": paymentMethodId,
      "seats": seats,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood || apiResponse.body is Map) {
      final booking = SharedRideBooking.fromJson(
        apiResponse.body is Map
            ? Map<String, dynamic>.from(apiResponse.body)
            : null,
      );
      if (!booking.success) {
        throw booking.message ?? apiResponse.message ?? "Shared booking failed";
      }
      return booking;
    }
    throw apiResponse.message ?? "Shared booking failed";
  }

  /// Raw-params quote — used by the taxi booking view model, which already
  /// holds pickup/dropoff coordinates and the selected vehicle type.
  Future<SharedRideQuote> quoteRaw({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required int vehicleTypeId,
    int seats = 1,
  }) async {
    final apiResult = await post(Api.sharedRideQuote, {
      "pickup": "$pickupLat,$pickupLng",
      "dropoff": "$dropoffLat,$dropoffLng",
      "vehicle_type_id": vehicleTypeId,
      "seats": seats,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return SharedRideQuote.fromJson(
      apiResponse.body is Map
          ? Map<String, dynamic>.from(apiResponse.body)
          : null,
    );
  }

  /// Raw-params book — mirrors [book] but takes primitives from the taxi VM,
  /// so the existing private-taxi address/vehicle types are not coupled in.
  Future<SharedRideBooking> bookRaw({
    required double pickupLat,
    required double pickupLng,
    String? pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    String? dropoffAddress,
    required int vehicleTypeId,
    required int paymentMethodId,
    int seats = 1,
  }) async {
    final apiResult = await post(Api.sharedRideBook, {
      "pickup": {"lat": pickupLat, "lng": pickupLng, "address": pickupAddress},
      "dropoff": {
        "lat": dropoffLat,
        "lng": dropoffLng,
        "address": dropoffAddress,
      },
      "vehicle_type_id": vehicleTypeId,
      "payment_method_id": paymentMethodId,
      "seats": seats,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood || apiResponse.body is Map) {
      final booking = SharedRideBooking.fromJson(
        apiResponse.body is Map
            ? Map<String, dynamic>.from(apiResponse.body)
            : null,
      );
      if (!booking.success) {
        throw booking.message ?? apiResponse.message ?? "Shared booking failed";
      }
      return booking;
    }
    throw apiResponse.message ?? "Shared booking failed";
  }

  /// Customer cancels their own seat (frees it; no charge was raised).
  Future<ApiResponse> cancel(int passengerId) async {
    final apiResult = await post(
      "${Api.sharedRidePassenger}/$passengerId/cancel",
      {},
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
