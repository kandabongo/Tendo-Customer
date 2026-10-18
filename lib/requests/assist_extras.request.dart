import 'package:fuodz/models/assist_invoice.dart';
import 'package:fuodz/services/http.service.dart';

/// Reading the charges on an Assist job and answering the provider's additional work requests.
/// The server decides every amount and checks that the answer comes from this job's customer.
/// A failure is thrown as the message to show.
class AssistExtrasRequest extends HttpService {
  static const String _networkMessage =
      "Please check your internet connection and try again";

  Future<AssistInvoice> getInvoice(int orderId) async {
    try {
      final response = await get("/assist/order/$orderId/invoice");
      if (response.statusCode == 200 && response.data is Map) {
        return AssistInvoice.fromJson(response.data);
      }
      throw _messageOf(response, "Could not load the job charges");
    } catch (error) {
      if (error is String) rethrow;
      throw _networkMessage;
    }
  }

  /// [approve] true = approve, false = reject.
  Future<void> respond({
    required int additionalWorkId,
    required bool approve,
  }) async {
    try {
      final response = await post("/assist/order/additional-work/respond", {
        "additional_work_id": additionalWorkId,
        "decision": approve ? "approve" : "reject",
      });
      if (response.statusCode == 200) {
        return;
      }
      throw _messageOf(response, "Could not record your answer");
    } catch (error) {
      if (error is String) rethrow;
      throw _networkMessage;
    }
  }

  String _messageOf(dynamic response, String fallback) {
    final data = response.data;
    if (data is Map && "${data["message"] ?? ""}".isNotEmpty) {
      return "${data["message"]}";
    }
    return fallback;
  }
}
