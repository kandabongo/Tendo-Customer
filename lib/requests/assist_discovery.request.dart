import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/assist_service_provider.dart';
import 'package:fuodz/services/http.service.dart';

/// ASSIST multi-service (customer app) — discovery of the providers that offer a
/// given canonical service (approved + active), with their price. Read-only.
class AssistDiscoveryRequest extends HttpService {
  Future<List<AssistServiceProvider>> providersForService(
    int serviceId, {
    double? latitude,
    double? longitude,
  }) async {
    final apiResult = await get(
      "${Api.assistServiceProviders}/$serviceId/providers",
      queryParameters: {
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood && apiResponse.body is Map) {
      final list = (apiResponse.body["providers"] as List?) ?? [];
      return list
          .map((e) =>
              AssistServiceProvider.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw apiResponse.message ?? "Unable to load providers";
  }
}
